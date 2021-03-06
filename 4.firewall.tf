resource "google_compute_firewall" "internal" {
  name    = "${var.network}-firewall-internal"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags   = ["${var.network}-firewall-internal"]
  source_ranges = ["10.20.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.network}-firewall-ssh"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["${var.network}-firewall-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name    = "${var.network}-firewall-http"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["${var.network}-firewall-http"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https" {
  name    = "${var.network}-firewall-https"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["${var.network}-firewall-https"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp" {
  name    = "${var.network}-firewall-icmp"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  target_tags   = ["${var.network}-firewall-icmp"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "k8s" {
  name    = "${var.network}-firewall-k8s"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["80-32000"]
  }

  target_tags   = ["${var.network}-firewall-k8s"]
  source_ranges = ["0.0.0.0/0"]
}
