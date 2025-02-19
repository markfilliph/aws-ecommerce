variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
}

variable "rds_instance_id" {
  description = "ID of the RDS instance"
  type        = string
}

variable "redis_cluster_id" {
  description = "ID of the Redis cluster"
  type        = string
}

variable "redis_endpoint" {
  description = "Endpoint of the Redis cluster"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Business Metrics Variables
variable "daily_revenue_target" {
  description = "Daily revenue target in USD"
  type        = number
  default     = 10000
}

variable "min_order_conversion_rate" {
  description = "Minimum acceptable order conversion rate percentage"
  type        = number
  default     = 2.5
}

variable "min_average_order_value" {
  description = "Minimum acceptable average order value in USD"
  type        = number
  default     = 50
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for business alerts"
  type        = string
  sensitive   = true
}

# PostgreSQL Database Variables
variable "db_host" {
  description = "PostgreSQL database host"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}
