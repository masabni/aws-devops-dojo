# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-06-28 (Phase 4 CI/CD APPLIED + pushed; CI verified green; $0 standing)

## Current phase

**Phase 4 (CI/CD via GitHub Actions) DONE.** `infra/cicd` (OIDC provider + deploy role)
APPLIED — $0 standing. Repo variable `AWS_DEPLOY_ROLE_ARN` set. Code committed + pushed to
`main` (`2fb910f`). **CI workflow verified green on GitHub** (checkout → npm ci → typecheck →
test 22/22 → build, 21s). The *deploy* workflow is manual and untested end-to-end (needs
`infra/ecs` applied — that's the optional billable dry-run). Next: **Phase 5 (DynamoDB)**.

> ℹ️ **Repo is now PUBLIC** (`masabni/aws-devops-dojo`). Changed from private so GitHub
> Actions minutes are free (private-repo Actions were blocked by an account billing/spending
> -limit issue). No real secrets are committed (tfvars gitignored; only the non-secret AWS
> account id + state-bucket name appear). Keep it that way — never commit creds.

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
- [x] **Phase 4 APPLIED + verified** — `infra/cicd` APPLIED: GitHub OIDC provider + IAM role
      `aws-devops-dojo-github-deploy` (trust scoped to `repo:masabni/aws-devops-dojo:ref:refs/
      heads/main`; perms = ECR push to `tasklet` + ECS deploy + PassRole on the execution role).
      Repo var `AWS_DEPLOY_ROLE_ARN` set. `.github/workflows/ci.yml` (PR/non-main:
      typecheck/test/build, `contents:read` token) + `deploy.yml` (manual `workflow_dispatch`:
      OIDC → build SHA-tagged image → push → register task-def → roll service). `/loadtest`
      gated behind `ENABLE_LOADTEST` (off by default). ecs service `ignore_changes =
      [desired_count, task_definition]`. App tests 22/22, 100% coverage; both TF stacks
      `validate` clean. **CI verified GREEN on GitHub (run 28323899990, 21s).** Repo made
      PUBLIC for free Actions minutes. **deploy.yml NOT yet exercised end-to-end** (needs
      `infra/ecs` applied — optional billable dry-run). OIDC role is $0 standing.

## Next actions (in order)

1. **Phase 5 (DynamoDB)** — see `docs/phases/phase-5-dynamodb.md`. Swap the in-memory store
   for DynamoDB (single-table design) + add an ECS *task role* (distinct from the execution
   role) granting the app DynamoDB access.
2. *(Optional, billable)* Exercise `deploy.yml` end-to-end: apply `infra/ecs` → run the
   "Deploy to ECS" workflow manually → confirm OIDC auth + rolling deploy → then
   **`terraform destroy infra/ecs`**.

> **If ending the session: `cd infra/ecs && terraform destroy`** only if you applied it.
> The `infra/cicd` OIDC role is free — leave it up. Nothing billable is running now.

## Known follow-ups / tech debt

- Backend uses deprecated `dynamodb_table` lock arg. Modern TF (1.10+) locks natively via
  S3 (`use_lockfile = true`) — can switch and drop the DynamoDB table later.
- `/loadtest` non-numeric `?ms=` returns `burnedMs: null` (no-op); add `Number.isFinite` guard.
- Gate `/loadtest` behind a flag before it's internet-reachable (Phase 2/3).

## Session-end checklist (cost safety)

- [ ] `terraform destroy` any billable stack started this session (ecs/eks/data/dns).
- [ ] Confirm no ECS services, EKS clusters, NAT gateways, Aurora clusters, or ALBs left running.
- [ ] Update this file.
