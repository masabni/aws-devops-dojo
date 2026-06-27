variable "project" {
  type    = string
  default = "aws-devops-dojo"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "state_bucket" {
  description = "S3 bucket holding remote state (created by infra/bootstrap)."
  type        = string
}

variable "app_name" {
  description = "Must match the ecs stack's app_name — used to scope ECR push + the task family/cluster/service this role may touch."
  type        = string
  default     = "tasklet"
}

# ---- Who is allowed to assume the deploy role (the OIDC trust 'sub' condition) ----
variable "github_owner" {
  description = "GitHub org/user that owns the repo (the 'owner' in owner/repo)."
  type        = string
  default     = "masabni"
}

variable "github_repo" {
  description = "GitHub repository name that may assume the deploy role."
  type        = string
  default     = "aws-devops-dojo"
}

variable "deploy_branch" {
  description = "Only workflow runs on this branch can assume the role. Tightens the OIDC trust to refs/heads/<this>."
  type        = string
  default     = "main"
}
