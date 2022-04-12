resource "google_compute_network" "network" {
  name = var.network
}

resource "google_compute_subnetwork" "network_subnetwor" {
  name          = "${var.network}-subnetwork-${var.subnetwork-region}"
  region        = var.subnetwork-region
  network       = google_compute_network.network.self_link
  ip_cidr_range = "10.20.0.0/16"
}

resource "google_compute_address" "lb" {
  name   = "lb-public-address"
  region = var.subnetwork-region
}

resource "google_compute_address" "master" {
  count  = var.master-count
  name   = "master${count.index + 1}-public-address"
  region = var.subnetwork-region
}

