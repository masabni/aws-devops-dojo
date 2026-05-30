terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # NOTE: this stack uses LOCAL state on purpose. It's the chicken-and-egg stack that
  # *creates* the S3 bucket + DynamoDB lock table that every other stack uses as their
  # remote backend. Commit its tiny terraform.tfstate is fine, or keep it local.
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}
