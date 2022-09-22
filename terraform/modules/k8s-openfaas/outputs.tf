output "ingress_password" {
  value       = random_password.ingress_auth.result
  sensitive   = true
  description = "Password to log into openfaas services"
}
