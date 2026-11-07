module "cloudrun" {

  source = "../../modules/cloud-run"

  project_id = "sample-prod"

  region = "us-central1"

  service_name = "demo-app"

  environment = "prod"

  image = "demo-app:latest"

  cpu    = "2"
  memory = "1Gi"

  timeout     = 120
  concurrency = 100

  min_instances = 1
  max_instances = 10
}