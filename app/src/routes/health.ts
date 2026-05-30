import { Router } from "express";
import type { Config } from "../config";

export function healthRouter(cfg: Config): Router {
  const router = Router();
  const startedAt = Date.now();

  // Liveness: is the process up? ALB/EKS uses this to decide whether to restart.
  router.get("/healthz", (_req, res) => {
    res.json({
      status: "ok",
      instanceId: cfg.instanceId,
      version: cfg.version,
      uptimeSeconds: Math.round((Date.now() - startedAt) / 1000),
    });
  });

  // Readiness: is the process ready to serve traffic? Split from liveness so a
  // later phase can flip this to "not ready" while a dependency (DB) warms up.
  router.get("/readyz", (_req, res) => {
    res.json({ status: "ready" });
  });

  // Deliberate CPU burn so we can trigger target-tracking autoscaling on demand
  // in the scaling phase. ?ms= controls how long to spin (capped to keep it safe).
  router.get("/loadtest", (req, res) => {
    const ms = Math.min(Number(req.query.ms ?? 200), 2000);
    const until = Date.now() + ms;
    let iterations = 0;
    while (Date.now() < until) {
      Math.sqrt(Math.random() * Math.random());
      iterations++;
    }
    res.json({ burnedMs: ms, iterations, instanceId: cfg.instanceId });
  });

  return router;
}
