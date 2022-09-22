####################################################################################################
## The Kubernetes Cluster itself
####################################################################################################

# This _must_ be in a separate module in order for us to use the credentials it provides
# to then deploy additional resources onto the cluster.
# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster#kubernetes-terraform-provider-example
# "When using interpolation to pass credentials from a digitalocean_kubernetes_cluster resource to the Kubernetes provider, the cluster resource generally should not be created in the same Terraform module where Kubernetes provider resources are also used. "

module "k8s_cluster" {
  source = "./k8s-cluster"

  cluster_name          = var.cluster_name
  max_worker_node_count = var.max_worker_node_count
  min_worker_node_count = var.min_worker_node_count
  worker_node_size      = var.worker_node_size
  region                = var.do_region
  vpc_uuid              = digitalocean_vpc.main_vpc.id
  vpc_ip_range          = var.vpc_ip_range
}

# Declare the kubeconfig as an output - access it anytime with "/tf output -raw kubeconfig"
output "kubeconfig" {
  value     = module.k8s_cluster.kubeconfig.raw_config
  sensitive = true
}

####################################################################################################
## Integrate kubernetes cluster with the GitLab project
####################################################################################################

module "k8s_gitlab_connector" {
  source                     = "../provider-modules/k8s-gitlab-connector"
  gitlab_cluster_agent_token = var.gitlab_cluster_agent_token
}

####################################################################################################
## Create k8s secret for GitLab container registry access
####################################################################################################

module "k8s_gitlab_container_registry" {
  for_each = toset(var.tutor_instances)

  source = "../provider-modules/k8s-gitlab-container-registry"

  namespace                          = each.key
  container_registry_server          = var.container_registry_server
  dependency_proxy_server            = var.dependency_proxy_server
  gitlab_group_deploy_token_username = var.gitlab_group_deploy_token_username
  gitlab_group_deploy_token_password = var.gitlab_group_deploy_token_password
}

####################################################################################################
## Create ingress controller
####################################################################################################

module "ingress" {
  source = "../provider-modules/k8s-nginx-ingress"

  ingress_namespace    = "kube-system"
  global_404_html_path = var.global_404_html_path
}


####################################################################################################
## Create monitoring pods
####################################################################################################

module "k8s_monitoring" {
  depends_on                      = [digitalocean_vpc.main_vpc]
  source                          = "../provider-modules/k8s-monitoring"
  alert_manager_config            = var.alert_manager_config
  enable_monitoring_ingress       = var.enable_monitoring_ingress
  cluster_domain                  = var.cluster_domain
  lets_encrypt_notification_inbox = var.lets_encrypt_notification_inbox
}

# The OpenSearch dashboard password - access it with "/tf output -raw opensearch_dashboard_admin_password"
output "opensearch_dashboard_admin_password" {
  value     = module.k8s_monitoring.opensearch_dashboard_admin_password
  sensitive = true
}

# The monitoring basic auth password - access it with "/tf output -raw monitoring_ingress_password"
output "monitoring_ingress_password" {
  value     = module.k8s_monitoring.monitoring_ingress_password
  sensitive = true
}

####################################################################################################
## Create OpenFAAS resources
####################################################################################################

module "k8s_openfaas" {
  count          = var.enable_openfaas ? 1 : 0
  source         = "../provider-modules/k8s-openfaas"
  depends_on     = [digitalocean_vpc.main_vpc]
  cluster_domain = var.cluster_domain
}

output "openfaas_ingress_password" {
  value     = module.k8s_openfaas
  sensitive = true
}

####################################################################################################
## Create metrics server resources
####################################################################################################

module "k8s_metrics_server" {
  source               = "../provider-modules/k8s-metrics-server"
  depends_on           = [digitalocean_vpc.main_vpc]
  service_account_name = "metrics-server"
}
