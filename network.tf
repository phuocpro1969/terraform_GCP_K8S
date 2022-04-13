resource "google_compute_network" "network" {
  name = var.network
}

resource "google_compute_subnetwork" "network_subnetwork" {
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

resource "google_compute_address" "nat" {
  name   = "nat-public-address"
  region = var.subnetwork-region
}

resource "google_compute_router" "router" {
  name    = "${var.network}-router-${var.subnetwork-region}"
  region  = google_compute_subnetwork.network_subnetwork.region
  network = google_compute_network.network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network}-router-nat-${var.subnetwork-region}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
