output "app_security_group_id" {
  value       = aws_security_group.app_sg.id
  description = "The security badge ID that our application containers must wear"
}

output "redis_endpoint" {
  value       = aws_elasticache_cluster.idempotency_cache.cache_nodes[0].address
  description = "The connection string our app needs to talk to the Idempotency Redis cache"
}