#baseline config for newly created project
#for use with Cluster Toolkit

variable "project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "vpc_network_name" {
  type    = string
  default = "default"
}

variable "vpc_subnetwork_region" {
  type    = string
  default = "us-central1"
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "resource_manager_api" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
}

#create default VPC (in custom mode to enable Google Private Access)
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  depends_on = [ google_project_service.compute_api ]
}

#create a subnet
resource "google_compute_subnetwork" "vpc_subnetwork_us_central1" {
  name = "default"
  network = google_compute_network.vpc_network.name
  ip_cidr_range = "10.1.0.0/20"
  region = var.vpc_subnetwork_region
  private_ip_google_access = true
}

#cloud router required for NAT
resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.vpc_network.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-gw"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

#IAP setup
#add firewall rule
resource "google_compute_firewall" "fw_rule_iap" {
  name          = "iap-fw"
  network       = google_compute_network.vpc_network.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_project_organization_policy" "disable_require_shielded_vm" {
  project    = var.project_id
  constraint = "compute.requireShieldedVm"

  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "trusted_image_policy" {
  project    = var.project_id
  constraint = "compute.trustedImageProjects"

  list_policy {
    allow {
      all = true
    }
  }
}

# Data source to get information about the current project
data "google_project" "project" {
     project_id = var.project_id
     }

# Grant the editor role to the Compute Engine default service account
resource "google_project_iam_member" "compute_default_sa_editor" {
  project = data.google_project.project.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [ google_project_service.compute_api ]
}
