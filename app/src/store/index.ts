import type { Config } from "../config";
import type { TaskStore } from "./types";
import { MemoryStore } from "./memoryStore";
import { DynamoStore } from "./dynamoStore";

// Pick the store backend from config so the rest of the app stays backend-agnostic
// (createApp/tasksRouter only know the TaskStore interface). STORE_BACKEND flips it.
export function createStore(cfg: Config): TaskStore {
  if (cfg.storeBackend === "dynamodb") {
    if (!cfg.tableName) {
      // Fail fast at startup rather than 500-ing on the first request.
      throw new Error("STORE_BACKEND=dynamodb requires TASKS_TABLE_NAME to be set");
    }
    return new DynamoStore(cfg.tableName, cfg.region);
  }
  return new MemoryStore();
}
