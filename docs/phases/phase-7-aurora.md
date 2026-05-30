# Phase 7 — Aurora + "which DB when"

**Goal:** model the same Tasklet data relationally on Aurora Serverless v2, then write the
decision doc comparing it to DynamoDB.

## Build
- `infra/data/` (extend): Aurora Serverless v2 (PostgreSQL) cluster in **private** subnets,
  min ACU low, security group allowing only the app SG. Secrets via Secrets Manager.
- App: `AuroraStore implements TaskStore` (a `tasks` table); select via `STORE_BACKEND=aurora`.

## Interview angle / decision doc → `docs/interview/dynamodb-vs-aurora.md`
- Access patterns: key-value/known-access (DynamoDB) vs ad-hoc queries/joins/transactions (Aurora).
- Scaling model: DynamoDB horizontal + serverless vs Aurora vertical + read replicas.
- Cost shape: per-request vs provisioned ACU/hours; idle cost.
- Consistency, relationships, schema flexibility, operational burden.

## Cost note
**Aurora Serverless v2 has a minimum ACU that bills hourly while up** — not free.
Apply, compare, **destroy the same session.**
