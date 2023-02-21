resource "aws_ecs_task_definition" "redis-task" {
  family                   = "ckan"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "redis",
      "image"     : "redis:7.0.8-alpine3.17",
      "cpu"       : 1024,
      "memory"    : 2048,
      "healthCheck": {
        "command": ["CMD", "redis-cli", "-e", "QUIT"]
      },
      "essential" : true
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "redis-service" {
  name             = "redis-service"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.redis-task.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.subnet.id]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}


