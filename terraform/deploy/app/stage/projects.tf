####################################################################################################
## Project: A DigitalOcean Project to keep all resources organized together
####################################################################################################

resource "digitalocean_project" "project" {
  name        = var.cluster_name
  description = "Open edX deployment using Grove"
  purpose     = "Web Application"
  environment = "Production"

  resources = [
    module.k8s_cluster.cluster_urn,
    module.tutor_env.spaces_bucket.urn,
    module.mysql.database_cluster.urn,
    module.mongodb.database_cluster.urn,
  ]
}
