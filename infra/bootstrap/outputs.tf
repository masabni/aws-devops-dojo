output "state_bucket" {
  description = "S3 bucket for Terraform remote state. Use this in other stacks' backend config."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "DynamoDB table for Terraform state locking."
  value       = aws_dynamodb_table.locks.name
}

output "region" {
  value = var.region
}
