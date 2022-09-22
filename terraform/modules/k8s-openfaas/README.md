# k8s-openfaas

This module installs [OpenFAAS](https://openfaas.com/) using Helm and exposes it on a cluster subdomain.

# Variables

- `openfaas_chart_version` - Version of the OpenFAAS Helm chart.
- `cluster_domain` - Domain name of the cluster.

# Output

- `ingress_password` - Basic auth password for the ingress controller.
