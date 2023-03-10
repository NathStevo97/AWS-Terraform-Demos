resource "aws_db_option_group" "option_group" {
  engine_name = "postgres"
  major_engine_version = "11"
}

resource "aws_db_parameter_group" "parameter_group" {
  family = "postgres11"
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "postgres"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "database" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "11"
  instance_class = "db.t2.micro"
  db_name = "ckan"
  identifier = "ckan"
  username = "ckan_default"
  password = var.database_password
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  option_group_name = aws_db_option_group.option_group.name
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
  final_snapshot_identifier = "dbfinalsnapshot"
  skip_final_snapshot = true
  publicly_accessible = true
}

# security group
resource "aws_security_group" "rds" {
  name   = "${var.name}-postgres"
  vpc_id = var.vpc_id

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
  cidr_blocks       = var.allowed_cidr_blocks
}