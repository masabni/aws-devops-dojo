import { describe, it, expect, afterEach } from "vitest";
import { loadConfig } from "../src/config";

const ENV_KEYS = [
  "PORT",
  "NODE_ENV",
  "INSTANCE_ID",
  "HOSTNAME",
  "APP_VERSION",
  "ENABLE_LOADTEST",
  "STORE_BACKEND",
  "TASKS_TABLE_NAME",
  "AWS_REGION",
] as const;

describe("loadConfig", () => {
  const saved: Record<string, string | undefined> = {};
  for (const k of ENV_KEYS) saved[k] = process.env[k];

  afterEach(() => {
    for (const k of ENV_KEYS) {
      if (saved[k] === undefined) delete process.env[k];
      else process.env[k] = saved[k];
    }
  });

  it("falls back to defaults when no env is set", () => {
    for (const k of ENV_KEYS) delete process.env[k];
    const cfg = loadConfig();
    expect(cfg.port).toBe(3000);
    expect(cfg.env).toBe("development");
    expect(cfg.instanceId).toBe("local");
    expect(cfg.version).toBe("dev");
    expect(cfg.storeBackend).toBe("memory");
    expect(cfg.enableLoadtest).toBe(false);
    expect(cfg.tableName).toBe("");
    expect(cfg.region).toBe("eu-central-1");
  });

  it("reads values from the environment", () => {
    process.env.PORT = "8080";
    process.env.NODE_ENV = "production";
    process.env.INSTANCE_ID = "task-abc";
    process.env.APP_VERSION = "1.2.3";
    process.env.ENABLE_LOADTEST = "true";
    process.env.STORE_BACKEND = "dynamodb";
    process.env.TASKS_TABLE_NAME = "aws-devops-dojo-tasklet";
    process.env.AWS_REGION = "us-east-1";
    const cfg = loadConfig();
    expect(cfg.port).toBe(8080);
    expect(cfg.env).toBe("production");
    expect(cfg.instanceId).toBe("task-abc");
    expect(cfg.version).toBe("1.2.3");
    expect(cfg.enableLoadtest).toBe(true);
    expect(cfg.storeBackend).toBe("dynamodb");
    expect(cfg.tableName).toBe("aws-devops-dojo-tasklet");
    expect(cfg.region).toBe("us-east-1");
  });

  it("falls back to HOSTNAME for instanceId when INSTANCE_ID is unset", () => {
    delete process.env.INSTANCE_ID;
    process.env.HOSTNAME = "host-9";
    expect(loadConfig().instanceId).toBe("host-9");
  });
});
