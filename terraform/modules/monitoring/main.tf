# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ecommerce/${var.environment}/application"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "containers" {
  name              = "/aws/ecommerce/${var.environment}/containers"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Create CloudWatch Alarms for EKS Cluster
resource "aws_cloudwatch_metric_alarm" "cluster_cpu" {
  alarm_name          = "${var.environment}-cluster-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cluster_cpu_utilization"
  namespace           = "ContainerInsights"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Cluster CPU utilization is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_memory" {
  alarm_name          = "${var.environment}-cluster-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cluster_memory_utilization"
  namespace           = "ContainerInsights"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Cluster memory utilization is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
  }
}

# Additional CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.environment}-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "RDS CPU utilization is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_memory" {
  alarm_name          = "${var.environment}-rds-freeable-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "1000000000" # 1GB in bytes
  alarm_description  = "RDS freeable memory is too low"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# Additional CloudWatch Alarms for ElastiCache
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.environment}-redis-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Redis CPU utilization is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.environment}-redis-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Redis memory utilization is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }
}

# Additional CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = "10"
  alarm_description  = "Number of 5XX errors is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  alarm_name          = "${var.environment}-alb-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = "100"
  alarm_description  = "Number of 4XX errors is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Business Metrics CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "daily_revenue_target" {
  alarm_name          = "${var.environment}-daily-revenue-target"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DailyRevenue"
  namespace           = "EcommerceBusiness"
  period             = "86400"
  statistic          = "Sum"
  threshold          = var.daily_revenue_target
  alarm_description  = "Daily revenue is below target"
  alarm_actions      = [aws_sns_topic.business_alerts.arn]

  dimensions = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "order_conversion_rate" {
  alarm_name          = "${var.environment}-order-conversion-rate"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "OrderConversionRate"
  namespace           = "EcommerceBusiness"
  period             = "3600"
  statistic          = "Average"
  threshold          = var.min_order_conversion_rate
  alarm_description  = "Order conversion rate is below minimum threshold"
  alarm_actions      = [aws_sns_topic.business_alerts.arn]

  dimensions = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "average_order_value" {
  alarm_name          = "${var.environment}-average-order-value"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "AverageOrderValue"
  namespace           = "EcommerceBusiness"
  period             = "3600"
  statistic          = "Average"
  threshold          = var.min_average_order_value
  alarm_description  = "Average order value is below minimum threshold"
  alarm_actions      = [aws_sns_topic.business_alerts.arn]

  dimensions = {
    Environment = var.environment
  }
}

# Create CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-ecommerce-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ContainerInsights", "cluster_cpu_utilization", "ClusterName", var.cluster_name],
            [".", "cluster_memory_utilization", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Cluster Resource Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Metrics"
        }
      }
    ]
  })
}

# Create SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-ecommerce-alerts"
  tags = var.tags
}

# Create SNS Topic for Business Alerts
resource "aws_sns_topic" "business_alerts" {
  name = "${var.environment}-ecommerce-business-alerts"
  tags = var.tags
}

# Install Prometheus and Grafana using Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.7.1"

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "50Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
    value = yamlencode([
      {
        job_name = "node-exporter"
        kubernetes_sd_configs = [{
          role = "node"
        }]
        relabel_configs = [
          {
            action = "labelmap"
            regex  = "__meta_kubernetes_node_label_(.+)"
          }
        ]
      },
      {
        job_name = "redis-exporter"
        static_configs = [{
          targets = ["redis-exporter:9121"]
        }]
      }
    ])
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "500m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "2Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "4Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.additionalRuleLabels.domain"
    value = "business"
  }

  set {
    name  = "prometheus.prometheusSpec.rulePath"
    value = "/etc/prometheus/rules"
  }

  set {
    name  = "prometheus.prometheusSpec.ruleSelector.matchLabels.domain"
    value = "business"
  }

  set {
    name  = "alertmanager.config.global.resolve_timeout"
    value = "5m"
  }

  set {
    name  = "alertmanager.config.route.group_by[0]"
    value = "domain"
  }

  set {
    name  = "alertmanager.config.route.group_wait"
    value = "30s"
  }

  set {
    name  = "alertmanager.config.route.group_interval"
    value = "5m"
  }

  set {
    name  = "alertmanager.config.route.repeat_interval"
    value = "12h"
  }

  set {
    name  = "alertmanager.config.receivers[0].name"
    value = "business-team"
  }

  set {
    name  = "alertmanager.config.receivers[0].slack_configs[0].channel"
    value = "#business-alerts"
  }

  set {
    name  = "alertmanager.config.receivers[0].slack_configs[0].api_url"
    value = var.slack_webhook_url
  }
}

