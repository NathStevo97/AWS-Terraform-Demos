output "load_balancer_dns_name" {
  value = aws_alb.application-load-balancer.dns_name
}

output "database_address" {
  value = aws_db_instance.database.address
}

output "elasticache_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "datapusher_service" {
  value = aws_service_discovery_service.datapusher.name
}

output "service_discovery_private_dns" {
  value = aws_service_discovery_private_dns_namespace.ckan-infrastructure.name
}