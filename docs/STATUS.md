# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-05-30 (scaffold)

## Current phase

**Phase 1 complete. Next up: Phase 0 apply, then Phase 2 (ECS Fargate + ALB).**

Phase 1 (the app) was built first because it needs no AWS. Phase 0 (cost-safety +
foundation infra) is *written* but not *applied* — it's blocked on local prerequisites.

## Done

- [x] Repo scaffolded: app, infra skeleton, docs, `.claude/`, CLAUDE.md, README.
- [x] **Phase 1** — Tasklet app (Express + TS + Tailwind UI), 11 passing tests,
      multi-stage Dockerfile, health/readiness/loadtest endpoints. Runs locally.
- [x] **Phase 0 Terraform written** — `infra/bootstrap` (S3 state + DynamoDB lock +
      monthly budget alarm) and `infra/foundation` (VPC + IAM baseline). NOT applied.

## Blocked / prerequisites before next apply

- [ ] Install Terraform (`brew install terraform`).
- [ ] Configure valid AWS credentials (`aws configure` / SSO) — current token is invalid.
- [ ] Decide a budget alarm email + monthly threshold (see `infra/bootstrap/variables.tf`).

## Next actions (in order)

1. Install Terraform + fix AWS creds.
2. `infra/bootstrap`: review vars → `terraform apply` (creates state bucket, lock table,
   budget alarm). One-time.
3. `infra/foundation`: `terraform apply` (VPC, subnets, IAM baseline).
4. Start Phase 2 (ECS Fargate + ALB) — see `docs/phases/phase-2-ecs-fargate.md`.

## Session-end checklist (cost safety)

- [ ] `terraform destroy` any billable stack started this session (ecs/eks/data/dns).
- [ ] Confirm no ECS services, EKS clusters, NAT gateways, Aurora clusters, or ALBs left running.
- [ ] Update this file.
