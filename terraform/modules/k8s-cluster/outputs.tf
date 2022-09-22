output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.cluster.kube_config[0]
  sensitive = true
}

output "cluster_urn" {
  value = digitalocean_kubernetes_cluster.cluster.urn
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.cluster.id
}
