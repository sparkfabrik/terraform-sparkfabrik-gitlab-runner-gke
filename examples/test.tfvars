resources_suffix          = "demo"
gitlab_url_with_protocol  = "gitlab.mydomain.com"
namespace                 = "gitlab-runner"
chart_version             = "v0.40.0"
run_untagged              = false
runner_tags               = "spark,demo"
# Grab a registration token from your CI/CD settings in your Gitlab project or group.
runner_registration_token = "XXXXXXXXXXXXXXXXXXXXXX-YYYY"
project_id                = "gcp-demo-project"
container_registry_bucket = "eu.artifacts.gcp-demo-project.appspot.com"

create_gitlab_k8s_integration_service_account = true
runner_consent_cloud_sql_dumps                = true
runner_consent_deploy_cloudrun_apps           = true
