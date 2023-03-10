resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 2048
  memory                   = 4096
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "solr",
      "image"     : "ckan/ckan-solr:2.9",
      "cpu"       : 2048,
      "memory"    : 4096,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 8983,
          "hostPort"      : 8983
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "service" {
  name             = "service"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.task.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.subnet.id]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}