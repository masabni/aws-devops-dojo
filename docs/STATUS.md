# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-05-31 (Phase 2 applied — ECS Fargate + ALB LIVE & BILLABLE)

## Current phase

**Phase 2 APPLIED and verified. Next up: Phase 3 (autoscaling + load testing).**

> ⚠️ **BILLABLE STACK IS UP.** `infra/ecs` (ALB ~$0.0225/hr + 2 Fargate tasks) is
> running right now. **`terraform destroy` it before ending the session:**
> `cd infra/ecs && terraform destroy`. (Bootstrap + foundation stay up at ~$0.)

## Environment (live)

- AWS account: `850896627732`, user `masabni`, region `eu-central-1`. Terraform v1.15.5.
- Remote state bucket: `aws-devops-dojo-tfstate-850896627732`; lock table: `aws-devops-dojo-tf-locks`.
- Budget alarm: $20/mo → ahmadmasabni@gmail.com (50% / 90% actual, 100% forecast).
- **VPC:** `vpc-0d19b613ce741f0f0` (`10.20.0.0/16`), NAT **disabled** (cost-safe).
  - Public subnets: `subnet-0374cd6a7b3205d80`, `subnet-0283735914e7229ab`.
  - Private subnets: `subnet-01fbbde296655135d`, `subnet-04981791c60efbb3b`.
- **ECS (Phase 2, BILLABLE):** cluster + service `aws-devops-dojo-tasklet`, 2 Fargate
  tasks (256 CPU / 512 MiB) in the public subnets, image `tasklet:v1`.
  - ALB URL: http://aws-devops-dojo-tasklet-806218387.eu-central-1.elb.amazonaws.com/
  - ECR repo: `850896627732.dkr.ecr.eu-central-1.amazonaws.com/tasklet` (keep-last-5 lifecycle).
  - Verified: HTTP 200, `/healthz` ok, ALB round-robins both tasks (`10.20.0.163` / `10.20.1.175`).

## Done

- [x] Repo scaffolded: app, infra skeleton, docs, `.claude/`, CLAUDE.md, README.
- [x] **Phase 1** — Tasklet app (Express + TS + Tailwind UI), 100% test coverage,
      multi-stage Dockerfile, health/readiness/loadtest endpoints. Runs locally + committed/pushed.
- [x] **Phase 0 APPLIED** — `infra/bootstrap` (S3 state + DynamoDB lock + budget alarm)
      and `infra/foundation` (VPC + subnets). Both ~$0 standing cost; safe to leave up.
- [x] **Phase 2 APPLIED** — `infra/ecs` (ECR + cluster + task def + service + ALB + SGs +
      IAM execution role + CloudWatch logs). Image cross-built `linux/amd64`, pushed as `v1`.
      12 resources. Verified app serves over the ALB with traffic spread across 2 tasks.
      **BILLABLE — destroy at session end.**

## Next actions (in order)

1. **First: if ending the session, `cd infra/ecs && terraform destroy`** (billable ALB+tasks).
2. Start Phase 3 (autoscaling + load testing) — see `docs/phases/phase-3-autoscaling.md`.
   Add Application Auto Scaling (target-tracking on CPU) to the ECS service, then drive
   `/loadtest` and watch task count scale out/in. (Gate `/loadtest` first — see tech debt.)

## Known follow-ups / tech debt

- Backend uses deprecated `dynamodb_table` lock arg. Modern TF (1.10+) locks natively via
  S3 (`use_lockfile = true`) — can switch and drop the DynamoDB table later.
- `/loadtest` non-numeric `?ms=` returns `burnedMs: null` (no-op); add `Number.isFinite` guard.
- Gate `/loadtest` behind a flag before it's internet-reachable (Phase 2/3).

## Session-end checklist (cost safety)

- [ ] `terraform destroy` any billable stack started this session (ecs/eks/data/dns).
- [ ] Confirm no ECS services, EKS clusters, NAT gateways, Aurora clusters, or ALBs left running.
- [ ] Update this file.
