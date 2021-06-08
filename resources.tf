provider "google" {
    project = "upbeat-sunspot-314403"
    region = "asia-south1"
    zone =  "asia-south1-a"
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-network"    
    ip_cidr_range = "10.0.0.0/16 "
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "private_subnet1" {
    name = "private-subnet1"
    ip_cidr_range = "10.0.0.0/24"
    network = google_compute_network.vpc_network.id
    region = "asia-south1"
}

resource "google_compute_subnetwork" "private_subnet2" {
    name = "private-subnet2"
    ip_cidr_range = "10.0.1.0/24"
    network = google_compute_network.vpc_network.id
    region = "asia-south1"
}

resource "google_compute_subnetwork" "pub_subnet1" {
    name = "pub-subnet1"
    ip_cidr_range = "10.0.2.0/24"
    network = google_compute_network.vpc_network.id
    region = "asia-south1"
}

resource "google_compute_firewall" "firewall" {
    name = "firewall"
    network = google_compute_network.vpc_network.id

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "default" {
  name        = "network-router"
  dest_range  = "15.0.0.0/24"
  network     = google_compute_network.vpc_network.id
  priority    = 100
}

resource "google_compute_router_nat" "nat_manual" {
  name   = "my-router-nat"
  router = google_compute_router.router.name
  region = "asia-south1"

  nat_ip_allocate_option = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}