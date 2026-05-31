variable "project" {
  type    = string
  default = "aws-devops-dojo"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

# ---- Where to read the VPC/subnets from (the foundation stack's remote state) ----
variable "state_bucket" {
  description = "S3 bucket holding remote state (created by infra/bootstrap). Same bucket the foundation stack writes to."
  type        = string
}

# ---- App / container sizing ----
variable "app_name" {
  description = "Logical app name; used for the ECR repo, log group, and resource names."
  type        = string
  default     = "tasklet"
}

variable "container_port" {
  description = "Port the Tasklet app listens on inside the container (PORT env / EXPOSE)."
  type        = number
  default     = 3000
}

variable "image_tag" {
  description = "Which tag of the tasklet image the task definition should run. Bump this to roll out a new build."
  type        = string
  default     = "v1"
}

variable "desired_count" {
  description = "How many Fargate tasks to run. 2 lets us watch the ALB round-robin and survive a task loss."
  type        = number
  default     = 2
}

variable "task_cpu" {
  description = "Fargate task CPU units. 256 = 0.25 vCPU (smallest, cheapest)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory (MiB). 512 is the smallest valid pairing with 256 CPU."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention. Keep short in the dojo to stay near $0."
  type        = number
  default     = 7
}
