# 1. Define the Logical Cluster Boundary
resource "aws_ecs_cluster" "this" {
  name = "iot-${var.environment}-cluster"
}

# 2. Define the Blueprint for the Container (Namespaces & Cgroups combined)
resource "aws_ecs_task_definition" "telemetry_app" {
  family                   = "iot-${var.environment}-telemetry-task"
  network_mode             = "awsvpc" # Forces the container to use our VPC subnets
  requires_compatibilities = ["FARGATE"]
  
  # --- PILLAR 1: GLOBAL CGROUP ENFORCEMENT ---
  cpu                      = "256"  # 0.25 Cores
  memory                   = "512"  # 512 MB Maximum RAM

  container_definitions = jsonencode([
    {
      name      = "telemetry-ingestor"
      image     = "iot-ingestor:latest" # In Layer 4, our CI/CD will push this automatically
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      # Inject our private Redis endpoint as an environment variable into the container
      environment = [
        { name = "REDIS_ENDPOINT", value = var.redis_endpoint },
        { name = "ENV", value = var.environment }
      ]
    }
  ])
}

# 3. Create the Continuous Service (The Reconciliation Engine)
resource "aws_ecs_service" "telemetry_service" {
  name            = "iot-${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.telemetry_app.arn
  desired_count   = 3 # The engine will continuously maintain 3 running replicas
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.app_security_group_id] # Wearing the security badge!
    assign_public_ip = false                       # Absolute private isolation
  }
}