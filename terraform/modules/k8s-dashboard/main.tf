resource "helm_release" "k8s_dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  version    = var.dashboard_chart_version
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
  # Give the default role (user) for the dashboard read-only permission.
  # "The basic idea of the clusterReadOnlyRole is not to hide all the secrets and sensitive data but more
  # to avoid accidental changes in the cluster outside the standard CI/CD."
  # Note that if this is set to false, the result is no permissions at all; for full permissions, they
  # must be created separately from the Helm chart as described at
  # https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html
  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }
}
