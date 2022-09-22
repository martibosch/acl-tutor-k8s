# k8s-nginx-ingress

This module installs [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and [cert-manager](https://cert-manager.io/docs/) using Helm.

# Variables

- `ingress_namespace`: The namespace under which those resources will be installed.
- `global_404_html_path`: Path in tools-container to the html page to show when provisioning instances or if there's a 404 on the ingress.
- `admission_webhooks_enabled`: Whether [admission webhooks](https://kubernetes.github.io/ingress-nginx/how-it-works/#avoiding-outage-from-wrong-configuration) enabled or disabled. By default it's enabled. **Don't disable in production.**

# Output

This module doesn't provide any output.
