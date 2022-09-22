####################################################################################################
## VPC: A virtual private cloud which will hold everything else
####################################################################################################

resource "digitalocean_vpc" "main_vpc" {
  name     = "${var.cluster_name}-vpc"
  region   = var.do_region
  ip_range = var.vpc_ip_range != "" ? var.vpc_ip_range : null
}
