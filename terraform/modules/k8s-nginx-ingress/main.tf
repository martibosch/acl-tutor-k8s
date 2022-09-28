locals {
  global_404_html_path = var.global_404_html_path != "" ? var.global_404_html_path : "${path.module}/404.html"
}

resource "kubernetes_config_map" "custom_error_pages" {
  metadata {
    name      = "custom-error-pages"
    namespace = var.ingress_namespace
  }

  data = {
    "404" = file(local.global_404_html_path)
  }
}

# install nginx ingress controller
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.1.0"
  namespace  = var.ingress_namespace

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = var.admission_webhooks_enabled
  }

  values = [
    file("${path.module}/ingress-values.yaml")
  ]
}

# install cert manager
resource "helm_release" "ingress_cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.8.0"
  namespace  = var.ingress_namespace
  values = [
    file("${path.module}/cert_manager.yaml")
  ]
  depends_on = [helm_release.nginx_ingress]
}
