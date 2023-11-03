# -----------------------
# Data and local resources
# -----------------------
locals {
  minio_bucket_name                  = "runner"
  runner_namespace                   = var.resources_suffix != "" ? "${var.namespace}-${var.resources_suffix}" : var.namespace
  workload_identity_name             = var.resources_suffix != "" ? "gitlab-runner-${var.resources_suffix}" : "gitlab-runner"
  cluster_admin_sa_name              = var.resources_suffix != "" ? "gitlab-${var.resources_suffix}" : "gitlab"
  cluster_admin_sa_role_binding_name = var.resources_suffix != "" ? "gitlab-admin-${var.resources_suffix}" : "gitlab-admin"
  gitlab_helm_release_name           = var.resources_suffix != "" ? "${var.helm_release_name}-${var.resources_suffix}" : var.helm_release_name
  minio_helm_release_name            = var.resources_suffix != "" ? "bitnami-${var.resources_suffix}" : "bitnami"

  # Permissions needed to dump databases using `gcloud sql export sql` command. 
  # Remember that the CloudSQL service account will need to be able to access the
  # bucket to write dumps to it.
  permissions_allow_cloudsql_database_dumps = [
    "cloudsql.instances.export",
    "cloudsql.instances.get",
    "cloudsql.databases.get",
  ]

  # Permissions needed to deploy cloud run applications.
  permissions_deploy_cloudrun_applications = [
    "run.configurations.get",
    "run.configurations.list",
    "run.locations.list",
    "run.operations.get",
    "run.operations.list",
    "run.revisions.get",
    "run.revisions.list",
    "run.routes.get",
    "run.routes.list",
    "run.services.create",
    "run.services.get",
    "run.services.getIamPolicy",
    "run.services.list",
    "run.services.setIamPolicy",
    "run.services.update",
  ]

  custom_role_name        = var.resources_suffix != "" ? join("", [
    "custom.gitlabRunner", title(var.resources_suffix)
  ]) : "custom.gitlabRunner"
  custom_role_fullpath_id = "projects/${var.project_id}/roles/${local.custom_role_name}"

  custom_role_permissions = concat(
    var.runner_consent_cloud_sql_dumps ? local.permissions_allow_cloudsql_database_dumps : [],
    var.runner_consent_deploy_cloudrun_apps ? local.permissions_deploy_cloudrun_applications : [],
  )

  # If custom_role_permissions is empty, we do not want to create the custom role.
  create_custom_role = length(local.custom_role_permissions) >= 1
}

# -----------------------
# Create the namespace.
# -----------------------
resource "kubernetes_namespace" "gitlab_runner" {
  metadata {
    labels = {
      name = local.runner_namespace
    }

    name = local.runner_namespace
  }
}

# -----------------------
# Minio bucket credentials
# -----------------------
resource "random_password" "minio_accesskey" {
  length           = 20
  special          = true
  override_special = "_%@"
}

resource "random_password" "minio_secretkey" {
  length           = 40
  special          = true
  override_special = "_%@"
}

resource "kubernetes_secret" "minio_credentials" {
  metadata {
    name      = "s3access"
    namespace = local.runner_namespace
  }

  data = {
    # Attributes for Gitlab runner https://docs.gitlab.com/runner/install/kubernetes.html
    accesskey     = random_password.minio_accesskey.result
    secretkey     = random_password.minio_secretkey.result
    # Attributes for minio.
    root-user     = random_password.minio_accesskey.result
    root-password = random_password.minio_secretkey.result
  }

  depends_on = [
    random_password.minio_accesskey,
    random_password.minio_secretkey,
    kubernetes_namespace.gitlab_runner,
  ]
}

# Define a custom role for atomic permissions management on gitlab-runner-workload-identity-mapping.
resource "google_project_iam_custom_role" "gitlab_runner_custom_role" {
  count       = local.create_custom_role ? 1 : 0
  role_id     = local.custom_role_name
  title       = "Custom role tailored for a Gitlab Runner pod."
  description = "A custom role to assign additional fine grained permissions to the ${local.workload_identity_name} service account used by the Gitlab runner pod."
  permissions = local.custom_role_permissions
}

# -------------------------------
# Service account for Gitlab Runner "Worker"
# -------------------------------
# Reference https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/v16.1.0/modules/workload-identity
module "gitlab_runner_workload_identity_mapping" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version    = "29.0.0"
  name       = local.workload_identity_name
  namespace  = local.runner_namespace
  project_id = var.project_id
  roles      = concat(
    var.runner_default_roles,
    var.runner_additional_roles,
    local.create_custom_role ? [local.custom_role_fullpath_id] : [],
    var.runner_consent_deploy_cloudrun_apps ? [
      "roles/run.invoker"
    ] : [], # The `run.routes.invoke` permission cannot be added to the custom role (https://cloud.google.com/iam/docs/custom-roles-permissions-support)
  )
}

