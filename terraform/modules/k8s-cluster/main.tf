terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.19"
    }
  }
}

data "digitalocean_kubernetes_versions" "available_versions" {}

resource "digitalocean_tag" "worker_firewall" {
  name = "fw-${var.cluster_name}-worker"
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name         = var.cluster_name
  region       = var.region
  version      = data.digitalocean_kubernetes_versions.available_versions.latest_version
  vpc_uuid     = var.vpc_uuid
  auto_upgrade = true
  # "Surge upgrade makes cluster upgrades fast and reliable by bringing up new nodes before destroying the outdated nodes."
  surge_upgrade = true

  node_pool {
    name       = "${var.cluster_name}-workers"
    size       = var.worker_node_size
    min_nodes  = var.min_worker_node_count
    max_nodes  = var.max_worker_node_count
    auto_scale = true
    tags       = [digitalocean_tag.worker_firewall.name]
  }
}

# Allow SSH into the worker nodes from any other host in the VPC (such as a bastion)
resource "digitalocean_firewall" "k8s_worker_node_ssh_access" {
  name = "${var.cluster_name}-worker-ssh"
  tags = [digitalocean_tag.worker_firewall.name]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.vpc_ip_range]
  }
}
