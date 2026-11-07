output "service_name" {
  value       = module.cloud_run.service_name
  description = "The deployed Cloud Run service name"
}

output "service_url" {
  value       = module.cloud_run.service_url
  description = "The direct URI endpoint of the Cloud Run service"
}

output "service_account" {
  value       = module.cloud_run.service_account
  description = "The service account email assigned to the runtime workload"
}