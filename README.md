# aws-devops-dojo

A hands-on AWS DevOps practice ground. One small app (**Tasklet**), deployed and
operated across the AWS stack the way a real service would be — to build practical
muscle memory on top of AWS Solutions Architect theory.

**What you practice here:** containers (ECS Fargate → EKS), CI/CD (GitHub Actions →
CodePipeline), autoscaling + load balancing, DynamoDB vs Aurora, and Route 53 +
CloudFront + ACM for DNS/TLS — all provisioned with Terraform.

## Quick start (Phase 1 — local, no AWS needed)

```bash
cd app
npm install
npm test          # 11 tests
npm run dev       # http://localhost:3000
# or run it in Docker:
docker build -t tasklet ./app
docker run --rm -p 3000:3000 tasklet
```

Open http://localhost:3000 — add/toggle/delete tasks. The footer shows which
instance + version served you (handy once we run multiple ECS/EKS replicas).

Endpoints: `/` (UI), `/tasks` (JSON CRUD), `/healthz`, `/readyz`, `/loadtest?ms=200`.

## The roadmap

| Phase | Topic | Status |
|-------|-------|--------|
| 0 | Foundations & cost safety (budget alarm, TF remote state, VPC, IAM) | Terraform written, not applied |
| 1 | Containerize + run locally | ✅ done |
| 2 | ECS Fargate + ALB | stub |
| 3 | Autoscaling + load testing | stub |
| 4 | CI/CD with GitHub Actions | stub |
| 5 | DynamoDB store | stub |
| 6 | EKS | stub |
| 7 | Aurora + "which DB when" | stub |
| 8 | DNS / TLS / CDN (Route 53 + CloudFront) | stub |
| 9 | CodePipeline/CodeBuild | stub |

Per-phase guides live in [`docs/phases/`](docs/phases/). Interview-style recaps live in
[`docs/interview/`](docs/interview/). Current progress is tracked in
[`docs/STATUS.md`](docs/STATUS.md).

## Cost safety

This runs in a personal AWS account on a small budget. **Every session ends with
`terraform destroy`** on the active stack — never leave EKS / NAT / Aurora / ALB
running. Phase 0 sets a monthly budget alarm as a backstop. See `CLAUDE.md` for the
full rules.

## Before you can do Phase 0+

- Install Terraform: `brew install terraform`
- Configure AWS credentials: `aws configure` (or SSO), then `aws sts get-caller-identity`
