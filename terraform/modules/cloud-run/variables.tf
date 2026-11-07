variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "image" {
  type = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "timeout" {
  type = number
}

variable "concurrency" {
  type = number
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}