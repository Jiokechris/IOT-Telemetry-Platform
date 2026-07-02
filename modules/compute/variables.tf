variable "environment" {
  type = string
}

variable "private_subnet_id" {
  type        = string
  description = "The isolated private subnet where containers will run"
}

variable "app_security_group_id" {
  type        = string
  description = "The security group badge passed from the app_tier module"
}

variable "redis_endpoint" {
  type        = string
  description = "The address of our Redis cache so the app can establish an idempotency layer"
}