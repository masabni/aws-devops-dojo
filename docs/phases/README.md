# Phase guides

One guide per phase: what we build, the steps, the interview angle, and the cost note.
Phases 0–1 are done in the scaffold; their summaries live in `CLAUDE.md` and `docs/STATUS.md`.

| Phase | Guide |
|-------|-------|
| 0 | Foundations & cost safety → `infra/bootstrap/README.md`, `infra/foundation/README.md` |
| 1 | Containerize + run locally → done (see repo `README.md`) |
| 2 | [ECS Fargate + ALB](phase-2-ecs-fargate.md) ← **next up** |
| 3 | [Autoscaling + load testing](phase-3-autoscaling.md) |
| 4 | [CI/CD with GitHub Actions](phase-4-cicd-github-actions.md) |
| 5 | [DynamoDB store](phase-5-dynamodb.md) |
| 6 | [EKS](phase-6-eks.md) |
| 7 | [Aurora + which DB when](phase-7-aurora.md) |
| 8 | [DNS / TLS / CDN](phase-8-dns-tls-cdn.md) |
| 9 | [CodePipeline/CodeBuild](phase-9-codepipeline.md) |

Each phase: `terraform apply` → experiment → **`terraform destroy`** → write the matching
`docs/interview/` recap.
