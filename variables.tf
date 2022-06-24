variable "project_id" {
  type = string
  description = "The GCP project ID."
}

# To allow the installation of multiple runners on the same cluster,
# in example if we want to register a runner in different Gitlab groups,
# we can add a suffix to each of the created resources.
# If the suffix is left empty, no suffix will be append to the created resources.
variable "resources_suffix" {
  type = string
  description = "The suffix for the generated resources. If null (default), the resources will not have a custom suffix."
  default = ""
}

variable "namespace" {
  type = string
  description = "Gitlab runner namespace name. If resouces_suffix is defined, the name of the namespace will be `namespace-SUFFIX`."
  default = "gitlab-runner"
}

variable "chart_version" {
  type = string
  description = "The chart version. Be sure to use the version corresponding to your Gitlab version."
}

variable "helm_release_name" {
  type = string
  description = "The Helm release name. You can leave default, if you need only a release per namespace."
  default = "gitlab"
}

variable "minio_chart_version" {
  type = string
  description = "The Bitnami Minio chart version."
  default = "9.2.10"
}

variable "gitlab_url_with_protocol" {
  type = string
  description = "The GitLab Server URL (with protocol) that want to register the runner against. ref: https://docs.gitlab.com/runner/commands/index.html#gitlab-runner-register"
}

variable "runner_registration_token" {
  type = string
  description = "The Gitlab runner registration token. You can retrieve it is from your Gitlab project or group backend in the CI/CD settings."
}

variable "container_registry_bucket" {
  type = string
  description = "The name of container registry bucket. If not empty, the runner will get all needed the permissions to push and pull images to this bucket."
  default = ""
}

variable "run_untagged" {
  type = bool
  description = "Specify if the runner can or can't run untagged jobs."
  default = false
}

# refs: https://docs.gitlab.com/ce/ci/runners#use-tags-to-limit-the-number-of-jobs-using-the-runner
variable "runner_tags" {
  type = string
  description = "Specify the tags associated with the runner. Comma-separated list of tags."
}

variable "runner_default_roles" {
  type = list(string)
  description = "Set the roles assigned to the runner SA via Workload Identity."
  default = [
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
  ]
}

variable "runner_additional_roles" {
  type = list(string)
  description = "A list of additional roles to be added to the runner service account."
  default = []
}

variable "runner_build_container_cpu_request" {
  type = string
  description = "The CPU allocation requested for build containers."
  default = "100m"
}

variable "runner_build_container_memory_request" {
  type = string
  description = "The amount of memory requested from build containers."
  default = "128Mi"
}

variable "create_gitlab_k8s_integration_service_account" {
  type = bool
  description = "Set to true if you want to integrate the cluster in which you are deploing your runner in Gitlab using a cluster certificate and a service account token. More info at https://docs.gitlab.com/ee/user/project/clusters/add_existing_cluster.html"
  default = false
}

variable "runner_consent_cloud_sql_dumps" {
  type = bool
  description = "Set to true if you want to add permissions to the runner to dump CloudSQL databases using gcloud sql export sql command."
  default = false
}

variable "runner_consent_deploy_cloudrun_apps" {
  type = bool
  description = "Set to true if you want to add permissions to the runner to manage and deploy applications in Cloud Run."
  default = false
}
