# Terraform Gitlab Runner GKE module

![tflint status](https://github.com/sparkfabrik/terraform-sparkfabrik-gitlab-runner-gke/actions/workflows/tflint.yml/badge.svg?branch=main)

This is a Terraform module to install and configure a Gitlab Runner in a GKE cluster
using the official [GitLab Runner Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab-runner).

The runner connect to an existing Gitlab instance using a provided registration token and 
use a Minio bucket (installed using the [Bitnami Chart](https://github.com/bitnami/charts/tree/master/bitnami/minio)) 
in the same namespace of the runner, to host the Runner cache.

This module is provided without any kind of warranty and is GPL3 licensed.

# Configuration of the Helm and Kubernetes providers

```
provider "kubernetes" {
  host                   = # reference cluster endpoint
  cluster_ca_certificate = # reference cluster ca certificate base64decode
  token                  = # reference access token
}

provider "helm" {
  kubernetes {
    host                   = # reference cluster endpoint
    cluster_ca_certificate = # reference cluster ca certificate base64decode
    token                  = # reference access token
  }
}
```
