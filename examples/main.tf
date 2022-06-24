# Install a Gitlab runner dedicated to the sacchettiditessuto project.
module "gitlab_runner" {
  source                    = "sparkfabrik/terraform-sparkfabrik-gitlab-runner-gke"
  gitlab_url_with_protocol  = var.gitlab_url_with_protocol
  resources_suffix          = var.resources_suffix
  namespace                 = var.namespace
  chart_version             = var.chart_version
  run_untagged              = var.run_untagged
  runner_tags               = var.runner_tags
  runner_registration_token = var.runner_registration_token
  project_id                = var.project_id
  container_registry_bucket = var.container_registry_bucket

  create_gitlab_k8s_integration_service_account = var.create_gitlab_k8s_integration_service_account
  runner_consent_cloud_sql_dumps                = var.runner_consent_cloud_sql_dumps
  runner_consent_deploy_cloudrun_apps           = var.runner_consent_deploy_cloudrun_apps
}
