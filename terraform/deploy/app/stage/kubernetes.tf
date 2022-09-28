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

####################################################################################################
## Create metrics server resources
####################################################################################################

module "k8s_metrics_server" {
  source               = "../provider-modules/k8s-metrics-server"
  depends_on           = [digitalocean_vpc.main_vpc]
  service_account_name = "metrics-server"
}
