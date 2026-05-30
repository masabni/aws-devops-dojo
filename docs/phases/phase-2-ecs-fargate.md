# Phase 2 — ECS Fargate + ALB

**Goal:** push the Tasklet image to ECR and run it on ECS Fargate behind an Application
Load Balancer, reachable on the public internet.

## What we'll build (`infra/ecs/`)

- **ECR repository** for the `tasklet` image (with a lifecycle policy to expire old tags).
- **ECS cluster** (Fargate — no EC2 to manage).
- **Task definition**: one container, port 3000, CPU/memory sized small (256/512),
  `INSTANCE_ID` from ECS metadata, log group in CloudWatch.
- **ECS service**: desired count 2, in the foundation **public** subnets (public IP, no NAT),
  registered to an ALB target group.
- **ALB**: internet-facing, listener on :80, target group health check → `/healthz`.
- **Security groups**: ALB allows :80 from the world; task SG allows :3000 only from the ALB SG.

## Steps

1. `aws ecr create-repository` (or via TF) → build → tag → `docker push`.
2. `terraform apply` the `ecs` stack (references foundation outputs via `terraform_remote_state`).
3. Hit the ALB DNS name → Tasklet UI. Refresh and watch the footer `instanceId` change as
   the ALB round-robins across the two tasks.
4. Kill a task (`aws ecs stop-task`) and watch ECS replace it / ALB drain it.

## Interview angle

- Fargate vs EC2 launch type; why Fargate for this.
- How the ALB health check + target group deregistration delay enable zero-downtime deploys.
- Task role vs execution role (we'll need the execution role to pull from ECR + write logs).
- Why the in-memory store now shows inconsistent data across refreshes → motivates Phase 5.

## Cost note

ALB ~$0.0225/hr + tasks. **Destroy this stack at session end.**
