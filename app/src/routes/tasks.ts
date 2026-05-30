import { Router } from "express";
import type { TaskStore } from "../store/types";

// JSON API for tasks. The HTML form posts here too (via method=post) and we
// redirect back to "/" so the browser shows the refreshed list.
export function tasksRouter(store: TaskStore): Router {
  const router = Router();

  router.get("/", async (_req, res) => {
    res.json(await store.list());
  });

  router.post("/", async (req, res) => {
    const title = String(req.body?.title ?? "").trim();
    if (!title) {
      res.status(400).json({ error: "title is required" });
      return;
    }
    const task = await store.create(title);
    if (req.accepts(["html", "json"]) === "html") {
      res.redirect("/");
      return;
    }
    res.status(201).json(task);
  });

  router.post("/:id/toggle", async (req, res) => {
    const task = await store.toggle(req.params.id);
    if (!task) {
      res.status(404).json({ error: "not found" });
      return;
    }
    if (req.accepts(["html", "json"]) === "html") {
      res.redirect("/");
      return;
    }
    res.json(task);
  });

  router.post("/:id/delete", async (req, res) => {
    const ok = await store.remove(req.params.id);
    if (!ok) {
      res.status(404).json({ error: "not found" });
      return;
    }
    if (req.accepts(["html", "json"]) === "html") {
      res.redirect("/");
      return;
    }
    res.status(204).end();
  });

  return router;
}
