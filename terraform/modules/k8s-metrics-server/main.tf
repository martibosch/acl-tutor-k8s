resource "helm_release" "k8s_metrics_server" {
  name       = "kubernetes-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.chart_version
  namespace  = "kube-system"

  # AWS EKS / DOKS doesn't include the required "metrics-server" by default, so we need to install it too:
  set {
    name  = "metrics-server.enabled"
    value = "true"
  }
  # Name of the role (user) that we use to log in to the dashboard
  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
    type  = "string"
  }
}
