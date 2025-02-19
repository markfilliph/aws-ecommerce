variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Name prefix for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of ACM certificate to use with the ALB"
  type        = string
}

variable "log_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "ARN of WAF Web ACL to associate with the ALB"
  type        = string
  default     = null
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm returns to OK state"
  type        = list(string)
  default     = []
}

variable "oidc_provider" {
  description = "OIDC provider URL for EKS cluster (without https://)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for EKS cluster"
  type        = string
}
