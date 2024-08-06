# Create a VPC for the application
resource "google_compute_network" "iddotme-network" {
  name                    = var.network_name
  project                 = module.project.project_id
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "iddotme-subnetwork" {
  project       = module.project.project_id
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = google_compute_network.iddotme-network.name
}

resource "google_compute_router" "default" {
  name    = "${var.network_name}-router"
  network = google_compute_network.iddotme-network.self_link
  region  = var.region
  project = module.project.project_id
}

resource "google_compute_router_nat" "nat" {
  project                            = module.project.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
resource "google_compute_firewall" "http" {
  project     = module.project.project_id
  name        = "${var.network_name}-http-allow"
  network     = google_compute_network.iddotme-network.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["allow-http"]
}
