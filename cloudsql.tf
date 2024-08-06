resource "google_sql_database_instance" "iddotme" {
  name             = local.cloud_sql_instance_name
  database_version = var.database_version
  region           = var.region
  project          = module.project.project_id

  deletion_protection = false

  settings {

    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.iddotme-network.id
    }

  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Create a database instance

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.iddotme.name
  project  = module.project.project_id
}

# Set the root password

resource "random_password" "mysql_root" {
  length  = 16
  special = true
}
resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.iddotme.name
  type     = "BUILT_IN"
  project  = module.project.project_id
  password = random_password.mysql_root.result
}

# Grant service account access to Cloud SQL as a client

resource "google_sql_user" "iddotme" {
  name     = google_service_account.service_account.email
  instance = google_sql_database_instance.iddotme.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = module.project.project_id
}

resource "google_project_iam_member" "sql_client" {
  project = module.project.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.service_account.email}"

}

resource "google_project_iam_member" "sql_instance" {
  project = module.project.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.service_account.email}"

}
