output "github_actions_role_arn" {
  description = "Set this as the GitHub repo variable AWS_DEPLOY_ROLE_ARN (used by deploy.yml)."
  value       = aws_iam_role.github_deploy.arn
}

output "ecr_registry" {
  description = "The ECR registry host the deploy workflow pushes to."
  value       = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
