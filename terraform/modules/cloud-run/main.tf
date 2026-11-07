resource "google_service_account" "runtime" {

  account_id = "${var.service_name}-${var.environment}"

  display_name = "Cloud Run Runtime Service Account"
}

## Cloud Run ###
resource "google_cloud_run_v2_service" "app" {

  name     = var.service_name
  location = var.region

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {

    service_account = google_service_account.runtime.email

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
    }

    timeout = "${var.timeout}s"

    max_instance_request_concurrency = var.concurrency
  }
}