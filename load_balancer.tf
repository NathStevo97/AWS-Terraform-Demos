resource "aws_alb" "application-load-balancer" {
  name            = "ckan"
  security_groups = [
    "${aws_security_group.elb.id}",
    #"${aws_security_group.administrative.id}",
    "${aws_security_group.all-outbound.id}"
  ]
  subnets         = module.vpc.public_subnets

}

###### Solr

resource "aws_alb_listener" "solr-http" {
  load_balancer_arn = "${aws_alb.application-load-balancer.id}"
  port              = "8983"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.solr-http.id}"
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.solr-http]
}

resource "aws_alb_target_group" "solr-http" {
  name = "solr"
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  target_type = "ip"
  port = 8983
  deregistration_delay = 90
  
  health_check {
    port = 8983
    path = "/solr"

  }
  
}

##### Datapusher

resource "aws_alb_listener" "datapusher-http" {
  load_balancer_arn = "${aws_alb.application-load-balancer.id}"
  port              = "8800"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.datapusher-http.id}"
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.datapusher-http]
}

resource "aws_alb_target_group" "datapusher-http" {
  name = "datapusher"
  protocol = "HTTP"
  vpc_id = "${module.vpc.vpc_id}"
  target_type = "ip"
  port = 8800
  deregistration_delay = 10
  health_check {
    path = "/"
  }
}

##### CKAN

resource "aws_alb_listener" "ckan-http" {
  load_balancer_arn = "${aws_alb.application-load-balancer.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ckan-http.id}"
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.ckan-http]
}

resource "aws_alb_target_group" "ckan-http" {
  name = "ckan"
  protocol = "HTTP"
  vpc_id = "${module.vpc.vpc_id}"
  target_type = "ip"
  port = 80
  deregistration_delay = 10
  
  health_check {
    path = "/api/3/action/status_show"
  }

}

## Nginx Test
/*
resource "aws_alb_listener" "nginx-http" {
  load_balancer_arn = "${aws_alb.application-load-balancer.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nginx-http.id}"
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.nginx-http]
}

resource "aws_alb_target_group" "nginx-http" {
  name = "nginx"
  protocol = "HTTP"
  vpc_id = "${module.vpc.vpc_id}"
  target_type = "ip"
  port = 80
  deregistration_delay = 10
}
*/
