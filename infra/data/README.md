# infra/data — Phase 5 (DynamoDB) / Phase 7 (Aurora)

**Phase 5:** the Tasklet single-table DynamoDB store (`<project>-<app_name>` =
`aws-devops-dojo-tasklet`), `PAY_PER_REQUEST`, point-in-time recovery on.
**Phase 7** will add an Aurora Serverless v2 cluster here for the "which DB when" lab.

**Standing cost: ≈ $0.** On-demand DynamoDB at dojo traffic is effectively free, and PITR
is pennies. Safe to leave up between sessions. **Aurora (Phase 7) bills hourly — destroy
that same session.**

## Apply

```bash
cd infra/data
terraform init -backend-config=backend.hcl
terraform apply
terraform output table_name   # -> set as TASKS_TABLE_NAME on the ECS task
```

## Single-table design (what to know)

- Key schema: `PK` (string) only, no sort key. Each task is one item, `PK = "TASK#<id>"`.
- Access patterns: get/put/update/delete by id are direct key ops; **list = Scan**.
- Scan is fine at dojo scale but an anti-pattern at real scale — you'd switch to a fixed
  partition + sort key (Query) or a GSI to avoid reading the whole table. The app's
  `DynamoStore` carries the same note.

## Who reads this

- The **ECS task role** (`infra/ecs`) scopes its DynamoDB permissions to `table_arn`.
- The **ECS task definition** passes `table_name` to the app as `TASKS_TABLE_NAME`.
Both read these via `terraform_remote_state.data`.
