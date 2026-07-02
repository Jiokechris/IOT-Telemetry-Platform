# 2. Refactored Redis Security Group (The Ironclad Door)
resource "aws_security_group" "redis_sg" {
  name        = "iot-${var.environment}-redis-sg"
  description = "Control traffic strictly to the idempotency cache"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    # --- INTERNATIONAL STANDARD TRICK ---
    # Instead of an IP range (cidr_blocks), we reference the App Security Group ID!
    security_groups = [aws_security_group.app_sg.id] 
  }

  # Outbound Rule: Allow Redis to respond to internal requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "iot-${var.environment}-redis-sg"
  }
}

# 2. Deploy a Secure, Private Redis Instance (AWS ElastiCache)
resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = "iot-${var.environment}-redis-subnet-group"
  subnet_ids = [var.private_subnet_id]
}

resource "aws_elasticache_cluster" "idempotency_cache" {
  cluster_id           = "iot-${var.environment}-cache"
  engine               = "redis"
  node_type            = "cache.t4g.micro" # Cost-effective, ARM-powered instance type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnets.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = {
    Name        = "iot-${var.environment}-idempotency-cache"
    Environment = var.environment
  }
}

# 1. The Security Group "Badge" for our Telemetry App Containers
resource "aws_security_group" "app_sg" {
  name        = "iot-${var.environment}-app-sg"
  description = "Security badge for our telemetry app containers"
  vpc_id      = var.vpc_id

  # Apps can talk outbound to the internet via the NAT Gateway to fetch schemas
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iot-${var.environment}-app-sg"
  }
}

