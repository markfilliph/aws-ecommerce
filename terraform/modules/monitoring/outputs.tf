output "prometheus_endpoint" {
  description = "Endpoint for Prometheus"
  value       = "http://prometheus-server.monitoring.svc.cluster.local"
}

output "grafana_endpoint" {
  description = "Endpoint for Grafana"
  value       = "http://grafana.monitoring.svc.cluster.local"
}

output "alert_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "cloudwatch_log_groups" {
  description = "Names of the CloudWatch log groups"
  value = {
    application = aws_cloudwatch_log_group.application.name
    containers  = aws_cloudwatch_log_group.containers.name
  }
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