# -----------------------
# Gitlab Runner
# -----------------------
# Gitlab runner Helm chart values.
data "template_file" "gitlab_runner_config" {
  template = templatefile("${path.module}/values/gitlab-runner.yml", {
    gitlab_url_with_protocol       = var.gitlab_url_with_protocol
    minio_server                   = "${helm_release.minio.name}-${helm_release.minio.chart}"
    bucket_name                    = local.minio_bucket_name
    runner_registration_token      = var.runner_registration_token
    cache_secretname               = kubernetes_secret.minio_credentials.metadata[0].name
    run_untagged                   = var.run_untagged
    runner_tags                    = var.runner_tags
    runner_sa_name                 = module.gitlab_runner_workload_identity_mapping.k8s_service_account_name
    build_container_cpu_request    = var.runner_build_container_cpu_request
    build_container_memory_request = var.runner_build_container_memory_request
  })

  depends_on = [
    kubernetes_secret.minio_credentials,
    module.gitlab_runner_workload_identity_mapping,
  ]
}

# refs: https://gitlab.com/gitlab-org/charts/gitlab-runner
resource "helm_release" "gitlab_runner" {
  # Helm release name is build as [name]-[chart].
  name             = local.gitlab_helm_release_name
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  namespace        = local.runner_namespace
  version          = var.chart_version
  create_namespace = false

  values = [
    data.template_file.gitlab_runner_config.template
  ]

  depends_on = [
    data.template_file.gitlab_runner_config,
    kubernetes_namespace.gitlab_runner,
  ]
}

# -----------------------
# S3 Minio (used for Runners cache layer)
# -----------------------
# Minio Helm chart values.
data "template_file" "minio_config" {
  template = templatefile("${path.module}/values/minio.yml", {
    bucket_name = local.minio_bucket_name
    secret_name = kubernetes_secret.minio_credentials.metadata[0].name
  })

  depends_on = [
    kubernetes_secret.minio_credentials,
  ]
}

# Minio installation
# refs: https://artifacthub.io/packages/helm/bitnami/minio/
resource "helm_release" "minio" {
  # Helm release name is build as [name]-[chart].
  name             = local.minio_helm_release_name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "minio"
  namespace        = local.runner_namespace
  version          = var.minio_chart_version
  create_namespace = false

  values = [
    data.template_file.minio_config.template,
  ]

  depends_on = [
    data.template_file.minio_config,
    kubernetes_namespace.gitlab_runner,
  ]
}

# -----------------------
# GitLab cluster integration
# -----------------------
# Add a k8s service account with admin privileges for Gitlab cluster integration.
# Refs: https://gitlab.sparkfabrik.com/help/user/project/clusters/add_existing_cluster.md
resource "kubernetes_service_account" "gitlab" {
  count = var.create_gitlab_k8s_integration_service_account ? 1 : 0
  metadata {
    name      = local.cluster_admin_sa_name
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "gitlab_admin_token" {
  count = var.create_gitlab_k8s_integration_service_account ? 1 : 0
  metadata {
    name      = kubernetes_service_account.gitlab[0].default_secret_name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_service_account.gitlab,
  ]
}

# Assign the cluster-admin role to the "gitlab" service account.
resource "kubernetes_cluster_role_binding" "gitlab_admin" {
  count = var.create_gitlab_k8s_integration_service_account ? 1 : 0
  metadata {
    name = local.cluster_admin_sa_role_binding_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gitlab[0].metadata[0].name
    namespace = kubernetes_service_account.gitlab[0].metadata[0].namespace
  }

  depends_on = [
    kubernetes_service_account.gitlab,
  ]
}

# ------------------------------------------------
# Gitlab runner can write on a container registry
# ------------------------------------------------
# Assign object admin to the gcr registry to gitlab-runner service account (the one used for gitlab jobs).
resource "google_storage_bucket_iam_member" "runner_registry_admin" {
  count      = var.container_registry_bucket != "" ? 1 : 0
  bucket     = var.container_registry_bucket
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${module.gitlab_runner_workload_identity_mapping.gcp_service_account_email}"
  depends_on = [
    module.gitlab_runner_workload_identity_mapping
  ]
}

resource "google_storage_bucket_iam_member" "runner_registry_writer" {
  count      = var.container_registry_bucket != "" ? 1 : 0
  bucket     = var.container_registry_bucket
  role       = "roles/storage.legacyBucketWriter"
  member     = "serviceAccount:${module.gitlab_runner_workload_identity_mapping.gcp_service_account_email}"
  depends_on = [
    module.gitlab_runner_workload_identity_mapping
  ]
}
