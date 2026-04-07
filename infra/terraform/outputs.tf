output "artifact_registry_url" {
  description = "Docker registry URL for pushing images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.smart_news.repository_id}"
}

output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.smart_news.uri
}

output "deployer_service_account" {
  description = "Email of the GitHub Actions deployer service account"
  value       = google_service_account.deployer.email
}

output "wif_provider" {
  description = "Workload Identity Federation provider resource name (use as GCP_WORKLOAD_IDENTITY_PROVIDER secret)"
  value       = google_iam_workload_identity_pool_provider.github.name
}
