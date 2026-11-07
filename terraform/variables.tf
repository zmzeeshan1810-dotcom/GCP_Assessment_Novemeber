variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region for deployment"
  default     = "us-central1"
}

variable "service_name" {
  type        = string
  description = "Base name of the service"
  default     = "stateless-app"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}

variable "image" {
  type        = string
  description = "Container image URI"
}

variable "cpu" {
  type        = string
  description = "CPU limit (e.g., '1000m')"
  default     = "1000m"
}

variable "memory" {
  type        = string
  description = "Memory limit (e.g., '512Mi')"
  default     = "512Mi"
}

variable "timeout" {
  type        = number
  description = "Request execution timeout in seconds"
  default     = 300
}

variable "concurrency" {
  type        = number
  description = "Maximum concurrent requests per instance"
  default     = 80
}

variable "min_instances" {
  type        = number
  description = "Minimum auto-scaling instance count"
  default     = 0
}

variable "max_instances" {
  type        = number
  description = "Maximum auto-scaling instance count"
  default     = 10
}

variable "ingress_type" {
  type        = string
  description = "Ingress control setting"
  default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

variable "allow_unauthenticated" {
  type        = bool
  description = "Whether to allow unauthenticated public requests"
  default     = false
}