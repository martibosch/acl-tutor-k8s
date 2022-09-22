terraform {
  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.1"
    }
  }
}

locals {
  service_namespace = "openfaas"
  fn_namespace      = "openfaas-fn"
}

resource "kubernetes_namespace" "k8s_service_namespace" {
  metadata {
    name        = local.service_namespace
    annotations = {}
    labels      = {}
  }
}

resource "kubernetes_namespace" "k8s_functions_namespace" {
  metadata {
    name        = local.fn_namespace
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "k8s_openfaas" {
  name       = "openfaas"
  repository = "https://openfaas.github.io/faas-netes"
  chart      = "openfaas"
  version    = var.openfaas_chart_version
  namespace  = local.service_namespace

  set {
    name  = "functionNamespace"
    value = local.fn_namespace
  }

  // Disable basic auth as we set it in a separate resource
  set {
    name  = "basic_auth"
    value = "false"
  }

  set {
    name  = "exposeServices"
    value = "false"
  }
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
    name      = "${local.service_namespace}-basic-auth"
    namespace = local.service_namespace
    labels = {
      app = "k8s-ingress"
    }
  }

  data = {
    "admin" = htpasswd_password.ingress_auth.bcrypt
  }
}

resource "kubernetes_ingress_v1" "openfaas_ingress" {
  depends_on = [
    helm_release.k8s_openfaas
  ]

  metadata {
    name      = "${local.service_namespace}-ingress"
    namespace = local.service_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/auth-type"        = "basic",
      "nginx.ingress.kubernetes.io/auth-secret-type" = "auth-map",
      "nginx.ingress.kubernetes.io/auth-secret"      = "${local.service_namespace}/${kubernetes_secret.ingress_auth.metadata.0.name}"
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
      secret_name = "${local.service_namespace}-ingress"
      hosts = [
        "openfaas.${var.cluster_domain}"
      ]
    }

    rule {
      host = "openfaas.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "gateway"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}
