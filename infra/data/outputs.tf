output "table_name" {
  description = "Set as TASKS_TABLE_NAME on the ECS task; the app's DynamoStore reads/writes here."
  value       = aws_dynamodb_table.app.name
}

output "table_arn" {
  description = "Used by the ECS task role to scope DynamoDB permissions to just this table."
  value       = aws_dynamodb_table.app.arn
}
