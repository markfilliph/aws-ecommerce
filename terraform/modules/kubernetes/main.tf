provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

# Create namespace for AWS Load Balancer Controller
resource "kubernetes_namespace" "aws_load_balancer_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

# Install AWS Load Balancer Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = kubernetes_namespace.aws_load_balancer_controller.metadata[0].name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.alb_controller_role_arn
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
}

# Create namespace for applications
resource "kubernetes_namespace" "applications" {
  metadata {
    name = var.environment
    labels = {
      name        = var.environment
      environment = var.environment
    }
  }
}

# Create default network policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace.applications.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_dns" {
  metadata {
    name      = "allow-dns"
    namespace = kubernetes_namespace.applications.metadata[0].name
  }

  spec {
    pod_selector {}
    
    egress {
      ports {
        port     = 53
        protocol = "UDP"
      }
      ports {
        port     = 53
        protocol = "TCP"
      }
    }

    policy_types = ["Egress"]
  }
}

# Create default ingress class
resource "kubernetes_ingress_class_v1" "alb" {
  metadata {
    name = "alb"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "ingress.k8s.aws/alb"
  }
}

# Create example ingress for the frontend application
resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.applications.metadata[0].name
    annotations = {
      "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"           = "ip"
      "alb.ingress.kubernetes.io/listen-ports"          = jsonencode([{"HTTP" = 80}, {"HTTPS" = 443}])
      "alb.ingress.kubernetes.io/ssl-redirect"          = "443"
      "alb.ingress.kubernetes.io/healthcheck-path"      = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol"  = "HTTP"
      "alb.ingress.kubernetes.io/success-codes"         = "200-399"
      "alb.ingress.kubernetes.io/group.name"            = "${var.environment}-frontend"
      "alb.ingress.kubernetes.io/ssl-policy"            = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      "alb.ingress.kubernetes.io/certificate-arn"       = var.certificate_arn
      "alb.ingress.kubernetes.io/waf-acl-id"           = var.waf_web_acl_arn != null ? var.waf_web_acl_arn : null
      "alb.ingress.kubernetes.io/load-balancer-attributes" = jsonencode({
        "idle_timeout.timeout_seconds" = "60"
        "routing.http2.enabled"        = "true"
      })
    }
  }

  spec {
    ingress_class_name = kubernetes_ingress_class_v1.alb.metadata[0].name

    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
