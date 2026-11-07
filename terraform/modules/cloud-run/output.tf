output "service_name" {
  value = google_cloud_run_v2_service.app.name
}

output "service_account" {
  value = google_service_account.runtime.email
}