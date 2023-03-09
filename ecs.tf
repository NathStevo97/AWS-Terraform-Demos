#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name   = "ecs"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecs-execution-task-role"
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

#----- ECS Services--------

resource "aws_ecs_service" "ckan" {
  name                               = "ckan"
  task_definition                    = aws_ecs_task_definition.ckan.id
  cluster                            = module.ecs.cluster_name
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  platform_version = "1.4.0"
  desired_count                      = 1
  #deployment_minimum_healthy_percent = 0
  #deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_alb_target_group.ckan-http.arn
    container_name   = "ckan"
    container_port   = "5000"
  }

  #health_check_grace_period_seconds = 600

  network_configuration {
    assign_public_ip = true
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.ckan.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.ckan.arn}"
  }

  depends_on = [
    aws_alb_listener.ckan-http,
    #aws_alb_listener.ckan-https,
    aws_alb_listener.solr-http
  ]
}

resource "aws_ecs_service" "datapusher" {
  name            = "datapusher"
  task_definition = "${aws_ecs_task_definition.datapusher.id}"
  cluster         = module.ecs.cluster_name
  desired_count   = 1
  launch_type          = "FARGATE"
  platform_version = "1.4.0"
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
    assign_public_ip = true
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
  platform_version = "1.4.0"
  desired_count   = 1
  wait_for_steady_state = true

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
    assign_public_ip = true
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

/*

### Test Nginx
resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "nginx",
      "image"     : "nginx:1.23.1",
      "cpu"       : 512,
      "memory"    : 2048,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort"      : 80
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "service" {
  name             = "service"
  cluster         = module.ecs.cluster_name
  task_definition  = aws_ecs_task_definition.task.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_alb_target_group.nginx-http.arn
    container_name   = "nginx"
    container_port   = "80"
  }

  network_configuration {
    #assign_public_ip = true
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.elb.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}
*/

#----- ECS Task Definitions--------

resource "aws_ecs_task_definition" "ckan" {
  family                = "ckan"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.datapusher.id}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "cpu": 2048,
    "environment": [
      {
        "name": "POSTGRES_PASSWORD",
        "value": "${aws_db_instance.database.password}"
      },
      {
        "name": "DATASTORE_READONLY_PASSWORD",
        "value": "${var.datastore_readonly_password}"
      },
      {
        "name": "CKAN_SITE_ID",
        "value": "default"
      },
      {
        "name": "CKAN_SITE_URL",
        "value": "http://${aws_alb.application-load-balancer.dns_name}"
      },
      {
        "name": "CKAN_PORT",
        "value": "80"
      },
      {
        "name": "CKAN_SYSADMIN_NAME",
        "value": "${var.ckan_admin}"
      },
      {
        "name": "CKAN_SYSADMIN_PASSWORD",
        "value": "${var.ckan_admin_password}"
      },
      {
        "name": "CKAN_SYSADMIN_EMAIL",
        "value": "ckan@ckan.nstephenson-ckan-dev.link"
      },
      {
        "name": "TZ",
        "value": "UTC"
      },
      {
        "name": "CKAN_SQLALCHEMY_URL",
        "value": "postgresql://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.address}/ckan"
      },
      {
        "name": "CKAN_DATASTORE_WRITE_URL",
        "value": "postgresql://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.address}/datastore"
      },
      {
        "name": "CKAN_DATASTORE_READ_URL",
        "value": "postgresql://datastore_ro:${var.datastore_readonly_password}@${aws_db_instance.database.address}/datastore"
      },
      {
        "name": "CKAN_SOLR_URL",
        "value": "http://${aws_service_discovery_service.solr.name}.${aws_service_discovery_private_dns_namespace.ckan-infrastructure.name}:8983/solr/ckan"
      },
      {
        "name": "CKAN_REDIS_URL",
        "value": "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:6379/1"
      },
      {
        "name": "CKAN_DATAPUSHER_URL",
        "value": "http://${aws_service_discovery_service.datapusher.name}.${aws_service_discovery_private_dns_namespace.ckan-infrastructure.name}:8800"
      },
      {
        "name": "CKAN__STORAGE_PATH",
        "value": "/var/lib/ckan"
      },
      {
        "name": "CKAN_SMTP_SERVER",
        "value": "smtp.ckan.nstephenson-ckan-dev.link:25"
      },
      {
        "name": "CKAN_SMTP_STARTTLS",
        "value": "True"
      },
      {
        "name": "CKAN_SMTP_USER",
        "value": "user"
      },
      {
        "name": "CKAN_SMTP_PASSWORD",
        "value": "pass"
      },
      {
        "name": "CKAN_SMTP_MAIL_FROM",
        "value": "ckan@ckan.nstephenson-ckan-dev.link"
      },
      {
        "name": "CKAN__PLUGINS",
        "value": "odp_theme showcase scheming_datasets image_view text_view recline_view datastore datapusher pdf_view resource_proxy geo_view pages envvars"
      },
      {
        "name": "CKAN__VIEWS__DEFAULT_VIEWS",
        "value": "image_view text_view recline_view pdf_view"
      },
      {
        "name": "CKANEXT_GEOVIEW__OL_VIEWER__FORMATS",
        "value": "wms wfs geojson gml kml arcgis_rest"
      },      {
        "name": "CKAN__HARVEST__MQ__TYPE",
        "value": "redis"
      },
      {
        "name": "CKAN__HARVEST__MQ__HOSTNAME",
        "value": "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
      },
      {
        "name": "CKAN__HARVEST__MQ__PORT",
        "value": "6379"
      },
      {
        "name": "CKAN__HARVEST__MQ__REDIS_DB",
        "value": "1"
      }
    ],
    "mountPoints": [
      {
        "readOnly": false,
        "containerPath": "/var/lib/ckan",
        "sourceVolume": "efs-ckan-storage"
      }
    ],
    "memory": 4096,
    "memoryReservation": 2048,
    "volumesFrom": [],
    "image": "ckan/ckan-base:2.9.7-dev",
    "essential": true,
    "name": "ckan"
    }
  ]
  DEFINITION

  network_mode = "awsvpc"

  volume {
    name      = "efs-ckan-storage"
    /* 
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/mnt/efs/ckan/storage"
      transit_encryption      = "ENABLED"
    }
    */
    #host_path = "/mnt/efs/ckan/storage"
  }
}

resource "aws_ecs_task_definition" "datapusher" {
  family                = "datapusher"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.datapusher.id}",
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
    "memoryReservation": 2048,
    "image": "ckan/ckan-base-datapusher:0.0.19",
    "essential": true,
    "name": "datapusher"
  }
]
  DEFINITION

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.datapusher]
}

resource "aws_ecs_task_definition" "solr" {
  cpu                      = 2048
  memory                   = 4096
  family                = "solr"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.datapusher.id}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
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
    "mountPoints": [
      {
        "containerPath": "/var/solr",
        "sourceVolume": "efs-solr"
      }
    ],
    "memory": 4096,
    "memoryReservation": 2048,
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
    }
    */
    #host_path = "/mnt/efs/solr"
  }

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.solr]

}
