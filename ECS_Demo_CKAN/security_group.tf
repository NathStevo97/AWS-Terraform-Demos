resource "aws_security_group" "elb" {
  name        = "elb"
  description = "allow http/s from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "allow from ECS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "all-outbound" {
  name        = "all-outbound"
  description = "allow to anywhere"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "allow from ELB"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "database" {
  name        = "database"
  description = "allow from ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "administrative" {
  name        = "administrative"
  description = "all traffic from admin ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "ckan" {
  name        = "ckan"
  description = "allow from elb/datapusher"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "datapusher" {
  name        = "datapusher"
  description = "allow from elb/ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "solr" {
  name        = "solr"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}