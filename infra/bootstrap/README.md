# infra/bootstrap — remote state + budget alarm (Phase 0, one-time)

Creates the S3 bucket + DynamoDB lock table that every other stack uses for remote
state, plus a monthly AWS Budget alarm as a cost-safety net.

This stack uses **local state** on purpose (it bootstraps the remote backend itself).

## Apply (one time)

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit it
terraform init
terraform plan
terraform apply        # cost: ~$0. S3 + on-demand DynamoDB + Budgets are effectively free at this scale.
```

Note the `state_bucket` and `lock_table` outputs — the `foundation` stack (and later
stacks) reference them in their backend config (`backend.hcl`).

## Teardown

Generally **leave this up** — it's near-zero cost and other stacks depend on it. Only
destroy it after every other stack is gone (and empty the bucket first).
