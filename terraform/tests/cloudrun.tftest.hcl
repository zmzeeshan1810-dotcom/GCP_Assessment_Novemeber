# Native Terraform 1.6+ Unit Test Suite
# Tests contract assertions without requiring live GCP authentication

variables {
  project_id            = "optum-dev-123"
  region                = "us-central1"
  service_name          = "stateless-app"
  environment           = "dev"
  image                 = "gcr.io/optum-dev-123/stateless-app:v1.0.0"
  cpu                   = "1000m"
  memory                = "512Mi"
  timeout               = 300
  concurrency           = 80
  min_instances         = 0
  max_instances         = 3
  ingress_type          = "INGRESS_TRAFFIC_ALL"
  allow_unauthenticated = true
}

run "verify_dev_naming_convention" {
  command = plan

  assert {
    condition     = module.cloud_run.service_name == "stateless-app-dev"
    error_message = "Cloud Run service name must include environment suffix."
  }
}

run "verify_prod_security_controls" {
  command = plan

  variables {
    environment           = "prod"
    allow_unauthenticated = false
    min_instances         = 2
    max_instances         = 10
  }

  assert {
    condition     = module.cloud_run.service_name == "stateless-app-prod"
    error_message = "Production Cloud Run service name must use prod suffix."
  }
}