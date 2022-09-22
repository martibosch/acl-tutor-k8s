terraform {
  cloud {
    organization = "exaf-epfl"
    workspaces {
      name = "acl-tutor-k8s-base"
    }
  }
}
