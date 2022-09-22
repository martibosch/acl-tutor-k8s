terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.19"
    }
  }
}

resource "digitalocean_database_cluster" "database_cluster" {
  name                 = substr("${var.cluster_name}-${var.engine}", 0, 30)
  engine               = var.engine
  version              = var.engine_version
  size                 = var.size
  region               = var.region
  node_count           = var.node_count
  private_network_uuid = var.vpc_id
  tags                 = []

  # Allow maintenance window for Sunday 1 AM
  maintenance_window {
    day = "sunday"
    # Maintenance hours parsing implemented differently for MySQL and
    # MongoDB. Although the same format would be accepted by all engines, the
    # plan output would show diffs.
    hour = var.engine == "mongodb" ? "1:00" : "01:00:00"
  }
}

resource "null_resource" "no_primay_key_patch_database_cluster" {
  triggers = {
    cluster_id = digitalocean_database_cluster.database_cluster.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -X PATCH \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DO_TOKEN" \
        -d '{"config": {"sql_mode": "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES"}}' \
        "https://api.digitalocean.com/v2/databases/$CLUSTER_ID/config"
    EOT
    environment = {
      DO_TOKEN   = var.do_token
      CLUSTER_ID = digitalocean_database_cluster.database_cluster.id
    }
  }
}

# DigitalOcean cannot set VPC CIDR blocks for rules, so we have to list the rules
# one by one. Since the rules are dynamic and depends on resources from other modules,
# we dynamically create those rules given as an input for the module. This allows higher
# chance for misconfiguration, but necessary to work with other modules' resources.
resource "digitalocean_database_firewall" "database_cluster_firewall" {
  cluster_id = digitalocean_database_cluster.database_cluster.id

  dynamic "rule" {
    for_each = var.firewall_rules

    content {
      type  = rule.value["type"]
      value = rule.value["value"]
    }
  }
}

resource "digitalocean_database_user" "database_users" {
  for_each   = toset(var.users)
  cluster_id = digitalocean_database_cluster.database_cluster.id
  name       = each.key
}

resource "digitalocean_database_db" "databases" {
  for_each   = toset(var.users)
  cluster_id = digitalocean_database_cluster.database_cluster.id
  name       = each.key
}
