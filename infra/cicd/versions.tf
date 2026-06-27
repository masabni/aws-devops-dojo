terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Used only to fetch GitHub's current OIDC TLS thumbprint at plan time, so we
    # never hard-code a fingerprint that can rotate out from under us.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  # Remote state in the S3 bucket created by infra/bootstrap.
  # Init with: terraform init -backend-config=backend.hcl
  backend "s3" {
    key = "cicd/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Stack     = "cicd"
    }
  }
}
