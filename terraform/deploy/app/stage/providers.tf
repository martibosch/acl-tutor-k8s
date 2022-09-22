terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.21.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.13.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Pre-declare data sources that we can use to get the cluster ID and auth info, once it's created
data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.cluster_name
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}
