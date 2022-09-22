variable "ingress_namespace" {
  type = string
}

variable "global_404_html_path" {
  type        = string
  default     = ""
  description = "Path in tools-container to the html page to show when provisioning instances or if there's a 404 on the ingress."
}

variable "admission_webhooks_enabled" {
  type    = bool
  default = true
}
