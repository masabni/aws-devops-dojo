# Phase 4 — CI/CD with GitHub Actions

**Goal:** on every push, run tests; on merge to main, build the image, push to ECR, and
deploy to ECS — with **no static AWS keys** (GitHub OIDC).

## Build
- `infra/cicd/`: a GitHub OIDC identity provider + an IAM role GitHub can assume, scoped
  to ECR push + ECS deploy.
- `.github/workflows/ci.yml`: install → `npm test` → `npm run build` on PRs.
- `.github/workflows/deploy.yml`: on `main`, `aws-actions/configure-aws-credentials`
  (OIDC) → build/push to ECR → render new task def → `aws-actions/amazon-ecs-deploy-task-definition`.

## Interview angle
- Why OIDC over long-lived access keys (no secrets to rotate/leak).
- Pipeline stages: source → test → build → push → deploy; where you'd add approval gates.
- Rolling deploy via ECS, and how the ALB health check gates it.
- Immutable image tags (git SHA) vs `latest`.

## Cost note
Actions minutes are free-tier-ish for a personal repo; the deploy targets the (billable)
ECS stack — **destroy that at session end.**
