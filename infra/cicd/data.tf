data "aws_caller_identity" "current" {}

# GitHub's OIDC issuer cert — we read its thumbprint instead of pinning a literal.
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # The ecs stack names everything "<project>-<app_name>" and the ECR repo "<app_name>".
  # We rebuild those ARNs here (by convention) rather than reading the ecs remote state,
  # because the ecs stack is destroyed between sessions — its state outputs may not exist,
  # but this role should persist and stay valid for the next time ecs is applied.
  ecs_name           = "${var.project}-${var.app_name}"
  ecr_repo_arn       = "arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.app_name}"
  ecs_cluster_arn    = "arn:aws:ecs:${var.region}:${local.account_id}:cluster/${local.ecs_name}"
  ecs_service_arn    = "arn:aws:ecs:${var.region}:${local.account_id}:service/${local.ecs_name}/${local.ecs_name}"
  execution_role_arn = "arn:aws:iam::${local.account_id}:role/${local.ecs_name}-execution"

  # OIDC 'sub' claim GitHub sends for a run on our branch. Scoping to this exact value
  # means only workflows from <owner>/<repo> running on <deploy_branch> can assume the role.
  github_sub = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.deploy_branch}"
}
