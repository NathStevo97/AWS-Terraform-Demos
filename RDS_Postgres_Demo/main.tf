data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "ckan"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "ckan" {
  name       = "ckan"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "ckan"
  }
}

resource "aws_security_group" "rds" {
  name   = "ckan_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["86.128.120.245/32"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ckan_rds"
  }
}

resource "aws_db_parameter_group" "ckan" {
  name   = "ckan"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "ckan" {
  identifier             = "ckan"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.1"
  username               = "ckan_default"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.ckan.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.ckan.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

# Postgres - Create Role
#CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD 'datastore_ro_password';

resource "postgresql_role" "datastore_ro" {
  name = "datastore_ro"
  login = true
  password = var.db_password
  superuser = false
  create_database = false
  create_role = false

  depends_on = [
    aws_db_instance.ckan
  ]
}


# CREATE DATABASE datastore OWNER ckan ENCODING 'utf-8';
# Postgres - Create Database
resource "postgresql_database" "datastore" {
  name = "datastore"
  owner = "ckan_default"
  allow_connections = true
  encoding = "UTF8"

  depends_on = [
    aws_db_instance.ckan
  ]
}
