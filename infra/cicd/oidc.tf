# ============================================================================
# Phase 4 — GitHub Actions → AWS via OIDC (no long-lived access keys)
# ============================================================================
# Three pieces:
#   1) an OIDC identity provider so AWS trusts GitHub-issued tokens,
#   2) a role GitHub can assume (trust policy = "who"),
#   3) a permission policy on that role (= "what it may do": ECR push + ECS deploy).
# GitHub Actions presents a short-lived OIDC token, STS swaps it for temporary
# credentials. Nothing static is ever stored in the repo.

# (1) Tell AWS to trust tokens issued by GitHub's OIDC provider.
# NOTE: only ONE provider per URL can exist per account. If you already created a
# GitHub OIDC provider for another project, import it instead of re-creating it:
#   terraform import aws_iam_openid_connect_provider.github \
#     arn:aws:iam::<account>:oidc-provider/token.actions.githubusercontent.com
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"] # the 'aud' our workflows request
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# (2) Trust policy — WHO may assume this role.
# AssumeRoleWithWebIdentity, federated to the provider above, gated on:
#   - aud == sts.amazonaws.com (the token was minted for AWS), and
#   - sub == repo:<owner>/<repo>:ref:refs/heads/<branch> (right repo + branch).
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_sub]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.project}-github-deploy"
  description        = "Assumed by GitHub Actions (OIDC) to push images to ECR and deploy to ECS."
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# (3) Permission policy — WHAT the role may do. Least-privilege, scoped to our repo/cluster.
data "aws_iam_policy_document" "deploy" {
  # ECR auth token is account-wide and cannot be resource-scoped.
  statement {
    sid       = "EcrAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Push (and pull, for cache) image layers — to the tasklet repo ONLY.
  statement {
    sid = "EcrPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [local.ecr_repo_arn]
  }

  # Registering a new task-def revision and reading task defs don't support
  # resource-level permissions in IAM, so these must be "*".
  statement {
    sid       = "EcsTaskDef"
    actions   = ["ecs:RegisterTaskDefinition", "ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  # Roll the service onto the new revision — scoped to our service in our cluster.
  statement {
    sid       = "EcsDeploy"
    actions   = ["ecs:UpdateService", "ecs:DescribeServices"]
    resources = [local.ecs_service_arn]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [local.ecs_cluster_arn]
    }
  }

  # The new task-def revision references the ECS execution role, so the deployer must
  # be allowed to pass THAT role — and only to ECS. (Phase 5 adds a task role here too.)
  statement {
    sid       = "PassExecutionRole"
    actions   = ["iam:PassRole"]
    resources = [local.execution_role_arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "ecr-push-ecs-deploy"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}