# Create Kubernetes namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name        = "monitoring"
      environment = var.environment
    }
  }
}

# Create ServiceMonitor for backend application
resource "kubernetes_manifest" "backend_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "backend"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name" = "backend"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "backend"
        }
      }
      endpoints = [
        {
          port   = "http"
          path   = "/metrics"
          scheme = "http"
        }
      ]
      namespaceSelector = {
        matchNames = [var.environment]
      }
    }
  }
}

# Create Grafana dashboards
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "ecommerce-dashboard.json" = file("${path.module}/dashboards/ecommerce-dashboard.json")
  }
}

# Update Prometheus configuration with business alert rules
resource "kubernetes_config_map" "prometheus_business_rules" {
  metadata {
    name      = "prometheus-business-rules"
    namespace = "monitoring"
  }

  data = {
    "business-alerts.yaml" = file("${path.module}/alert-rules/business-alerts.yaml")
  }
}

# Deploy Redis Exporter
resource "kubernetes_deployment" "redis_exporter" {
  metadata {
    name      = "redis-exporter"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis-exporter"
        }
      }

      spec {
        container {
          name  = "redis-exporter"
          image = "oliver006/redis_exporter:v1.44.0"

          env {
            name  = "REDIS_ADDR"
            value = "redis://${var.redis_endpoint}:6379"
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          port {
            container_port = 9121
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_exporter" {
  metadata {
    name      = "redis-exporter"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "redis-exporter"
    }

    port {
      port        = 9121
      target_port = 9121
    }
  }
}

# Create Secret for PostgreSQL Exporter
resource "kubernetes_secret" "postgres_exporter" {
  metadata {
    name      = "postgres-exporter"
    namespace = "monitoring"
  }

  data = {
    "DATA_SOURCE_NAME" = "postgresql://${var.db_username}:${var.db_password}@${var.db_host}:5432/${var.db_name}?sslmode=require"
  }
}

# Deploy PostgreSQL Exporter
resource "kubernetes_deployment" "postgres_exporter" {
  metadata {
    name      = "postgres-exporter"
    namespace = "monitoring"
    labels = {
      app = "postgres-exporter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres-exporter"
        }
      }

      spec {
        containers {
          name  = "postgres-exporter"
          image = "prometheuscommunity/postgres-exporter:v0.11.1"

          env {
            name = "DATA_SOURCE_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_exporter.metadata[0].name
                key  = "DATA_SOURCE_NAME"
              }
            }
          }

          ports {
            container_port = 9187
            protocol      = "TCP"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9187
            }
            initial_delay_seconds = 30
            timeout_seconds      = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9187
            }
            initial_delay_seconds = 5
            timeout_seconds      = 5
          }
        }
      }
    }
  }
}

# Create Service for PostgreSQL Exporter
resource "kubernetes_service" "postgres_exporter" {
  metadata {
    name      = "postgres-exporter"
    namespace = "monitoring"
    labels = {
      app = "postgres-exporter"
    }
  }

  spec {
    selector = {
      app = "postgres-exporter"
    }

    port {
      port        = 9187
      target_port = 9187
      protocol    = "TCP"
      name        = "metrics"
    }
  }
}

# Create ServiceMonitor for PostgreSQL Exporter
resource "kubernetes_manifest" "postgres_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "postgres-exporter"
      namespace = "monitoring"
      labels = {
        release = "prometheus"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "postgres-exporter"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
        }
      ]
    }
  }
}

