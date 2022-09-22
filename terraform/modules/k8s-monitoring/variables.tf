variable "alert_manager_config" {
  type        = string
  description = "Alert Manager configuration as a YAML-encoded string"
  default     = "{}"
  validation {
    condition     = can(yamldecode(var.alert_manager_config))
    error_message = "The alert_manager_config value must be a valid YAML-encoded string."
  }
}

variable "enable_monitoring_ingress" {
  type        = bool
  default     = false
  description = "Whether to enable ingress for monitoring services."
}

variable "cluster_domain" {
  type        = string
  default     = "grove.local"
  description = "Domain used as the base for monitoring services."
}

variable "lets_encrypt_notification_inbox" {
  type        = string
  default     = "contact@example.com"
  description = "Email to send any email notifications about Letsencrypt"
}
