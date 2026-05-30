# aws-devops-dojo — Claude project guide

This repo is a hands-on AWS DevOps practice ground. The owner holds an AWS Solutions
Architect Associate cert but wants **practical** muscle memory: deploying containers,
CI/CD, autoscaling, load balancing, DNS/TLS, and choosing the right data store.

Any Claude session working here should read this file first, then `README.md` for the
full roadmap, then `docs/STATUS.md` for "what phase are we on right now".

## The goal

Build ONE small app (`Tasklet`) and layer real AWS capabilities onto it, one phase at a
time. Each phase is a self-contained lab you can `apply` → play with → `destroy`.

## Hard rules (do not violate)

1. **Cost safety is non-negotiable.** This runs in a personal AWS account on a small
   budget. ALWAYS end a working session by tearing down billable infra
   (`terraform destroy` in the active stack). NEVER leave EKS control planes, NAT
   gateways, Aurora clusters, ALBs, or running ECS services up overnight. A budget
   alarm is set up in Phase 0 as a backstop — it is not a substitute for destroying.
2. **Never `terraform apply` without the user present and confirming.** Applies cost
   money and are the user's call. Writing/refactoring Terraform is fine; applying is not.
3. **No real secrets in git.** Use `*.tfvars` (gitignored) and AWS SSO/named profiles.
   CI/CD authenticates to AWS via GitHub OIDC — no long-lived access keys.
4. **Smallest correct change.** This is a learning repo; favor clarity over cleverness.
   Comments should explain the *why* / the AWS concept being practiced.

## Decisions locked in (don't relitigate without asking)

| Choice            | Decision                                                |
|-------------------|---------------------------------------------------------|
| App stack         | Node.js + TypeScript + Express, server-rendered Tailwind UI |
| IaC               | Terraform                                               |
| App structure     | One app, built up incrementally (not separate labs)     |
| DNS/CDN           | AWS-native: Route 53 + CloudFront + ACM                 |
| CI/CD             | GitHub Actions first, then replicate in CodePipeline/CodeBuild |
| Container compute | ECS Fargate first, then EKS (same image)                |
| Account           | Personal, small budget, tear down after each session    |

## Repo layout

```
app/        Tasklet — the Node/TS Express demo app (+ tests, Dockerfile)
infra/      Terraform, one stack per concern (bootstrap, foundation, ecs, eks, data, dns, cicd)
.github/    GitHub Actions workflows (CI/CD)
docs/
  specs/      design doc(s)
  phases/     one guide per phase (what we build + the interview angle)
  interview/  interview-style Q&A recap per topic, written from what we actually built
  STATUS.md   the single source of truth for current progress
.claude/
  skills/     helper skills (e.g. resume-session)
  settings.json   project permission allowlist
```

## The 10-phase roadmap

0. **Foundations & cost safety** — budget alarm, Terraform remote state (S3 + DynamoDB lock), VPC, IAM baseline.
1. **Containerize + run locally** — Tasklet app, Dockerfile, run in Docker. ✅ (done in scaffold)
2. **ECS Fargate + ALB** — ECR repo, task def, service behind an Application Load Balancer.
3. **Autoscaling + load testing** — target-tracking scaling, drive `/loadtest`, watch it scale.
4. **CI/CD (GitHub Actions)** — test on PR, build/push to ECR, deploy to ECS via OIDC.
5. **DynamoDB** — swap the in-memory store for a DynamoDB-backed one; single-table design; task IAM role.
6. **EKS** — deploy the same image to Kubernetes; compare ECS vs EKS hands-on.
7. **Aurora + "which DB when"** — Aurora Serverless v2; model the data relationally; write the decision doc.
8. **DNS / TLS / CDN** — register domain, Route 53 hosted zone, ACM cert, CloudFront in front of the ALB.
9. **CodePipeline/CodeBuild** — re-implement the pipeline AWS-natively; compare with GitHub Actions.

## How to resume in a future session

Run the `resume-session` skill (in `.claude/skills/`) or just: read this file →
`docs/STATUS.md` → the `docs/phases/` guide for the current phase → continue.

## Local prerequisites (status at scaffold time)

- Node 24 ✅  ·  npm ✅  ·  Docker ✅  ·  AWS CLI ✅
- **Terraform ❌ not installed** — needed before Phase 0 apply (`brew install terraform`).
- **AWS credentials ❌ invalid** — run `aws configure` / SSO before any Phase 0+ apply.
