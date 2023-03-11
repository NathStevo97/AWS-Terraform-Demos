output "load_balancer_dns" {
  value = aws_alb.application-load-balancer.dns_name
}

output "solr_dns" {
  value = "http://${aws_alb.application-load-balancer.dns_name}:8983/solr"
}

output "redis_cluster_address" {
  value = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
}