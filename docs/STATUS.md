# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-05-31 (Phase 3 done & code committed; ecs stack DESTROYED — $0 standing)

## Current phase

**Phases 2 + 3 code complete and committed. `infra/ecs` was applied, verified, then
DESTROYED at session end. Next up: Phase 4 (CI/CD, GitHub Actions).**

> ✅ **Nothing billable running.** The `infra/ecs` stack (ECR/cluster/service/ALB/
> autoscaling) was torn down — verified no ALBs, ECS clusters, ECR repos, or NAT
> gateways remain. To resume Phase 2/3 hands-on, re-apply per `infra/ecs/README.md`
> (apply ECR → build/push `tasklet:v1` → apply rest). Bootstrap + foundation still up at ~$0.

## Environment (live)

- AWS account: `850896627732`, user `masabni`, region `eu-central-1`. Terraform v1.15.5.
- Remote state bucket: `aws-devops-dojo-tfstate-850896627732`; lock table: `aws-devops-dojo-tf-locks`.
- Budget alarm: $20/mo → ahmadmasabni@gmail.com (50% / 90% actual, 100% forecast).
- **VPC:** `vpc-0d19b613ce741f0f0` (`10.20.0.0/16`), NAT **disabled** (cost-safe).
  - Public subnets: `subnet-0374cd6a7b3205d80`, `subnet-0283735914e7229ab`.
  - Private subnets: `subnet-01fbbde296655135d`, `subnet-04981791c60efbb3b`.
- **ECS / autoscaling (Phase 2+3): DESTROYED at session end — not currently running.**
  Code lives in `infra/ecs/` (committed). When re-applied it creates: cluster + service
  `aws-devops-dojo-tasklet` (2 Fargate tasks, 256/512, public subnets, image `tasklet:v1`),
  internet-facing ALB, ECR repo `…/tasklet` (keep-last-5), and Application Auto Scaling
  (min 2 / max 6, CPU target 50%, `autoscaling.tf`; service has `lifecycle ignore_changes
  = [desired_count]` so TF and autoscaling don't fight). ALB DNS name is recreated fresh
  on each apply. Last run verified: HTTP 200, `/healthz` ok, ALB round-robin across 2 AZs,
  and a real scale-out (2→3) via AlarmHigh → ALARM.

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
