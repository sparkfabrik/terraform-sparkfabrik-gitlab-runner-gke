# Terraform Gitlab Runner GKE module

![tflint status](https://github.com/sparkfabrik/terraform-sparkfabrik-gitlab-runner-gke/actions/workflows/tflint.yml/badge.svg?branch=main)

This is a Terraform module to install and configure a Gitlab Runner in a GKE cluster
using the official [GitLab Runner Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab-runner).

The runner connect to an existing Gitlab instance using a provided registration token and 
use a Minio bucket (installed using the [Bitnami Chart](https://github.com/bitnami/charts/tree/master/bitnami/minio)) 
in the same namespace of the runner, to host the Runner cache.

This module is provided without any kind of warranty and is GPL3 licensed.

## Configuration of the Helm and Kubernetes providers

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

## Configuration options.

This module allows the installation of a runner on a GKE cluster and is rather
opinionated although it is highly configurable.

A workload identity is used that assigns default permissions to the runner,
permissions that should allow applications to be installed in the cluster.

It is possible to override the permissions by changing the default roles entered
in the `runner_default_roles` variable or by adding them to the `runner_additional_roles` variable.

If the runner needs to be able to access a CloudSQL instance or deploy 
applications to cloud run it is sufficient to enable two options by setting 
the two variables `runner_consent_cloud_sql_dumps` and `runner_consent_deploy_cloudrun_apps` to true.

The module supports the creation of a service account with cluster admin role needed 
for cluster integration in GitLab as described in the [official 
documentation](https://docs.gitlab.com/ee/user/project/clusters/add_existing_cluster.html) (`create_gitlab_k8s_integration_service_account`).

Finally, it is possible to install multiple runners on the same cluster by 
adding a suffix to the created resources (`resources_suffix`).
