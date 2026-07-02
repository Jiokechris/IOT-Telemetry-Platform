variable "environment" {
    type        = string
    description = "The environment for the VPC (e.g., dev, staging, prod)."      
}

variable "vpc_cidr" {
  type        = string
  description = "The root private IP range for the entire network"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The IP range for the public load balancer zone"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The IP range for the isolated application tier"
}