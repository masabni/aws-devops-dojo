output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnets — where dojo Fargate tasks + ALBs live (NAT-free, cost-safe)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnets — for Aurora and anything that shouldn't be internet-reachable."
  value       = aws_subnet.private[*].id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
