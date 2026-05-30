variable "project" {
  description = "Project name, used to prefix resources."
  type        = string
  default     = "aws-devops-dojo"
}

variable "region" {
  description = "AWS region for all dojo resources."
  type        = string
  default     = "eu-central-1"
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform remote state. Add a suffix (e.g. your account id) to keep it unique."
  type        = string
  # Example: "aws-devops-dojo-tfstate-123456789012"
}

variable "budget_monthly_usd" {
  description = "Monthly cost budget in USD. You get alerted as actual + forecast cross thresholds."
  type        = number
  default     = 20
}

variable "budget_alert_email" {
  description = "Email address that receives budget alerts."
  type        = string
}
