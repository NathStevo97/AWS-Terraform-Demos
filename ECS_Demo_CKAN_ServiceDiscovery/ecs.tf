resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ckan-test-ecs-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS Cluster
#----- ECS --------
module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.name}-ecs"
}

# CKAN

# Datapusher

resource "aws_ecs_service" "datapusher" {
  name                = "datapusher"
  task_definition     = aws_ecs_task_definition.datapusher.id
  cluster             = module.ecs.cluster_name
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  platform_version    = "1.4.0"

  load_balancer {
    target_group_arn = aws_alb_target_group.datapusher-http.id
    container_name   = "datapusher"
    container_port   = "8800"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.datapusher.arn
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.datapusher.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }
}

resource "aws_ecs_task_definition" "datapusher" {
  family                   = "datapusher"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.datapusher.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8800,
        "hostPort": 8800
      }
    ],
    "cpu": 1024,
    "memory": 2048,
    "memoryReservation": 128,
    "image": "ckan/ckan-base-datapusher:0.0.19",
    "name": "datapusher"
    }
  ]

  DEFINITION

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.datapusher]

}

# Solr

resource "aws_ecs_service" "solr" {
  name                              = "solr"
  task_definition                   = aws_ecs_task_definition.solr.id
  cluster                           = module.ecs.cluster_name
  desired_count                     = 1
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 120
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_alb_target_group.solr-http.id
    container_name   = "solr"
    container_port   = "8983"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.solr.arn
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      aws_security_group.solr.id,
      aws_security_group.all-outbound.id
    ]
  }

  depends_on = [
    aws_alb_listener.solr-http
  ]

}

resource "aws_ecs_task_definition" "solr" {
  family                   = "solr"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.solr.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "hostPort": 8983,
        "protocol": "tcp",
        "containerPort": 8983
      }
    ],
    "cpu": 2048,
    "memory": 4096,
    "memoryReservation": 1024,
    "image": "ckan/ckan-solr:2.9",
    "essential": true,
    "name": "solr"
    }
  ]
  DEFINITION

  volume {
    name = "efs-solr"
    /*
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
    */
    #host_path = "/mnt/efs/solr"
  }

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.solr]

}