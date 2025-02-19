variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ecommerce-dev"
}

variable "database_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "ecommerceadmin"
}

variable "database_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for ALB HTTPS listener"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "ARN of WAF Web ACL to associate with the ALB"
  type        = string
  default     = null
}

variable "alb_account_id" {
  description = "AWS account ID for ALB service in the current region"
  type        = string
  # US East (N. Virginia) - us-east-1
  default     = "127311923021"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}
