# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-06-28 (Phase 5 DynamoDB DONE + verified live; ecs BILLABLE & running)

## Current phase

**Phase 5 (DynamoDB) DONE and verified live.** `infra/data` (on-demand table
`aws-devops-dojo-tasklet`, PITR) applied — $0. App `DynamoStore` + `createStore` factory
(`STORE_BACKEND=dynamodb`). `infra/ecs` task role (least-priv DynamoDB on the table) +
task-def env applied; `infra/cicd` PassRole extended to the task role. Code on `main`
(`2161ace`), deploy pipeline rolled the service to revision `:4`. **Verified:** POST via ALB
landed in DynamoDB (count 1→2) and 6 reads returned an identical list across both tasks —
the Phase 2 per-task inconsistency is gone. Next: **Phase 6 (EKS)**.

> ⚠️ **`infra/ecs` is BILLABLE and running right now** (ALB + 2 Fargate tasks). Destroy it at
> session end: `cd infra/ecs && terraform destroy`. The DynamoDB table (`infra/data`) is ~$0
> and can stay up — your tasks persist there for next session.

> ℹ️ **Repo is now PUBLIC** (`masabni/aws-devops-dojo`). Changed from private so GitHub
> Actions minutes are free (private-repo Actions were blocked by an account billing/spending
> -limit issue). No real secrets are committed (tfvars gitignored; only the non-secret AWS
> account id + state-bucket name appear). Keep it that way — never commit creds.

> ⚠️ **`infra/ecs` is BILLABLE and currently UP** (ALB + 2 Fargate tasks on rev `:4`, now
> DynamoDB-backed). `cd infra/ecs && terraform destroy` at session end. Bootstrap, foundation,
> cicd (OIDC role), and data (DynamoDB table) are all ~$0 and stay up.

## Environment (live)

- AWS account: `850896627732`, user `masabni`, region `eu-central-1`. Terraform v1.15.5.
- Remote state bucket: `aws-devops-dojo-tfstate-850896627732`; lock table: `aws-devops-dojo-tf-locks`.
- Budget alarm: $20/mo → ahmadmasabni@gmail.com (50% / 90% actual, 100% forecast).
- **VPC:** `vpc-0d19b613ce741f0f0` (`10.20.0.0/16`), NAT **disabled** (cost-safe).
  - Public subnets: `subnet-0374cd6a7b3205d80`, `subnet-0283735914e7229ab`.
  - Private subnets: `subnet-01fbbde296655135d`, `subnet-04981791c60efbb3b`.
- **ECS / autoscaling (Phase 2+3+5): UP & BILLABLE.** cluster + service
  `aws-devops-dojo-tasklet`, 2 Fargate tasks (256/512) on task-def rev `:4` (image built by
  the deploy pipeline, `STORE_BACKEND=dynamodb`), internet-facing ALB
  `aws-devops-dojo-tasklet-1161158689.eu-central-1.elb.amazonaws.com`, ECR `…/tasklet`,
  Application Auto Scaling (min 2 / max 6, CPU 50%). Service `ignore_changes =
  [desired_count, task_definition]` (autoscaling owns count, CI owns image). **Destroy at
  session end.**
- **DynamoDB (Phase 5): UP, ~$0.** Table `aws-devops-dojo-tasklet` (on-demand, PITR,
  `PK = TASK#<id>`). The app's task role grants GetItem/PutItem/DeleteItem/Scan on it only.
  Tasks created via the app persist here across sessions. Safe to leave up.

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
      PUBLIC for free Actions minutes. OIDC role is $0 standing. **deploy.yml later exercised
      end-to-end in Phase 5 (rolled the service to rev :4) — it works.**
- [x] **Phase 5 APPLIED + verified** — `infra/data` DynamoDB table (on-demand, PITR). App
      `DynamoStore` (SDK v3 DocumentClient) + `createStore` factory (`STORE_BACKEND`). `infra/ecs`
      task role (least-priv DynamoDB on the table ARN) + task-def env (`STORE_BACKEND=dynamodb`,
      `TASKS_TABLE_NAME`, `AWS_REGION`); `infra/cicd` PassRole extended to the task role. 32
      tests, 100% coverage; 0 prod vulns. Deploy pipeline rolled service to rev `:4`. **Verified
      live:** POST via ALB → DynamoDB count 1→2; 6 reads identical across both tasks (shared,
      durable state — Phase 2 inconsistency gone).

## Next actions (in order)

1. **If ending the session: `cd infra/ecs && terraform destroy`** (billable ALB + tasks).
   Leave `infra/data` (DynamoDB) up — ~$0 and your tasks persist there.
2. **Phase 6 (EKS)** — see `docs/phases/phase-6-eks.md`. Deploy the SAME image to Kubernetes
   and compare ECS vs EKS hands-on. ⚠️ EKS control plane (~$0.10/hr) + nodes are BILLABLE —
   destroy same session.

## Known follow-ups / tech debt

- Backend uses deprecated `dynamodb_table` lock arg. Modern TF (1.10+) locks natively via
  S3 (`use_lockfile = true`) — can switch and drop the DynamoDB table later.
- `/loadtest` non-numeric `?ms=` returns `burnedMs: null` (no-op); add `Number.isFinite` guard.
  (Lower priority now — `/loadtest` is gated off by default behind `ENABLE_LOADTEST` since Phase 4.)
- `DynamoStore.list()` uses Scan with no pagination (1 MB cap) and `toggle()` is a non-atomic
  read-modify-write — both fine at dojo scale, documented in-code; revisit if data grows.

## Session-end checklist (cost safety)

- [ ] `terraform destroy` any billable stack started this session (ecs/eks/data/dns).
- [ ] Confirm no ECS services, EKS clusters, NAT gateways, Aurora clusters, or ALBs left running.
- [ ] Update this file.
