# Create a Google project for Compute Engine
resource "google_project" "project" {
  name            = var.prefix
  project_id      = var.prefix
  org_id          = var.org_id
  billing_account = "01FD6B-C45D51-322971"
}

# Enable the necessary services on the project for deployments
resource "google_project_service" "service" {
  for_each = toset(var.services)

  service = each.key

  project            = google_project.project.project_id
  disable_on_destroy = false
}