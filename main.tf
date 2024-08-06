# Create a project for the resources hosting the application
module "project" {
  source = "./gcp-project"
  org_id = var.org_id
  region = var.region
  prefix = random_id.id.hex
}
# Create a service account

resource "google_service_account" "service_account" {
  account_id   = local.gcp_service_account_name
  display_name = local.gcp_service_account_name
  project      = module.project.project_id
}
# Private IP address for Cloud SQL

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  project  = module.project.project_id

  name          = "iddotme-db-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.iddotme-network.id
}
# Private IP connection for DB

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.iddotme-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
resource "random_id" "db_name_suffix" {
  byte_length = 4
}
/*****************************************
  Runner Secrets
 *****************************************/
resource "google_secret_manager_secret" "iddotme-secret" {
  provider  = google-beta
  project   = module.project.project_id
  secret_id = "iddotme-token"

  labels = {
    label = "iddotme-sql-connect"
  }

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}
resource "google_secret_manager_secret_version" "iddotme-secret-version" {
  provider = google-beta
  secret   = google_secret_manager_secret.iddotme-secret.id
  secret_data = jsonencode({
    "DB_USER" = "root"
    "DB_PASS" = random_password.mysql_root.result
    "DB_NAME" = var.database_name
    "DB_HOST" = "${google_sql_database_instance.iddotme.private_ip_address}:3306"
  })
}
resource "google_secret_manager_secret_iam_member" "iddotme-secret-member" {
  provider  = google-beta
  project   = module.project.project_id
  secret_id = google_secret_manager_secret.iddotme-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}

/*****************************************
  Runner GCE Instance Template
 *****************************************/
locals {
  instance_name = "iddotme-runner-vm"
}
module "mig_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 7.0"
  project_id         = module.project.project_id
  machine_type       = var.machine_type
  network            = var.network_name
  subnetwork         = var.subnet_name
  region             = var.region
  subnetwork_project = module.project.project_id
  service_account = {
    email = google_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 10
  disk_type            = "pd-ssd"
  auto_delete          = true
  name_prefix          = var.instance_name
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  startup_script       = file("${path.module}/scripts/startup.sh")
  source_image         = var.source_image
  metadata = {
    "secret-id" = google_secret_manager_secret_version.iddotme-secret-version.name
  }
  tags = [
    "iddotme-runner-vm", "allow-http"
  ]
}
/*****************************************
  Runner MIG
 *****************************************/
module "mig" {
  source             = "terraform-google-modules/vm/google//modules/mig"
  version            = "~> 7.0"
  project_id         = module.project.project_id
  subnetwork_project = module.project.project_id
  hostname           = var.instance_name
  region             = var.region
  instance_template  = module.mig_template.self_link
  target_size        = var.target_size

  /* autoscaler */
  autoscaling_enabled = true
  cooldown_period     = var.cooldown_period
}
