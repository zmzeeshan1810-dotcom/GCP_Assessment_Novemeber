module "cloudrun" {

  source = "../../modules/cloud-run"

  project_id = "sample-dev"
  region     = "us-central1"

  service_name = "demo-app"

  environment = "dev"

  image = "demo-app:latest"

  cpu    = "1"
  memory = "512Mi"

  timeout     = 60
  concurrency = 80

  min_instances = 0
  max_instances = 3
}