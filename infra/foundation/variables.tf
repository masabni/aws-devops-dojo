variable "project" {
  type    = string
  default = "aws-devops-dojo"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  description = "How many AZs to spread subnets across. 2 is plenty (and required by ALB/EKS)."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "NAT gateways let private subnets reach the internet but cost ~$32/mo each. Keep OFF for the dojo; Fargate tasks can run in PUBLIC subnets with a public IP instead. Turn on only when a lab specifically needs private egress."
  type        = bool
  default     = false
}
