# Declare the kubeconfig as an output - access it anytime with "/tf output -raw kubeconfig"
output "kubeconfig" {
  value     = module.k8s_cluster.kubeconfig.raw_config
  sensitive = true
}

# The OpenSearch dashboard password - access it with "/tf output -raw opensearch_dashboard_admin_password"
output "opensearch_dashboard_admin_password" {
  value     = module.k8s_monitoring.opensearch_dashboard_admin_password
  sensitive = true
}

# The monitoring basic auth password - access it with "/tf output -raw monitoring_ingress_password"
output "monitoring_ingress_password" {
  value     = module.k8s_monitoring.monitoring_ingress_password
  sensitive = true
}
