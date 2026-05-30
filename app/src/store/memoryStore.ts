import { randomUUID } from "node:crypto";
import type { Task, TaskStore } from "./types";

// In-memory store for Phase 1. It is intentionally NOT durable: when we move to
// ECS/EKS with multiple tasks, each replica keeps its own copy — which is a great
// live demonstration of *why* we need a shared data store (DynamoDB/Aurora) later.
export class MemoryStore implements TaskStore {
  private tasks = new Map<string, Task>();

  async list(): Promise<Task[]> {
    return [...this.tasks.values()].sort((a, b) =>
      a.createdAt.localeCompare(b.createdAt),
    );
  }

  async create(title: string): Promise<Task> {
    const task: Task = {
      id: randomUUID(),
      title,
      done: false,
      createdAt: new Date().toISOString(),
    };
    this.tasks.set(task.id, task);
    return task;
  }

  async toggle(id: string): Promise<Task | undefined> {
    const task = this.tasks.get(id);
    if (!task) return undefined;
    task.done = !task.done;
    return task;
  }

  async remove(id: string): Promise<boolean> {
    return this.tasks.delete(id);
  }
}
