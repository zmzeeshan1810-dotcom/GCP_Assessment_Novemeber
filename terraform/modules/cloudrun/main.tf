# Dedicated Runtime Service Account
resource "google_service_account" "runtime" {
  account_id   = "${var.service_name}-${var.environment}-sa"
  display_name = "Cloud Run Runtime Service Account for ${var.environment}"
}

# Cloud Run v2 Service
resource "google_cloud_run_v2_service" "app" {
  name     = "${var.service_name}-${var.environment}"
  location = var.region
  ingress  = var.ingress_type

  template {
    service_account = google_service_account.runtime.email
    timeout         = "${var.timeout}s"

    max_instance_request_concurrency = var.concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      ports {
        container_port = 8080
      }
    }
  }
}

# Explicit Ingress Access IAM Policy
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  count    = var.allow_unauthenticated ? 1 : 0
  location = google_cloud_run_v2_service.app.location
  project  = google_cloud_run_v2_service.app.project
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}