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

# ---- Phase 3: autoscaling ----
# The scalable target's floor and ceiling. desired_count (above) is only the *starting*
# task count; once autoscaling is attached it owns the number between these bounds.
variable "min_capacity" {
  description = "Minimum tasks autoscaling will ever run. >1 so a single AZ/task failure can't take us to zero."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Ceiling autoscaling can scale out to. Caps the blast radius on cost during a load test."
  type        = number
  default     = 6
}

variable "cpu_target_percent" {
  description = "Target-tracking setpoint: autoscaling adds/removes tasks to keep average CPU near this."
  type        = number
  default     = 50
}

variable "scale_out_cooldown" {
  description = "Seconds to wait after scaling OUT before scaling out again. Short = react fast to load."
  type        = number
  default     = 30
}

variable "scale_in_cooldown" {
  description = "Seconds to wait after scaling IN before scaling in again. Long = avoid flapping when load is bursty."
  type        = number
  default     = 120
}
