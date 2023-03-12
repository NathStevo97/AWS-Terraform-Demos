output "load_balancer_dns" {
  value = aws_alb.application-load-balancer.dns_name
}

output "private_dns_namespace" {
  value = aws_service_discovery_private_dns_namespace.ckan-infrastructure.id
}

output "service_registries" {
  value = [aws_service_discovery_service.ckan.arn, aws_service_discovery_service.solr.arn, aws_service_discovery_service.datapusher.arn]
}

output "solr_url" {
  value = "http://${aws_alb.application-load-balancer.dns_name}:8983/solr"
}

output "redis_cluster_address" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "database" {
  value = [aws_db_instance.database.address, aws_db_instance.database.endpoint]
}