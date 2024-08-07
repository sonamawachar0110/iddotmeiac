variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "us-central1"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming the project and other resources"
}

variable "services" {
  type        = list(string)
  description = "List of services to enable for project"
  default = [
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}