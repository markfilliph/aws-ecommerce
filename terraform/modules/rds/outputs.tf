output "endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
}

output "port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.main.port
}

output "security_group_id" {
  description = "The ID of the security group protecting the RDS instance"
  value       = aws_security_group.rds.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.rds.arn
}
