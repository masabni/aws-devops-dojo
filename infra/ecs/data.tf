data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Pull the VPC + subnet IDs from the foundation stack instead of hard-coding them.
# This is the canonical way to share outputs between Terraform stacks.
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "foundation/terraform.tfstate"
    region = var.region
  }
}

locals {
  name            = "${var.project}-${var.app_name}"
  vpc_id          = data.terraform_remote_state.foundation.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.foundation.outputs.public_subnet_ids
  ecr_repo_url    = aws_ecr_repository.app.repository_url
  container_image = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}
