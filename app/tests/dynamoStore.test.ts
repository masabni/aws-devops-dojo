import { describe, it, expect, beforeEach } from "vitest";
import { mockClient } from "aws-sdk-client-mock";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";
import { DynamoStore } from "../src/store/dynamoStore";

// aws-sdk-client-mock intercepts .send() on every DynamoDBDocumentClient instance,
// so no AWS credentials or network are needed — we assert against the commands sent.
const ddbMock = mockClient(DynamoDBDocumentClient);

describe("DynamoStore", () => {
  const store = new DynamoStore("test-table", "eu-central-1");

  beforeEach(() => ddbMock.reset());

  it("lists tasks via Scan, mapped and sorted by createdAt", async () => {
    ddbMock.on(ScanCommand).resolves({
      Items: [
        { PK: "TASK#b", title: "second", done: false, createdAt: "2024-01-02T00:00:00Z" },
        { PK: "TASK#a", title: "first", done: true, createdAt: "2024-01-01T00:00:00Z" },
      ],
    });
    const tasks = await store.list();
    expect(tasks.map((t) => t.id)).toEqual(["a", "b"]); // sorted by createdAt
    expect(tasks[0]).toEqual({
      id: "a",
      title: "first",
      done: true,
      createdAt: "2024-01-01T00:00:00Z",
    });
    expect(ddbMock.commandCalls(ScanCommand)[0].args[0].input.TableName).toBe(
      "test-table",
    );
  });

  it("returns an empty list when the table has no items", async () => {
    ddbMock.on(ScanCommand).resolves({}); // Items undefined -> [] branch
    expect(await store.list()).toEqual([]);
  });

  it("creates a task and writes it as a TASK# item", async () => {
    ddbMock.on(PutCommand).resolves({});
    const task = await store.create("buy milk");
    expect(task.title).toBe("buy milk");
    expect(task.done).toBe(false);
    expect(task.id).toBeTruthy();
    const item = ddbMock.commandCalls(PutCommand)[0].args[0].input.Item;
    expect(item?.PK).toBe(`TASK#${task.id}`);
    expect(item?.createdAt).toBe(task.createdAt);
  });

  it("toggles an existing task (Get then Put)", async () => {
    ddbMock.on(GetCommand).resolves({
      Item: { PK: "TASK#x", title: "t", done: false, createdAt: "2024-01-01T00:00:00Z" },
    });
    ddbMock.on(PutCommand).resolves({});
    const task = await store.toggle("x");
    expect(task?.id).toBe("x");
    expect(task?.done).toBe(true);
    expect(ddbMock.commandCalls(PutCommand)[0].args[0].input.Item?.done).toBe(true);
  });

  it("returns undefined toggling a missing task", async () => {
    ddbMock.on(GetCommand).resolves({}); // no Item
    expect(await store.toggle("nope")).toBeUndefined();
    expect(ddbMock.commandCalls(PutCommand)).toHaveLength(0); // no write attempted
  });

  it("removes an existing task and returns true", async () => {
    ddbMock.on(DeleteCommand).resolves({ Attributes: { PK: "TASK#x" } });
    expect(await store.remove("x")).toBe(true);
    expect(ddbMock.commandCalls(DeleteCommand)[0].args[0].input.Key?.PK).toBe(
      "TASK#x",
    );
  });

  it("returns false removing a missing task", async () => {
    ddbMock.on(DeleteCommand).resolves({}); // no Attributes -> nothing was deleted
    expect(await store.remove("nope")).toBe(false);
  });
});
