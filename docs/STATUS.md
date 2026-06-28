# STATUS — where we are right now

> Single source of truth for progress. Update this at the end of every session.

**Last updated:** 2026-06-29 (Phase 5 DONE; ecs DESTROYED — $0 standing; Phase 6 EKS planned)

## Current phase

**Phase 5 (DynamoDB) DONE and verified live; `infra/ecs` DESTROYED at session end.**
Phase 6 (EKS) is **planned but not yet built** — decisions locked below.

- Phase 5 recap: `infra/data` DynamoDB table applied ($0). App `DynamoStore` + `createStore`
  factory (`STORE_BACKEND=dynamodb`). `infra/ecs` task role + task-def env; `infra/cicd`
  PassRole extended to the task role. Verified live (POST via ALB → DynamoDB; reads consistent
  across tasks). Code on `main` (`2161ace`).
- **Phase 6 decisions (locked):** compute = **EKS on Fargate** (no nodes; Fargate profiles;
  parallels ECS Fargate — the learning goal). Exposure = **ALB Ingress via the AWS Load
  Balancer Controller**. IRSA for DynamoDB (the EKS parallel to the ECS task role).
  Quirks to handle: patch CoreDNS to run on Fargate (kube-system Fargate profile), ALB
  `target-type: ip`, LB Controller + its own IRSA.
- **Phase 6 next step (build while $0, apply in one focused billable push, destroy same day):**
  write `infra/eks/` Terraform (cluster + Fargate profiles + OIDC/IRSA + LB Controller IAM)
  + Helm install + k8s manifests (Deployment 2 replicas, Service, Ingress→ALB, probes →
  `/healthz` `/readyz`), validate, THEN apply → deploy → verify → `terraform destroy`.

> ✅ **Nothing billable running.** `infra/ecs` torn down (verified: 0 ALBs/ECS clusters/ECR
> repos/NAT GWs). Bootstrap, foundation, cicd (OIDC role), and **data (DynamoDB table
> `aws-devops-dojo-tasklet`, holds your tasks)** stay up at ~$0.
> ⚠️ **Phase 6 EKS is the priciest phase: control plane ~$0.10/hr even idle — apply and
> `terraform destroy` the SAME session.**

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
- **ECS / autoscaling (Phase 2+3+5): DESTROYED — not running.** Code in `infra/ecs/`
  (committed). Re-apply recreates cluster + service `aws-devops-dojo-tasklet` (2 Fargate
  tasks, 256/512, `STORE_BACKEND=dynamodb`), internet-facing ALB, ECR `…/tasklet`, task +
  execution roles, Application Auto Scaling (min 2 / max 6, CPU 50%). Re-apply is two-step
  (ECR target → build/push image → full apply) since `force_delete` removed the ECR repo.
  ALB DNS recreated fresh each apply. **BILLABLE when up.**
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

1. **Phase 6 (EKS) — build phase (FREE, do first):** write `infra/eks/` Terraform for the
   chosen design (EKS on **Fargate** + **ALB Ingress via LB Controller** + **IRSA** for
   DynamoDB). Pieces: EKS cluster (public endpoint, public subnets); Fargate profiles for
   `kube-system` (CoreDNS) + the app namespace; OIDC provider; IRSA roles for (a) the app
   (DynamoDB) and (b) the AWS Load Balancer Controller; Helm install of the LB Controller;
   k8s manifests (namespace, IRSA-annotated SA, Deployment 2 replicas, Service,
   Ingress→ALB `target-type: ip`, probes → `/healthz` `/readyz`). Patch CoreDNS to run on
   Fargate. `terraform validate` + commit while $0.
2. **Phase 6 — billable push (one session):** apply `infra/eks` → install controller → apply
   manifests → verify app via the ALB + DynamoDB shared state from EKS → **`terraform destroy`
   the SAME session** (control plane ~$0.10/hr even idle).
3. Then Phase 7 (Aurora + "which DB when").

> See `docs/phases/phase-6-eks.md` for the interview angle (ECS vs EKS, IRSA vs task roles,
> k8s probes ↔ ALB health checks).

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
