# database

This module provisions a DigitalOcean managed database clusters.

## Variables

- `cluster_name`: Grove cluster name.
- `engine`: Database engine name.
- `engine_version`: Database engine version.
- `region`: DigitalOcean region.
- `size`: DigitalOcean database kind slug.
- `vpc_id`: VPC ID where the cluster belongs to.
- `firewall_rules`: List of inbound firewall rule objects.
- `node_count`: Number of nodes in the cluster.

## Outputs

- `database_cluster` - Result of [`digitalocean_database_cluster`](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster).
- `root_username`: Root user's username.
- `root_password`: Root user's password.
- `host`: Cluster host address.
- `port`: Cluster port.
- `connection_string`: Database connection string.
- `certificate`: Database self-signed (by DigitalOcean) CA certificate.
- `instances`: Database users and passwords created for the instances.
