variable "project" {
  type    = string
  default = "aws-devops-dojo"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "app_name" {
  description = "Logical app name; the single-table is named <project>-<app_name>."
  type        = string
  default     = "tasklet"
}
