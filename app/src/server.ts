import { loadConfig } from "./config";
import { MemoryStore } from "./store/memoryStore";
import { createApp } from "./app";

const cfg = loadConfig();
const store = new MemoryStore();
const app = createApp(cfg, store);

const server = app.listen(cfg.port, () => {
  console.log(
    JSON.stringify({
      msg: "tasklet listening",
      port: cfg.port,
      env: cfg.env,
      instanceId: cfg.instanceId,
      version: cfg.version,
    }),
  );
});

// Graceful shutdown: ECS/EKS send SIGTERM on deploy/scale-in. Closing the server
// cleanly lets in-flight requests finish and avoids dropped connections.
for (const signal of ["SIGTERM", "SIGINT"] as const) {
  process.on(signal, () => {
    console.log(JSON.stringify({ msg: "shutting down", signal }));
    server.close(() => process.exit(0));
  });
}
