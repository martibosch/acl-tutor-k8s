# k8s-gitlab-container-registry

This module creates a namespace, secret set and service account to connect to GitLab Container Registry.

# Variables

- `namespace`: The namespace under which those resources will be created.
- `gitlab_group_deploy_token_username`: GitLab deployment token username.
- `gitlab_group_deploy_token_password`: GitLab deployment token password.

# Output

This module doesn't provide any output.
