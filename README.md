<!-- BEGIN_TF_DOCS -->
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
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.86.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.2 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.86.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.2 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The chart version. Be sure to use the version corresponding to your Gitlab version. | `string` | n/a | yes |
| <a name="input_container_registry_bucket"></a> [container\_registry\_bucket](#input\_container\_registry\_bucket) | The name of container registry bucket. If not empty, the runner will get all needed the permissions to push and pull images to this bucket. | `string` | `""` | no |
| <a name="input_create_gitlab_k8s_integration_service_account"></a> [create\_gitlab\_k8s\_integration\_service\_account](#input\_create\_gitlab\_k8s\_integration\_service\_account) | Set to true if you want to integrate the cluster in which you are deploing your runner in Gitlab using a cluster certificate and a service account token. More info at https://docs.gitlab.com/ee/user/project/clusters/add_existing_cluster.html | `bool` | `false` | no |
| <a name="input_gitlab_url_with_protocol"></a> [gitlab\_url\_with\_protocol](#input\_gitlab\_url\_with\_protocol) | The GitLab Server URL (with protocol) that want to register the runner against. ref: https://docs.gitlab.com/runner/commands/index.html#gitlab-runner-register | `string` | n/a | yes |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | The Helm release name. You can leave default, if you need only a release per namespace. | `string` | `"gitlab"` | no |
| <a name="input_minio_chart_version"></a> [minio\_chart\_version](#input\_minio\_chart\_version) | The Bitnami Minio chart version. | `string` | `"9.2.10"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Gitlab runner namespace name. If resouces\_suffix is defined, the name of the namespace will be `namespace-SUFFIX`. | `string` | `"gitlab-runner"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID. | `string` | n/a | yes |
| <a name="input_resources_suffix"></a> [resources\_suffix](#input\_resources\_suffix) | The suffix for the generated resources. If null (default), the resources will not have a custom suffix. | `string` | `""` | no |
| <a name="input_run_untagged"></a> [run\_untagged](#input\_run\_untagged) | Specify if the runner can or can't run untagged jobs. | `bool` | `false` | no |
| <a name="input_runner_additional_roles"></a> [runner\_additional\_roles](#input\_runner\_additional\_roles) | A list of additional roles to be added to the runner service account. | `list(string)` | `[]` | no |
| <a name="input_runner_build_container_cpu_request"></a> [runner\_build\_container\_cpu\_request](#input\_runner\_build\_container\_cpu\_request) | The CPU allocation requested for build containers. | `string` | `"100m"` | no |
| <a name="input_runner_build_container_memory_request"></a> [runner\_build\_container\_memory\_request](#input\_runner\_build\_container\_memory\_request) | The amount of memory requested from build containers. | `string` | `"128Mi"` | no |
| <a name="input_runner_consent_cloud_sql_dumps"></a> [runner\_consent\_cloud\_sql\_dumps](#input\_runner\_consent\_cloud\_sql\_dumps) | Set to true if you want to add permissions to the runner to dump CloudSQL databases using gcloud sql export sql command. | `bool` | `false` | no |
| <a name="input_runner_consent_deploy_cloudrun_apps"></a> [runner\_consent\_deploy\_cloudrun\_apps](#input\_runner\_consent\_deploy\_cloudrun\_apps) | Set to true if you want to add permissions to the runner to manage and deploy applications in Cloud Run. | `bool` | `false` | no |
| <a name="input_runner_default_roles"></a> [runner\_default\_roles](#input\_runner\_default\_roles) | Set the roles assigned to the runner SA via Workload Identity. | `list(string)` | <pre>[<br>  "roles/container.developer",<br>  "roles/iam.serviceAccountUser"<br>]</pre> | no |
| <a name="input_runner_registration_token"></a> [runner\_registration\_token](#input\_runner\_registration\_token) | The Gitlab runner registration token. You can retrieve it is from your Gitlab project or group backend in the CI/CD settings. | `string` | n/a | yes |
| <a name="input_runner_tags"></a> [runner\_tags](#input\_runner\_tags) | Specify the tags associated with the runner. Comma-separated list of tags. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_cluster_admin_service_token"></a> [gitlab\_cluster\_admin\_service\_token](#output\_gitlab\_cluster\_admin\_service\_token) | The service token scoped to kube-system with cluster-admin privileges. We use this token to integrate the cluster in Gitlab. |
| <a name="output_gitlab_runner_worker_service_account_email"></a> [gitlab\_runner\_worker\_service\_account\_email](#output\_gitlab\_runner\_worker\_service\_account\_email) | The GCP service account used by the Gitlab runner worker. |
| <a name="output_minio_accesskey"></a> [minio\_accesskey](#output\_minio\_accesskey) | The minio access key. |
| <a name="output_minio_credentials_k8s_secret_name"></a> [minio\_credentials\_k8s\_secret\_name](#output\_minio\_credentials\_k8s\_secret\_name) | The name of the secret with minio credentials |
| <a name="output_minio_secretkey"></a> [minio\_secretkey](#output\_minio\_secretkey) | The minio secret key. |
## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.gitlab_runner_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_storage_bucket_iam_member.runner_registry_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.runner_registry_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [helm_release.gitlab_runner](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.minio](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding.gitlab_admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.gitlab_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.minio_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.gitlab](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_password.minio_accesskey](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.minio_secretkey](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [kubernetes_secret.gitlab_admin_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |
| [template_file.gitlab_runner_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.minio_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitlab_runner_workload_identity_mapping"></a> [gitlab\_runner\_workload\_identity\_mapping](#module\_gitlab\_runner\_workload\_identity\_mapping) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | 16.1.0 |

<!-- END_TF_DOCS -->