# Phase 5 — DynamoDB store

**Goal:** replace the in-memory store with a durable DynamoDB-backed store so all ECS
tasks share state (fixing the inconsistency you saw in Phase 2).

## Build
- `infra/data/`: a DynamoDB table (`PAY_PER_REQUEST`), single-table design
  (PK = `TASK#<id>`), point-in-time recovery on.
- App: add `DynamoStore implements TaskStore` (AWS SDK v3); select it via `STORE_BACKEND=dynamodb`.
- ECS **task role** with least-privilege access to just this table.

## Interview angle
- Single-table design; partition vs sort keys; access patterns first.
- On-demand vs provisioned capacity; hot partitions.
- Task role (app permissions) vs execution role (platform permissions).
- Eventual vs strongly consistent reads.

## Cost note
On-demand DynamoDB at dojo scale is effectively free. Table can stay up cheaply, but
**destroy the ECS stack** at session end.
