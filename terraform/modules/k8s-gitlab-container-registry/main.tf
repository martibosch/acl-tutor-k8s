# create k8s namespaces for each tutor instance
resource "kubernetes_namespace" "k8s_namespace" {
  metadata {
    name        = var.namespace
    annotations = {}
    labels      = {}
  }
}

# we need to create seperate secret for each k8s namespace
resource "kubernetes_secret" "k8s_docker_secret" {
  metadata {
    name        = "${var.namespace}-docker-cfg"
    namespace   = var.namespace
    annotations = {}
    labels      = {}
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.container_registry_server}" = {
          auth = "${base64encode("${var.gitlab_group_deploy_token_username}:${var.gitlab_group_deploy_token_password}")}"
        },
        "${var.dependency_proxy_server}" = {
          auth = "${base64encode("${var.gitlab_group_deploy_token_username}:${var.gitlab_group_deploy_token_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# we attach the docker secret with the default service account of a namespace
# so all pods & services under the namespace will use the secret to pull images
resource "kubernetes_default_service_account" "k8s_default_service_account" {
  depends_on = [kubernetes_namespace.k8s_namespace]
  metadata {
    namespace   = var.namespace
    annotations = {}
    labels      = {}
  }

  image_pull_secret {
    name = "${var.namespace}-docker-cfg"
  }
}
