####################################################################################################
## Monitoring: Resources for monitoring our Kubernetes cluster
####################################################################################################

# This provider is required for stateful updates of passwords.
# OpenSearch Dashboard needs a bcrypt hash to configure it's password.
# The built-in terraform `random_password` module + the bcrypt function
# works, but it changes every time terraform is run requiring in a
# rebuild of resources.
# https://github.com/hashicorp/terraform-provider-random/issues/102

terraform {
  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

locals {
  namespace_monitoring = "monitoring"
  alert_manager_config = merge(
    yamldecode(file("${path.module}/alert-manager-default.yaml")),
    yamldecode(var.alert_manager_config)
  )
}

resource "kubernetes_config_map" "grafana_extra_dashboards" {
  binary_data = {}

  metadata {
    name        = "grafana-extra-dashboards"
    namespace   = local.namespace_monitoring
    annotations = {}
    labels      = {}
  }

  data = {
    "default-dashboard.json" : file("${path.module}/kubernetes-views-global_rev8.json")
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.namespace_monitoring
  }
}

resource "helm_release" "prometheus_operator" {
  depends_on = [helm_release.opensearch_cluster]
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "34.9.0"
  namespace  = local.namespace_monitoring


  values = [
    "${templatefile("${path.module}/prometheus-values.yaml", { alert_manager_config = local.alert_manager_config })}"
  ]
}

resource "random_password" "opensearch_admin_password" {
  length  = 32
  special = false
  keepers = {
    iteration = "1"
  }
}

resource "htpasswd_password" "hash" {
  password = random_password.opensearch_admin_password.result
  salt     = substr(sha512(random_password.opensearch_admin_password.result), 0, 8)
}

# This is not used at the moment, but is required for the OpenSearch securityConfig
# https://github.com/opensearch-project/helm-charts/issues/125
resource "kubernetes_secret" "opensearch_secret" {
  metadata {
    name        = "internal-users-config-secret"
    namespace   = local.namespace_monitoring
    annotations = {}
    labels      = {}
  }

  data = {
    "internal_users.yaml" = templatefile("${path.module}/internal_users.yaml", {
      hashed_password = htpasswd_password.hash.bcrypt
    })
  }

  type = "Opaque"
}

resource "helm_release" "opensearch_cluster" {
  depends_on = [kubernetes_namespace.monitoring]
  name       = "opensearch"
  repository = "https://opensearch-project.github.io/helm-charts/"
  chart      = "opensearch"
  version    = "1.10.0"
  namespace  = local.namespace_monitoring

  values = [
    "${file("${path.module}/opensearch_values.yaml")}"
  ]
}

resource "helm_release" "opensearch_dashboard" {
  depends_on = [helm_release.opensearch_cluster]
  name       = "opensearch-dashboard"
  repository = "https://opensearch-project.github.io/helm-charts/"
  chart      = "opensearch-dashboards"
  version    = "1.4.0"
  namespace  = local.namespace_monitoring
  values = [
    "${templatefile("${path.module}/dashboard_values.yaml", { password = "${random_password.opensearch_admin_password.result}" })}",
  ]
}

resource "helm_release" "fluent_bit" {
  depends_on = [helm_release.opensearch_cluster]
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.19.23"
  namespace  = local.namespace_monitoring

  values = [
    "${templatefile("${path.module}/fluent_bit_values.yaml", { password = "${random_password.opensearch_admin_password.result}" })}",
  ]
}
