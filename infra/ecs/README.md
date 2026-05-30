# infra/ecs — Phase 2/3 (stub)

ECR + ECS Fargate cluster + task def + service + ALB + autoscaling.
Written in Phase 2. See `docs/phases/phase-2-ecs-fargate.md` and `phase-3-autoscaling.md`.

References `infra/foundation` outputs via `terraform_remote_state`.

**Billable (ALB + tasks). `terraform destroy` at session end.**
