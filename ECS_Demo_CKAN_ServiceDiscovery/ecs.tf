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

resource "aws_ecs_service" "ckan" {
  name                = "ckan"
  task_definition     = aws_ecs_task_definition.ckan.id
  cluster             = module.ecs.cluster_name
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  platform_version    = "1.4.0"
  /*
  load_balancer {
    target_group_arn = aws_alb_target_group.ckan-http.id
    container_name   = "ckan"
    container_port   = "5000"
  }
  */

  #health_check_grace_period_seconds = 600

  network_configuration {
    assign_public_ip = true
    subnets = module.vpc.public_subnets
    security_groups = [
      "${aws_security_group.ckan.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.ckan.arn
  }
  /*
  depends_on = [
    aws_alb_listener.ckan-http,
    aws_alb_listener.solr-http
  ]
  */

}

resource "aws_ecs_task_definition" "ckan" {
  family                = "ckan"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
         "awslogs-group": "${aws_cloudwatch_log_group.ckan.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "command": [ "/bin/sh", "sudo chmod 777 -R /var/lib/ckan/" ],
    "cpu": 2048,
    "environment": [
      {
        "name": "POSTGRES_PASSWORD",
        "value": "${aws_db_instance.database.password}"
      },
      {
        "name": "DATASTORE_READONLY_PASSWORD",
        "value": "${var.rds_readonly_password}"
      },
      {
        "name": "CKAN_SITE_ID",
        "value": "default"
      },
      {
        "name": "CKAN_SITE_URL",
        "value": "http://localhost:5000"
      },
      {
        "name": "CKAN_PORT",
        "value": "5000"
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
        "value": "ckan@ckan.nathanstephenson.link"
      },
      {
        "name": "TZ",
        "value": "UTC"
      },
      {
        "name": "CKAN_SQLALCHEMY_URL",
        "value": "postgresql://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.endpoint}/ckan"
      },
      {
        "name": "CKAN_DATASTORE_WRITE_URL",
        "value": "postgresql://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.endpoint}/datastore"
      },
      {
        "name": "CKAN_DATASTORE_READ_URL",
        "value": "postgresql://${var.rds_readonly_user}:${var.rds_readonly_password}@${aws_db_instance.database.endpoint}/datastore"
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
        "value": "smtp.ckan.nathanstephenson.link:25"
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
        "value": "ckan@ckan.nathanstephenson.link"
      },
      {
        "name": "CKAN__PLUGINS",
        "value": "image_view text_view recline_view datastore datapusher resource_proxy envvars"
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
    "memory": 4096,
    "memoryReservation": 512,
    "mountPoints": [
      {
        "readOnly": false,
        "containerPath": "/var/lib/ckan",
        "sourceVolume": "efs-ckan-storage"
      }
    ],
    "image": "ckan/ckan-base:2.9.7",
    "name": "ckan"
    }
  ]
  DEFINITION
  volume {
    name = "efs-ckan-storage"
    #host_path = "/mnt/efs/ckan/storage"
  }

  network_mode = "awsvpc"

  #depends_on = [aws_cloudwatch_log_group.ckan]

}


# Datapusher

resource "aws_ecs_service" "datapusher" {
  name                = "datapusher"
  task_definition     = aws_ecs_task_definition.datapusher.id
  cluster             = module.ecs.cluster_name
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  platform_version    = "1.4.0"
  /*
  load_balancer {
    target_group_arn = aws_alb_target_group.datapusher-http.id
    container_name   = "datapusher"
    container_port   = "8800"
  }
  */

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
  #health_check_grace_period_seconds = 120
  enable_execute_command            = true
  /*
  load_balancer {
    target_group_arn = aws_alb_target_group.solr-http.id
    container_name   = "solr"
    container_port   = "8983"
  }
  */

  service_registries {
    registry_arn = aws_service_discovery_service.solr.arn
  }

  network_configuration {
    assign_public_ip = true
    subnets = module.vpc.public_subnets
    security_groups = [
      aws_security_group.solr.id,
      aws_security_group.all-outbound.id
    ]
  }
  /*
  depends_on = [
    aws_alb_listener.solr-http
  ]
  */

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
    "image": "ckan/ckan-solr:2.9-solr8",
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