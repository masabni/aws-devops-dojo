import { describe, it, expect } from "vitest";
import { createStore } from "../src/store";
import { MemoryStore } from "../src/store/memoryStore";
import { DynamoStore } from "../src/store/dynamoStore";
import { loadConfig } from "../src/config";

const base = loadConfig();

describe("createStore (backend selection)", () => {
  it("returns a MemoryStore for the memory backend", () => {
    expect(createStore({ ...base, storeBackend: "memory" })).toBeInstanceOf(
      MemoryStore,
    );
  });

  it("returns a DynamoStore for the dynamodb backend", () => {
    const store = createStore({
      ...base,
      storeBackend: "dynamodb",
      tableName: "tasklet-table",
      region: "eu-central-1",
    });
    expect(store).toBeInstanceOf(DynamoStore);
  });

  it("throws when the dynamodb backend has no table name", () => {
    expect(() =>
      createStore({ ...base, storeBackend: "dynamodb", tableName: "" }),
    ).toThrow(/TASKS_TABLE_NAME/);
  });
});
