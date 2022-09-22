variable "cluster_name" { type = string }

variable "min_worker_node_count" {
  type        = number
  default     = 3
  description = "Minimum number of running Kubernetes worker nodes."
}

variable "max_worker_node_count" {
  type        = number
  default     = 5
  description = "Maximum number of running Kubernetes worker nodes."
}

variable "worker_node_size" {
  type        = string
  default     = "s-2vcpu-4gb"
  description = "Kubernetes worker node size."
  validation {
    condition = contains([
      "s-1vcpu-1gb",
      "s-1vcpu-1gb-amd",
      "s-1vcpu-1gb-intel",
      "s-1vcpu-2gb",
      "s-1vcpu-2gb-amd",
      "s-1vcpu-2gb-intel",
      "s-2vcpu-2gb",
      "s-2vcpu-2gb-amd",
      "s-2vcpu-2gb-intel",
      "s-2vcpu-4gb",
      "s-2vcpu-4gb-amd",
      "s-2vcpu-4gb-intel",
      "s-4vcpu-8gb",
      "c-2",
      "c2-2vcpu-4gb",
      "s-4vcpu-8gb-amd",
      "s-4vcpu-8gb-intel",
      "g-2vcpu-8gb",
      "gd-2vcpu-8gb",
      "s-8vcpu-16gb",
    ], var.worker_node_size)
    error_message = "The provided worker node size is invalid."
  }
}

variable "do_token" { type = string }

variable "do_region" {
  type        = string
  default     = "sfo3"
  description = "DigitalOcean region to create the resources in."
  validation {
    condition = contains([
      "ams3",
      "blr1",
      "fra1",
      "lon1",
      "nyc1",
      "nyc2",
      "nyc3",
      "sfo3",
      "sgp1",
      "tor1",
    ], var.do_region)
    error_message = "The DigitalOcean region to create the cluster in."
  }
}

variable "mysql_cluster_instance_size" {
  type    = string
  default = "db-s-1vcpu-1gb"
}
variable "mysql_cluster_node_count" {
  type    = number
  default = 1
}
variable "mysql_cluster_engine_version" {
  type    = string
  default = "8"
}

variable "mongodb_cluster_instance_size" {
  type    = string
  default = "db-s-1vcpu-1gb"
}
variable "mongodb_cluster_node_count" {
  type    = number
  default = 3
}
variable "mongodb_cluster_engine_version" {
  type    = string
  default = "4"
}

variable "container_registry_server" { default = "registry.gitlab.com" }
variable "dependency_proxy_server" { default = "gitlab.com" }
variable "gitlab_group_deploy_token_username" { type = string }
variable "gitlab_group_deploy_token_password" { type = string }
variable "gitlab_cluster_agent_token" {
  type        = string
  description = "Token retrieved for Gitlab cluster agent"
}

variable "tutor_instances" { type = list(string) }

variable "vpc_ip_range" {
  type        = string
  description = "VPC IP range."
  default     = ""
}

variable "droplet_default_image" {
  type    = string
  default = "ubuntu-20-04-x64"
}

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

variable "enable_openfaas" {
  type        = bool
  default     = false
  description = "Whether to enable OpenFAAS."
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

variable "global_404_html_path" {
  type        = string
  default     = ""
  description = "Path in tools-container to html page to show when provisioning instances or if there's a 404 on the ingress."
}
