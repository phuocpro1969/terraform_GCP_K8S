resource "google_compute_instance" "lb-instance" {
  name         = "lb"
  machine_type = var.machine_type
  zone         = var.region

  tags = [
    "${var.network}-firewall-ssh",
    "${var.network}-firewall-http",
    "${var.network}-firewall-https",
    "${var.network}-firewall-icmp",
    "${var.network}-firewall-internal",
    "${var.network}-firewall-k8s"
  ]

  boot_disk {
    initialize_params {
      image = var.ubuntu
      size  = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.network_subnetwork.name
    network_ip = "10.20.0.10"
    access_config {
      // Ephemeral IP
      nat_ip = google_compute_address.lb.address
    }
  }

  metadata = {
    ssh-keys       = "${var.root}:${file(var.ssh_file_public)}"
    startup-script = <<-EOT

    ${file(var.script_install)}

    sudo tee -a /etc/environment <<-EOF
    MASTER_COUNT=${var.master-count}
    WORKER_COUNT=${var.worker-count}
    EOF

    . /etc/environment

    sudo echo "${var.root}:${var.root_password}" | sudo chpasswd

    ${file(var.script_add_host)}

    ${file(var.script_install_proxy)}

    ${file(var.script_install_docker)}

    ${file(var.script_install_kubernetes)}
    EOT
  }

  can_ip_forward = true

  # service_account {
  #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  #   email  = google_service_account.default.email
  #   scopes = ["cloud-platform"]
  # }
}


resource "google_compute_instance" "master-instance" {
  count        = var.master-count
  name         = "master${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.region

  tags = [
    "${var.network}-firewall-ssh",
    "${var.network}-firewall-http",
    "${var.network}-firewall-https",
    "${var.network}-firewall-icmp",
    "${var.network}-firewall-internal",
    "${var.network}-firewall-k8s"
  ]

  boot_disk {
    initialize_params {
      image = var.ubuntu
      size  = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.network_subnetwork.name
    network_ip = "10.20.0.1${count.index + 1}"

    access_config {
      // Ephemeral IP
      nat_ip = google_compute_address.master[count.index].address
    }
  }

  metadata = {
    ssh-keys       = "${var.root}:${file(var.ssh_file_public)}"
    startup-script = <<-EOT
    ${file(var.script_install)}
    sudo tee -a /etc/environment <<-EOF
    MASTER_COUNT="${var.master-count}"
    WORKER_COUNT="${var.worker-count}"
    EOF
    . /etc/environment

    sudo echo "${var.root}:${var.root_password}" | sudo chpasswd

    ${file(var.script_add_host)}

    ${file(var.script_install_docker)}

    ${file(var.script_install_kubernetes)}
    EOT
  }

  can_ip_forward = true

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = jsondecode(file(var.credentials_file_path)).client_email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "worker-instance" {
  count        = var.worker-count
  name         = "worker${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.region

  tags = [
    "${var.network}-firewall-ssh",
    "${var.network}-firewall-http",
    "${var.network}-firewall-https",
    "${var.network}-firewall-icmp",
    "${var.network}-firewall-internal",
    "${var.network}-firewall-k8s"
  ]

  boot_disk {
    initialize_params {
      image = var.ubuntu
      size  = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.network_subnetwork.name
    network_ip = "10.20.0.2${count.index + 1}"
  }

  metadata = {
    ssh-keys       = "${var.root}:${file(var.ssh_file_public)}"
    startup-script = <<-EOT
    ${file(var.script_install)}
    sudo tee -a /etc/environment <<-EOF
    MASTER_COUNT="${var.master-count}"
    WORKER_COUNT="${var.worker-count}"
    EOF
    . /etc/environment

    sudo echo "${var.root}:${var.root_password}" | sudo chpasswd

    ${file(var.script_add_host)}

    ${file(var.script_install_docker)}

    ${file(var.script_install_kubernetes)}
    EOT
  }

  can_ip_forward = true

  # service_account {
  #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  #   email  = google_service_account.default.email
  #   scopes = ["cloud-platform"]
  # }
}
