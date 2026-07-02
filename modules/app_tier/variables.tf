variable "environment" {
  type        = string
  description = "The deployment stage (e.g., prod, staging)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC created by the network module"
}

variable "private_subnet_id" {
  type        = string
  description = "The isolated private subnet ID where Redis and Compute will live"
}