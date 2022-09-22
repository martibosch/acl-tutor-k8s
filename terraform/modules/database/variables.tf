variable "cluster_name" {
  type        = string
  description = "Grove cluster name."
}

variable "engine" {
  type        = string
  description = "Database engine name."
}

variable "engine_version" {
  type        = string
  description = "Database engine version."
}

variable "region" {
  type        = string
  description = "Droplet region."
}

variable "vpc_id" {
  type        = string
  description = "ID of the related VPC."
}

variable "size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "Database instance size."
}

variable "firewall_rules" {
  type = list(object({
    type  = string
    value = string
  }))

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["droplet", "k8s", "ip_addr", "tag", "app"], rule.type)
    ])
    error_message = "The DigitalOcean database cluster's VPC must be droplet, k8s, ip_addr, tag, or app."
  }
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes in the database cluster."
}

variable "users" {
  type        = list(string)
  default     = []
  description = "List of users created for the database cluster"
}

variable "do_token" {
  type = string
}
