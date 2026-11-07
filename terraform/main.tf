terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_run" {
  source = "./modules/cloudrun" # Updated to match folder name 'cloudrun'

  project_id            = var.project_id
  region                = var.region
  service_name          = var.service_name
  environment           = var.environment
  image                 = var.image
  cpu                   = var.cpu
  memory                = var.memory
  timeout               = var.timeout
  concurrency           = var.concurrency
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  ingress_type          = var.ingress_type
  allow_unauthenticated = var.allow_unauthenticated
}