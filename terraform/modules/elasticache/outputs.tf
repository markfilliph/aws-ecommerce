output "primary_endpoint" {
  description = "Address of the endpoint for the primary node in the replication group"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Address of the endpoint for the reader node in the replication group"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "Port number on which the cache accepts connections"
  value       = aws_elasticache_replication_group.main.port
}

output "security_group_id" {
  description = "ID of the security group protecting the Redis cluster"
  value       = aws_security_group.redis.id
}

output "replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.id
}
