variable "cluster_name" {
  type        = string
  description = "DigitalOcean cluster name."
}

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

variable "region" {
  type        = string
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
    ], var.region)
    error_message = "The DigitalOcean region to create the cluster in."
  }
}

variable "vpc_uuid" {
  type        = string
  description = "VPC network UUID to create the cluster in."
}

variable "vpc_ip_range" {
  type        = string
  description = "VPC IP range."
}
