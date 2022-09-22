output "opensearch_dashboard_admin_password" {
  value     = random_password.opensearch_admin_password.result
  sensitive = true
}

output "monitoring_ingress_password" {
  value       = random_password.ingress_auth.result
  sensitive   = true
  description = "Password to log into monitoring services"
}
