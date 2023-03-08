output "load_balancer_dns_name" {
  value = aws_alb.application-load-balancer.dns_name
}