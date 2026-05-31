output "ecr_repository_url" {
  description = "Push the Tasklet image here, then bump var.image_tag to deploy it."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public URL of the Tasklet app: http://<this>/"
  value       = aws_lb.main.dns_name
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

# Handy one-liners for the docker push step (Phase 2, step 1).
output "ecr_login_command" {
  description = "Run this to authenticate Docker to ECR before pushing."
  value       = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}
