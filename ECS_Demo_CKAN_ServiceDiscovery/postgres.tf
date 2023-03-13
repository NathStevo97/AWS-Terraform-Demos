

resource "aws_db_option_group" "option_group" {
  engine_name          = "postgres"
  major_engine_version = "11"
}

resource "aws_db_parameter_group" "parameter_group" {
  family = "postgres11"
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "postgres"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_db_instance" "database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.13"
  instance_class       = "db.t2.micro"
  db_name              = var.rds_database_name
  identifier           = "ckan"
  username             = var.rds_username
  password             = var.rds_password
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  port = 5432
  option_group_name    = aws_db_option_group.option_group.name
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [
    #aws_security_group.database.id,
    #aws_security_group.administrative.id,
    #aws_security_group.all-outbound.id
    aws_security_group.rds.id
  ]
  final_snapshot_identifier = "dbfinalsnapshot"
  skip_final_snapshot       = true
  publicly_accessible       = true
}

# dns

/*
resource "aws_route53_record" "postgres" {
  zone_id = var.hosted_zone_id
  name    = "db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds.db_instance_address]
}
*/
# security group
resource "aws_security_group" "rds" {
  name   = "${var.name}-postgres"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.name}-postgres" }
}

# rules
resource "aws_security_group_rule" "cidr" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["86.128.120.245/32", var.cidr]
}




# Postgres - Create Role
#CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD 'datastore_ro_password';

resource "postgresql_role" "datastore_ro" {
  provider = "postgresql.ckan-datastore"
  name = "datastore_ro"
  login = true
  password = var.rds_readonly_password
  superuser = false
  create_database = false
  create_role = false
}


# CREATE DATABASE datastore OWNER ckan ENCODING 'utf-8';
# Postgres - Create Database
resource "postgresql_database" "datastore" {
  name = "datastore"
  owner = "ckan_default"
  allow_connections = true
  encoding = "UTF8"
}
