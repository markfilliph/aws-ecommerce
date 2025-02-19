# Get the hosted zone
data "aws_route53_zone" "main" {
  name = var.domain_name
  private_zone = false
}

# Create A record for the application
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.environment == "prod" ? var.domain_name : "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id               = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Create CNAME record for www
resource "aws_route53_record" "www" {
  count = var.environment == "prod" ? 1 : 0

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.domain_name]
}

# Create ACM certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.environment == "prod" ? var.domain_name : "*.${var.domain_name}"
  subject_alternative_names = var.environment == "prod" ? ["*.${var.domain_name}"] : []
  validation_method         = "DNS"

  tags = {
    Environment = var.environment
    Name        = var.environment == "prod" ? var.domain_name : "*.${var.domain_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS records for ACM validation
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# Validate ACM certificate
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
