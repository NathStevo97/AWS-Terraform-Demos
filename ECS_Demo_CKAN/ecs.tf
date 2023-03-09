#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name   = "ecs"
}


#----- ECS Services--------


resource "aws_ecs_service" "datapusher" {
  name            = "datapusher"
  task_definition = "${aws_ecs_task_definition.datapusher.id}"
  cluster         = module.ecs.cluster_name
  desired_count   = 1
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"

  load_balancer {
    target_group_arn = aws_alb_target_group.datapusher-http.arn
    container_name   = "datapusher"
    container_port   = "8800"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.datapusher.arn
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      aws_security_group.datapusher.id,
      aws_security_group.all-outbound.id
    ]
  }

}

resource "aws_ecs_service" "solr" {
  name            = "solr"
  task_definition = aws_ecs_task_definition.solr.id
  cluster         = module.ecs.cluster_name
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count   = 1

  #health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_alb_target_group.solr-http.arn
    container_name   = "solr"
    container_port   = "8983"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.solr.arn}"
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.solr.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

  depends_on = [
    aws_alb_listener.solr-http
  ]

}

#----- ECS Task Definitions--------


resource "aws_ecs_task_definition" "datapusher" {
  family                = "datapusher"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<DEFINITION
  [
  {
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8800,
        "hostPort": 8800
      }
    ],
    "cpu": 1024,
    "environment": [],
    "mountPoints": [],
    "memory": 2048,
    "memoryReservation": 2048,
    "volumesFrom": [],
    "image": "ckan/ckan-base-datapusher:0.0.19",
    "essential": true,
    "name": "datapusher"
  }
]
  DEFINITION

  network_mode = "awsvpc"

  #depends_on = [aws_cloudwatch_log_group.datapusher]
}

resource "aws_ecs_task_definition" "solr" {
  cpu                      = 2048
  memory                   = 4096
  family                = "solr"
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<DEFINITION
  [
  {
    "dnsSearchDomains": null,
    "portMappings": [
      {
        "hostPort": 8983,
        "protocol": "tcp",
        "containerPort": 8983
      }
    ],
    "cpu": 2048,
    "environment": [],
    "mountPoints": [],
    "memory": 4096,
    "memoryReservation": 512,
    "volumesFrom": [],
    "image": "ckan/ckan-solr:2.9-solr8",
    "essential": true,
    "name": "solr"
    }
  ]
  DEFINITION

  volume {
    name      = "efs-solr"
    /*
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/mnt/efs/solr"
      transit_encryption      = "ENABLED"
    }
    */
    #host_path = "/mnt/efs/solr"
  }

  network_mode = "awsvpc"

  #depends_on = [aws_cloudwatch_log_group.solr]

}