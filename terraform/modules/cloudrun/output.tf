output "service_name" {
  value       = google_cloud_run_v2_service.app.name
  description = "The deployed Cloud Run service name"
}

output "service_url" {
  value       = google_cloud_run_v2_service.app.uri
  description = "The direct URI endpoint of the Cloud Run service"
}

output "service_account" {
  value       = google_service_account.runtime.email
  description = "The service account email assigned to the runtime workload"
}