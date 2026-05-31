# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-05-31 (Phase 3 applied — autoscaling verified; ECS LIVE & BILLABLE)

## Current phase

**Phase 3 APPLIED and verified (real scale-out observed). Next up: Phase 4 (CI/CD, GitHub Actions).**

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
- **Autoscaling (Phase 3):** Application Auto Scaling on the service, min 2 / max 6,
  target-tracking on avg CPU 50% (`autoscaling.tf`). Service has `lifecycle ignore_changes
  = [desired_count]` so TF and autoscaling don't fight. Verified: under `ab` load CPU
  crossed 50%, AlarmHigh → ALARM, scaling activity "Setting desired count to 3" fired.

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
- [x] **Phase 3 APPLIED** — `infra/ecs/autoscaling.tf` (scalable target + CPU target-tracking
      policy) + `ecs.tf` lifecycle ignore on desired_count. Drove load with `ab`, observed a
      real scale-out (2→3) via AlarmHigh→ALARM and the scaling-activities audit log.
      Lesson logged: `/loadtest` CPU-burn blocks Node's event loop → starves `/healthz` →
      ECS recycles busy tasks. Gate `/loadtest` before Phase 4 internet exposure.

## Next actions (in order)

1. **First: if ending the session, `cd infra/ecs && terraform destroy`** (billable ALB+tasks).
2. Start Phase 4 (CI/CD with GitHub Actions) — see `docs/phases/phase-4-cicd-github-actions.md`.
   GitHub OIDC role (keyless auth), workflow: test on PR → build/push image to ECR →
   update ECS service. Gate `/loadtest` behind a flag as part of this (it's internet-reachable).

## Known follow-ups / tech debt

- Backend uses deprecated `dynamodb_table` lock arg. Modern TF (1.10+) locks natively via
  S3 (`use_lockfile = true`) — can switch and drop the DynamoDB table later.
- `/loadtest` non-numeric `?ms=` returns `burnedMs: null` (no-op); add `Number.isFinite` guard.
- Gate `/loadtest` behind a flag before it's internet-reachable (Phase 2/3).

## Session-end checklist (cost safety)

- [ ] `terraform destroy` any billable stack started this session (ecs/eks/data/dns).
- [ ] Confirm no ECS services, EKS clusters, NAT gateways, Aurora clusters, or ALBs left running.
- [ ] Update this file.
