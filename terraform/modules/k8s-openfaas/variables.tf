variable "openfaas_chart_version" {
  type    = string
  default = "10.0.23"
}

variable "cluster_domain" {
  type        = string
  default     = "grove.local"
  description = "Domain name of the cluster."
}
