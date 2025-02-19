terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket         = "ecommerce-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  environment         = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  environment       = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
  node_desired_size = 2
  node_max_size     = 4
  node_min_size     = 1
  node_instance_types = ["t3.medium"]
}

module "rds" {
  source = "../../modules/rds"

  environment     = var.environment
  identifier      = "ecommerce"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  
  allowed_security_groups = [module.eks.node_security_group_id]
  
  instance_class    = "db.t3.medium"
  allocated_storage = 20
  
  database_name     = "ecommerce"
  database_username = var.database_username
  database_password = var.database_password
  
  backup_retention_period = 7
}

module "elasticache" {
  source = "../../modules/elasticache"

  environment     = var.environment
  identifier     = "ecommerce"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  
  allowed_security_groups = [module.eks.node_security_group_id]
  
  node_type            = "cache.t3.medium"
  num_cache_clusters   = 2
  
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  snapshot_retention_limit = 7
}

module "alb_logs" {
  source = "../../modules/s3"

  environment      = var.environment
  bucket_name      = "${var.environment}-${var.cluster_name}-alb-logs"
  alb_account_id   = var.alb_account_id
  log_retention_days = 30
}

module "waf" {
  source = "../../modules/waf"

  environment        = var.environment
  log_retention_days = 30
  
  tags = {
    Environment = var.environment
    Project     = "ecommerce"
    Terraform   = "true"
  }
}

module "route53" {
  source = "../../modules/route53"

  environment  = var.environment
  domain_name = var.domain_name
  
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "alb" {
  source = "../../modules/alb"

  environment        = var.environment
  name              = "ecommerce"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  
  certificate_arn    = module.route53.certificate_arn
  log_bucket        = module.alb_logs.bucket_name
  
  oidc_provider     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  
  waf_web_acl_arn   = module.waf.web_acl_arn
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  environment            = var.environment
  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  
  aws_region            = var.aws_region
  vpc_id               = module.vpc.vpc_id
  
  alb_controller_role_arn = module.alb.controller_role_arn
  certificate_arn        = var.certificate_arn
  waf_web_acl_arn       = var.waf_web_acl_arn
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment            = var.environment
  aws_region            = var.aws_region
  cluster_name          = module.eks.cluster_name
  alb_arn_suffix        = module.alb.alb_arn_suffix
  grafana_admin_password = var.grafana_admin_password
  
  # Add RDS and Redis variables
  rds_instance_id       = module.rds.instance_id
  redis_cluster_id      = module.elasticache.cluster_id
  redis_endpoint        = module.elasticache.primary_endpoint
  
  tags = {
    Environment = var.environment
    Project     = "ecommerce"
    Terraform   = "true"
  }
}

# Output the cluster endpoint and certificate authority data
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority_data
  sensitive = true
}

# RDS Outputs
output "database_endpoint" {
  value = module.rds.endpoint
}

output "database_name" {
  value = module.rds.db_name
}

# Redis Outputs
output "redis_primary_endpoint" {
  value = module.elasticache.primary_endpoint
}

output "redis_reader_endpoint" {
  value = module.elasticache.reader_endpoint
}

# ALB Outputs
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  value = module.alb.alb_zone_id
}
