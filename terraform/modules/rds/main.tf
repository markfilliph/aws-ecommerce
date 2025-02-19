resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-${var.identifier}-subnet-group"
  description = "Database subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.environment}-${var.identifier}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-${var.identifier}-sg"
  description = "Security group for ${var.identifier} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  tags = {
    Name        = "${var.environment}-${var.identifier}-sg"
    Environment = var.environment
  }
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS database encryption"
  deletion_window_in_days = 7
  enable_key_rotation    = true

  tags = {
    Name        = "${var.environment}-${var.identifier}-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.environment}-${var.identifier}-kms"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-${var.identifier}-pg"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-${var.identifier}"

  engine            = "postgres"
  engine_version    = "14"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 5432

  multi_az               = var.environment == "prod" ? true : false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  storage_encrypted = true
  kms_key_id       = aws_kms_key.rds.arn

  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  auto_minor_version_upgrade = true
  allow_major_version_upgrade = false
  apply_immediately          = var.environment != "prod"

  skip_final_snapshot = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.environment}-${var.identifier}-final-snapshot" : null

  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  deletion_protection = var.environment == "prod"

  tags = {
    Name        = "${var.environment}-${var.identifier}"
    Environment = var.environment
  }
}
