import { describe, it, expect } from "vitest";
import request from "supertest";
import { createApp } from "../src/app";
import { MemoryStore } from "../src/store/memoryStore";
import { loadConfig } from "../src/config";

const app = createApp(loadConfig(), new MemoryStore());

// A second app with /loadtest explicitly enabled — the route is off by default now.
const loadtestApp = createApp(
  { ...loadConfig(), enableLoadtest: true },
  new MemoryStore(),
);

describe("health endpoints", () => {
  it("reports liveness", async () => {
    const res = await request(app).get("/healthz");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
    expect(res.body).toHaveProperty("instanceId");
    expect(res.body).toHaveProperty("version");
  });

  it("reports readiness", async () => {
    const res = await request(app).get("/readyz");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ready");
  });

  it("does not expose /loadtest when ENABLE_LOADTEST is off (default)", async () => {
    const res = await request(app).get("/loadtest");
    expect(res.status).toBe(404);
  });
});

describe("/loadtest (only when enabled)", () => {
  it("burns CPU for the requested duration", async () => {
    const res = await request(loadtestApp).get("/loadtest?ms=50");
    expect(res.status).toBe(200);
    expect(res.body.burnedMs).toBe(50);
    expect(res.body.iterations).toBeGreaterThan(0);
  });

  it("defaults the loadtest burn duration when ms is omitted", async () => {
    const res = await request(loadtestApp).get("/loadtest");
    expect(res.status).toBe(200);
    expect(res.body.burnedMs).toBe(200);
  });

  it("caps the loadtest burn duration", async () => {
    const res = await request(loadtestApp).get("/loadtest?ms=999999");
    expect(res.body.burnedMs).toBe(2000);
  });
});
