resource "aws_lb" "nginx-alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = false

  tags = {
    Name = "nginx-alb"
  }
}

resource "aws_lb_target_group" "nginx-alb" {
  name     = "niginx-alb"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  stickiness {
    type = "lb_cookie"
  }
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "nginx-alb" {
  load_balancer_arn = aws_lb.nginx-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-alb.arn
  }
}