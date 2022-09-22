# See https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
# if using the kubectl_manifest resource then we get an error
# every time we do a tf plan.
# no matches for kind "ClusterIssuer" in group "cert-manager.io"
resource "kubectl_manifest" "monitoring_certificate" {
  count = var.enable_monitoring_ingress ? 1 : 0
  yaml_body = templatefile("${path.module}/cert-manager-letsencrypt.yaml", {
    namespace          = local.namespace_monitoring
    notification_email = var.lets_encrypt_notification_inbox,
    domain             = var.cluster_domain
  })
}

resource "random_password" "ingress_auth" {
  length           = 32
  special          = false
  override_special = ",.-_!"
}

resource "htpasswd_password" "ingress_auth" {
  password = random_password.ingress_auth.result
  salt     = substr(sha512(random_password.ingress_auth.result), 0, 8)
}

resource "kubernetes_secret" "ingress_auth" {
  metadata {
    name      = "${local.namespace_monitoring}-basic-auth"
    namespace = local.namespace_monitoring
    labels = {
      app = "k8s-monitoring"
    }
  }

  data = {
    "admin" = htpasswd_password.ingress_auth.bcrypt
  }
}

resource "kubernetes_ingress_v1" "monitoring_ingress" {
  count      = var.enable_monitoring_ingress ? 1 : 0
  depends_on = [kubectl_manifest.monitoring_certificate]

  metadata {
    name      = "monitoring-ingress"
    namespace = local.namespace_monitoring
    annotations = {
      "nginx.ingress.kubernetes.io/auth-type"        = "basic",
      "nginx.ingress.kubernetes.io/auth-secret-type" = "auth-map",
      "nginx.ingress.kubernetes.io/auth-secret"      = "${local.namespace_monitoring}/${kubernetes_secret.ingress_auth.metadata.0.name}"
      "nginx.ingress.kubernetes.io/auth-realm"       = "Authentication is required"
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/enable-cors"      = "true"
      "kubernetes.io/tls-acme"                       = "true"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      secret_name = "${local.namespace_monitoring}-ingress"
      hosts = [
        "prometheus.${var.cluster_domain}",
        "grafana.${var.cluster_domain}",
        "alert-manager.${var.cluster_domain}",
        "opensearch-dashboard.${var.cluster_domain}",
      ]
    }

    rule {
      host = "prometheus.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "prometheus-operated"
              port {
                number = 9090
              }
            }
          }
          path = "/"
        }
      }
    }

    rule {
      host = "alert-manager.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "alertmanager-operated"
              port {
                number = 9093
              }
            }
          }

          path = "/"
        }
      }
    }

    rule {
      host = "grafana.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "prometheus-operator-grafana"
              port {
                number = 3000
              }
            }
          }

          path = "/"
        }
      }
    }

    rule {
      host = "opensearch-dashboard.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "opensearch-dashboard-opensearch-dashboards"
              port {
                number = 5601
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}
