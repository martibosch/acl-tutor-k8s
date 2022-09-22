####################################################################################################
## Managed MySQL Cluster
####################################################################################################

module "mysql" {
  source         = "./database"
  cluster_name   = var.cluster_name
  region         = var.do_region
  engine         = "mysql"
  engine_version = var.mysql_cluster_engine_version
  vpc_id         = digitalocean_vpc.main_vpc.id
  size           = var.mysql_cluster_instance_size
  node_count     = var.mysql_cluster_node_count
  do_token       = var.do_token

  # Database cluster firewalls cannot use VPC CIDR, therefore the access is
  # limited to the k8s cluster
  firewall_rules = [
    {
      type  = "k8s"
      value = module.k8s_cluster.cluster_id
    },
  ]
}

output "mysql" {
  value     = module.mysql
  sensitive = true
}

####################################################################################################
## Create MongoDB instance
####################################################################################################

module "mongodb" {
  source         = "./database"
  cluster_name   = var.cluster_name
  region         = var.do_region
  engine         = "mongodb"
  engine_version = var.mongodb_cluster_engine_version
  vpc_id         = digitalocean_vpc.main_vpc.id
  size           = var.mongodb_cluster_instance_size
  node_count     = var.mongodb_cluster_node_count
  do_token       = var.do_token

  # Database cluster firewalls cannot use VPC CIDR, therefore the access is
  # limited to the k8s cluster
  firewall_rules = [
    {
      type  = "k8s"
      value = module.k8s_cluster.cluster_id
    },
  ]

  users = toset(var.tutor_instances)
}

resource "digitalocean_database_db" "forum_database" {
  for_each   = toset(var.tutor_instances)
  cluster_id = module.mongodb.database_cluster.id
  name       = "${each.key}-cs_comments_service"
}

output "mongodb" {
  sensitive = true
  value = merge(module.mongodb, {
    instances = {
      for instance in toset(var.tutor_instances) :
      instance => {
        username       = module.mongodb.instances[instance].username
        password       = module.mongodb.instances[instance].password
        database       = module.mongodb.instances[instance].database,
        forum_database = "${instance}-cs_comments_service"
      }
    }
  })
}
