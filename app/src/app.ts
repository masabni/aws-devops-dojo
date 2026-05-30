import express, { type Express } from "express";
import type { Config } from "./config";
import type { TaskStore } from "./store/types";
import { tasksRouter } from "./routes/tasks";
import { healthRouter } from "./routes/health";
import { renderPage } from "./views/layout";

// App factory: takes its dependencies (config + store) as arguments so tests can
// build an app with an isolated store, and later phases can inject a DynamoDB or
// Aurora-backed store without touching this file.
export function createApp(cfg: Config, store: TaskStore): Express {
  const app = express();
  app.use(express.urlencoded({ extended: false }));
  app.use(express.json());

  app.use(healthRouter(cfg));

  app.get("/", async (_req, res) => {
    res.type("html").send(renderPage(await store.list(), cfg));
  });

  app.use("/tasks", tasksRouter(store));

  return app;
}
