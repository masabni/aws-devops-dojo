# aws-devops-dojo — design

**Date:** 2026-05-30
**Status:** approved (Approach A — incremental, one app layered)

## Purpose

A hands-on practice ground to convert AWS Solutions Architect Associate *theory* into
*practical* DevOps muscle memory. Driven by real interview questions the owner has faced:
design a CI/CD pipeline; ECS vs EKS; DynamoDB vs Aurora; autoscaling + load balancers;
DNS setup end to end.

## Approach

Build ONE small app (**Tasklet**) and layer AWS capabilities onto it across 10 phases.
Each phase is a self-contained Terraform stack: `apply` → experiment → `destroy`. Every
phase also produces a short interview-style recap doc written from what was actually built.

Rejected alternatives: two parallel tracks (loses the single-architecture narrative,
repeats wiring) and interview-driven shallow demos (crisp talking points but no depth).
Chosen approach folds the interview recaps into the deep, hands-on path.

## The app: Tasklet

A tiny task/notes service. Chosen because the same domain models cleanly as **single-table
DynamoDB** and as **relational Aurora**, making the "which DB when" lab a genuine
comparison rather than a contrived one.

- **Stack:** Node.js + TypeScript + Express; server-rendered HTML with Tailwind (Play CDN).
- **Structure:** app factory (`createApp(config, store)`) with an injectable `TaskStore`
  interface. Phase 1 uses an in-memory store; later phases inject DynamoDB / Aurora stores
  without touching routes.
- **Operational endpoints, present from day one because later phases need them:**
  - `/healthz` (liveness), `/readyz` (readiness) — for ALB / Kubernetes probes.
  - `/loadtest?ms=` (capped CPU burn) — to drive target-tracking autoscaling on demand.
  - Footer surfaces `instanceId` + `version` — to *see* traffic spread across replicas
    and to watch rolling deploys.
- **Container:** multi-stage Dockerfile (build → prod deps → minimal non-root runtime)
  with a Docker `HEALTHCHECK`.

The in-memory store is intentionally non-durable: once multiple replicas run, each keeps
its own copy — a live demonstration of *why* a shared data store is needed (motivates Phase 5/7).

## Infrastructure

- **IaC:** Terraform, one stack per concern under `infra/` so each can be applied and
  destroyed independently for cost control.
- **State:** S3 remote state + DynamoDB lock table (created in Phase 0 `bootstrap`).
- **Networking:** a single small VPC (Phase 0 `foundation`) reused by later phases.
- **Compute:** ECS Fargate first (Phase 2), then the *same image* on EKS (Phase 6).
- **Data:** DynamoDB (Phase 5) then Aurora Serverless v2 (Phase 7).
- **Edge:** Route 53 + ACM + CloudFront in front of the ALB (Phase 8).
- **CI/CD:** GitHub Actions with GitHub OIDC to AWS (no static keys) in Phase 4, then
  CodePipeline/CodeBuild in Phase 9 for comparison.

## Phase breakdown

0. Foundations & cost safety — budget alarm, S3+DynamoDB state, VPC, IAM baseline.
1. Containerize + run locally. **(done in scaffold)**
2. ECS Fargate + ALB.
3. Autoscaling + load testing.
4. CI/CD with GitHub Actions (OIDC).
5. DynamoDB store (single-table).
6. EKS (same image).
7. Aurora Serverless v2 + "which DB when" decision doc.
8. DNS / TLS / CDN.
9. CodePipeline/CodeBuild.

## Cost safety (cross-cutting)

Personal account, small budget. Hard rules: a monthly budget alarm (Phase 0); never apply
without the user present; always `terraform destroy` billable stacks at session end; never
leave EKS control planes, NAT gateways, Aurora clusters, or ALBs running idle. CI/CD uses
OIDC so there are no long-lived credentials to leak.

## Out of scope

Production-grade frontend build tooling, multi-region/HA, blue-green at the edge, and a
real user-auth system. This is a learning repo; depth goes into the DevOps path, not app
features.
