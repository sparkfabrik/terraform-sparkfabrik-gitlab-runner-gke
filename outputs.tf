output "minio_credentials_k8s_secret_name" {
  sensitive = true
  value = kubernetes_secret.minio_credentials.metadata[0].name
  description = "The name of the secret with minio credentials"
}

output "minio_accesskey" {
  sensitive = true
  description = "The minio access key."
  value = random_password.minio_accesskey.result
}

output "minio_secretkey" {
  sensitive = true
  description = "The minio secret key."
  value = random_password.minio_secretkey.result
}

output "gitlab_cluster_admin_service_token" {
  sensitive = true
  description = "The service token scoped to kube-system with cluster-admin privileges. We use this token to integrate the cluster in Gitlab."
  value = var.create_gitlab_k8s_integration_service_account ? data.kubernetes_secret.gitlab_admin_token[0].data.token : null
}

output "gitlab_runner_worker_service_account_email" {
  sensitive = false
  description = "The GCP service account used by the Gitlab runner worker."
  value = module.gitlab_runner_workload_identity_mapping.gcp_service_account_email
}
