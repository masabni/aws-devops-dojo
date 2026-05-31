# infra/ecs — Phase 2 (ECS Fargate + ALB)

ECR repo + ECS Fargate cluster + task def + service + ALB + security groups.
Reads the VPC/subnets from `infra/foundation` via `terraform_remote_state`.

See `docs/phases/phase-2-ecs-fargate.md` for the why + the interview angle.

## Chicken-and-egg: push the image before the service can run it

The ECS service can't pull an image that doesn't exist yet, so apply in two steps:

```bash
terraform init -backend-config=backend.hcl

# 1) Create just the ECR repo first
terraform apply -target=aws_ecr_repository.app

# 2) Build, auth, tag, push the Tasklet image as :v1
terraform output -raw ecr_login_command | bash          # docker login to ECR
REPO=$(terraform output -raw ecr_repository_url)
docker build -t "$REPO:v1" ../../app
docker push "$REPO:v1"

# 3) Now apply the rest (cluster, task def, service, ALB)
terraform apply

# 4) Open the app
open "http://$(terraform output -raw alb_dns_name)/"
```

Refresh the page and watch the footer `instanceId` flip as the ALB round-robins the
two tasks. Stop one task (`aws ecs stop-task ...`) and watch ECS replace it.

To roll out a new build: push a new tag, set `image_tag` in `terraform.tfvars`, `apply`.

**Billable (ALB ~$0.0225/hr + 2 Fargate tasks). `terraform destroy` at session end.**
