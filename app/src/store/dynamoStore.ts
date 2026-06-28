import { randomUUID } from "node:crypto";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";
import type { Task, TaskStore } from "./types";

// Single-table design: each task is one item keyed by PK = "TASK#<id>".
// The DocumentClient (lib-dynamodb) marshals plain JS objects <-> DynamoDB's typed
// attribute format for us, so we never hand-write { S: "..." } shapes.
const PK_PREFIX = "TASK#";

interface StoredTask {
  PK: string;
  title: string;
  done: boolean;
  createdAt: string;
}

const toItem = (t: Task): StoredTask => ({
  PK: PK_PREFIX + t.id,
  title: t.title,
  done: t.done,
  createdAt: t.createdAt,
});

const toTask = (i: StoredTask): Task => ({
  id: i.PK.slice(PK_PREFIX.length),
  title: i.title,
  done: i.done,
  createdAt: i.createdAt,
});

// Durable, shared store: every ECS task talks to the same table, so the list is
// consistent across replicas (unlike MemoryStore, which is per-process).
export class DynamoStore implements TaskStore {
  private readonly doc: DynamoDBDocumentClient;

  constructor(private readonly tableName: string, region: string) {
    this.doc = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));
  }

  async list(): Promise<Task[]> {
    // Scan reads EVERY item — fine at dojo scale, an anti-pattern at real scale
    // (cost/latency grow with table size). At scale: fixed partition + Query, or a GSI.
    const out = await this.doc.send(new ScanCommand({ TableName: this.tableName }));
    const items = (out.Items ?? []) as StoredTask[];
    return items
      .map(toTask)
      .sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  }

  async create(title: string): Promise<Task> {
    const task: Task = {
      id: randomUUID(),
      title,
      done: false,
      createdAt: new Date().toISOString(),
    };
    await this.doc.send(
      new PutCommand({ TableName: this.tableName, Item: toItem(task) }),
    );
    return task;
  }

  async toggle(id: string): Promise<Task | undefined> {
    // Read-modify-write: DynamoDB can't negate a boolean inside an UpdateExpression,
    // so we read the current value, flip it, and put it back. (Last-writer-wins; a
    // concurrent toggle could be lost — acceptable for the dojo, not for real money.)
    const got = await this.doc.send(
      new GetCommand({ TableName: this.tableName, Key: { PK: PK_PREFIX + id } }),
    );
    if (!got.Item) return undefined;
    const task = toTask(got.Item as StoredTask);
    task.done = !task.done;
    await this.doc.send(
      new PutCommand({ TableName: this.tableName, Item: toItem(task) }),
    );
    return task;
  }

  async remove(id: string): Promise<boolean> {
    // ReturnValues=ALL_OLD makes Delete report what it removed, so we can tell a real
    // delete (item existed) from a no-op (nothing there) and return 404 accordingly.
    const out = await this.doc.send(
      new DeleteCommand({
        TableName: this.tableName,
        Key: { PK: PK_PREFIX + id },
        ReturnValues: "ALL_OLD",
      }),
    );
    return out.Attributes != null;
  }
}
