output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the created VPC"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "The ID of the isolated private subnet"
}