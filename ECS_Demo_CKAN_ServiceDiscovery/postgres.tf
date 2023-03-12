resource "aws_db_option_group" "option_group" {
  engine_name          = "postgres"
  major_engine_version = "11"
}

resource "aws_db_parameter_group" "parameter_group" {
  family = "postgres11"
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "postgres"
  subnet_ids = module.vpc.private_subnets
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
    "${aws_security_group.database.id}",
    "${aws_security_group.administrative.id}",
    "${aws_security_group.all-outbound.id}"
  ]
  final_snapshot_identifier = "dbfinalsnapshot"
  skip_final_snapshot       = true
  publicly_accessible       = true
}
/*
module "rds-boostrap" {
  source = "github.com/fvinas/tf_rds_boostrap"

  name = "RDS-BOOSTRAP"

  subnet_id = module.vpc.private_subnets
  security_group_ids = ["${aws_security_group.ecs.id}"]

  endpoint = "${aws_db_instance.database.endpoint}"
  port = "${aws_db_instance.database.port}"
  database = "${aws_db_instance.database.name}"
  master_username = "${aws_db_instance.database.username}"
  master_password = "${var.rds_password}"

  sql_script = "${file("./rds-bootstrap.sql")}"
}
*/