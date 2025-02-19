resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.environment}-${var.identifier}-subnet-group"
  description = "Subnet group for ${var.identifier} ElastiCache cluster"
  subnet_ids  = var.subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "${var.environment}-${var.identifier}-redis-sg"
  description = "Security group for ${var.identifier} Redis cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.identifier}-redis-sg"
    Environment = var.environment
  }
}

resource "aws_elasticache_parameter_group" "main" {
  family = "redis7"
  name   = "${var.environment}-${var.identifier}-params"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.environment}-${var.identifier}"
  replication_group_description = "Redis cluster for ${var.identifier}"
  
  node_type            = var.node_type
  port                = 6379
  parameter_group_name = aws_elasticache_parameter_group.main.name
  
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled          = var.multi_az_enabled
  
  num_cache_clusters = var.num_cache_clusters

  engine               = "redis"
  engine_version      = "7.0"
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  auto_minor_version_upgrade = true

  apply_immediately = var.environment != "prod"

  tags = {
    Name        = "${var.environment}-${var.identifier}"
    Environment = var.environment
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "${var.environment}-${var.identifier}-cache-cpu"
  alarm_description   = "Redis cluster CPU utilization"
  namespace           = "AWS/ElastiCache"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  period             = "300"
  statistic          = "Average"
  threshold          = "75"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.main.id
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = {
    Name        = "${var.environment}-${var.identifier}-cpu-alarm"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  alarm_name          = "${var.environment}-${var.identifier}-cache-memory"
  alarm_description   = "Redis cluster memory utilization"
  namespace           = "AWS/ElastiCache"
  metric_name         = "DatabaseMemoryUsagePercentage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.main.id
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = {
    Name        = "${var.environment}-${var.identifier}-memory-alarm"
    Environment = var.environment
  }
}
