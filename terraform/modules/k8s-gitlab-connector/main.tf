####################################################################################################
## Integrate kubernetes cluster with gitlab project
####################################################################################################

terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.13.0"
    }
  }
}

resource "helm_release" "gitlab_agentagent" {
  name             = "gitlab"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  version          = "1.0.0"
  namespace        = "gitlab-kubernetes-agent"
  create_namespace = true

  set {
    name  = "config.token"
    value = var.gitlab_cluster_agent_token
  }

  set {
    name  = "config.kasAddress"
    value = "wss://kas.gitlab.com"
  }
}
