# Phase 3 — Autoscaling + load testing

**Goal:** make the ECS service scale out under load and back in when it's quiet, and
watch it happen.

## Build (`infra/ecs/`, extending Phase 2)
- Application Auto Scaling target on the ECS service: min 2 / max 6 tasks.
- Target-tracking policy on **average CPU = 50%** (and/or ALB request-count-per-target).
- Optional CloudWatch dashboard/alarms to visualize.

## Experiment
- Drive load: `hey`/`ab`/`vegeta` against `/loadtest?ms=200` with high concurrency.
- Watch tasks scale from 2 → up to 6; stop the load and watch scale-in (slower, by design).

## Interview angle
- Target tracking vs step scaling vs scheduled scaling.
- Why scale-in is deliberately slower than scale-out (avoid flapping).
- ALB + autoscaling together: request-count-per-target as a scaling metric.
- Cooldowns, and why min capacity > 1 matters for availability.

## Cost note
More tasks = more cost while load-testing. **Destroy at session end.**
