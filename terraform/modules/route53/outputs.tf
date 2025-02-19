output "domain_name" {
  description = "Domain name for the environment"
  value       = aws_route53_record.app.name
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "zone_id" {
  description = "Route53 zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "nameservers" {
  description = "Nameservers for the hosted zone"
  value       = data.aws_route53_zone.main.name_servers
}