# Add PostgreSQL Dashboard to Grafana
resource "kubernetes_config_map" "postgres_dashboard" {
  metadata {
    name      = "postgres-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "postgres-dashboard.json" = <<EOF
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
            "legend": false,
            "tooltip": false,
            "viz": false
          },
          "lineInterpolation": "linear",
          "lineWidth": 1,
          "pointSize": 5,
          "scaleDistribution": {
            "type": "linear"
          },
          "showPoints": "never",
          "spanNulls": false
        },
        "unit": "short"
      }
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false
          },
          "unit": "bytes"
        }
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 2,
      "title": "Database Size",
      "type": "timeseries",
      "targets": [
        {
          "expr": "pg_database_size_bytes{datname=~\"$database\"}",
          "legendFormat": "{{datname}}"
        }
      ]
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false
          },
          "unit": "short"
        }
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "id": 3,
      "title": "Transactions",
      "type": "timeseries",
      "targets": [
        {
          "expr": "rate(pg_stat_database_xact_commit{datname=~\"$database\"}[5m])",
          "legendFormat": "Commits"
        },
        {
          "expr": "rate(pg_stat_database_xact_rollback{datname=~\"$database\"}[5m])",
          "legendFormat": "Rollbacks"
        }
      ]
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false
          },
          "unit": "short"
        }
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "id": 4,
      "title": "Cache Hit Ratio",
      "type": "timeseries",
      "targets": [
        {
          "expr": "pg_stat_database_blks_hit{datname=~\"$database\"} / (pg_stat_database_blks_hit{datname=~\"$database\"} + pg_stat_database_blks_read{datname=~\"$database\"}) * 100",
          "legendFormat": "Cache Hit Ratio"
        }
      ]
    }
  ],
  "refresh": "30s",
  "schemaVersion": 38,
  "style": "dark",
  "tags": ["postgresql"],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "All",
          "value": "$__all"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "prometheus"
        },
        "definition": "label_values(pg_stat_database_size{}, datname)",
        "hide": 0,
        "includeAll": true,
        "label": "Database",
        "multi": false,
        "name": "database",
        "options": [],
        "query": {
          "query": "label_values(pg_stat_database_size{}, datname)",
          "refId": "StandardVariableQuery"
        },
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "type": "query"
      }
    ]
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "browser",
  "title": "PostgreSQL Overview",
  "version": 0
}
EOF
  }
}

# Fluent Bit IAM Role
resource "aws_iam_role" "fluent_bit" {
  name = "${var.environment}-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:fluent-bit"
          }
        }
      }
    ]
  })
}

# Fluent Bit IAM Policy
resource "aws_iam_role_policy" "fluent_bit" {
  name = "${var.environment}-fluent-bit-policy"
  role = aws_iam_role.fluent_bit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.cluster_name}/*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.cluster_name}/*:log-stream:*"
        ]
      }
    ]
  })
}

# Fluent Bit Kubernetes Service Account
resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn
    }
  }
}

# Fluent Bit ConfigMap
resource "kubernetes_config_map" "fluent_bit" {
  metadata {
    name      = "fluent-bit-config"
    namespace = "kube-system"
  }

  data = {
    "fluent-bit.conf" = <<EOF
[SERVICE]
    Flush         1
    Log_Level     info
    Daemon        off
    Parsers_File  parsers.conf

[INPUT]
    Name              tail
    Tag               kube.*
    Path              /var/log/containers/*.log
    Parser            docker
    DB                /var/log/flb_kube.db
    Mem_Buf_Limit     5MB
    Skip_Long_Lines   On
    Refresh_Interval  10

[FILTER]
    Name                kubernetes
    Match               kube.*
    Kube_URL           https://kubernetes.default.svc:443
    Kube_CA_File       /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Kube_Token_File    /var/run/secrets/kubernetes.io/serviceaccount/token
    Merge_Log          On
    K8S-Logging.Parser On
    K8S-Logging.Exclude On

[OUTPUT]
    Name                cloudwatch
    Match               *
    region              ${var.aws_region}
    log_group_name      /aws/eks/${var.cluster_name}/containers
    log_stream_prefix   ${var.environment}-
    auto_create_group   true
    retry_limit         2
EOF

    "parsers.conf" = <<EOF
[PARSER]
    Name        docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Time_Keep   On
EOF
  }
}

# Fluent Bit DaemonSet
resource "kubernetes_daemonset" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = "kube-system"
    labels = {
      "k8s-app" = "fluent-bit"
    }
  }

  spec {
    selector {
      match_labels = {
        "k8s-app" = "fluent-bit"
      }
    }

    template {
      metadata {
        labels = {
          "k8s-app" = "fluent-bit"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.fluent_bit.metadata[0].name
        containers {
          name  = "fluent-bit"
          image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.31.11"

          volume_mounts {
            name       = "fluentbitconfig"
            mount_path = "/fluent-bit/etc/"
          }

          volume_mounts {
            name       = "varlog"
            mount_path = "/var/log"
          }

          volume_mounts {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          volume_mounts {
            name       = "runlogjournal"
            mount_path = "/run/log/journal"
            read_only  = true
          }

          resources {
            limits = {
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }
        }

        volumes {
          name = "fluentbitconfig"
          config_map {
            name = kubernetes_config_map.fluent_bit.metadata[0].name
          }
        }

        volumes {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volumes {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volumes {
          name = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}
