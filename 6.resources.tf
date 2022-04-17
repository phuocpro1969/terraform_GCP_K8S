resource "null_resource" "lb_provisilboner" {
  triggers = {
    public_ip = google_compute_instance.lb-instance.network_interface.0.access_config.0.nat_ip
  }

  connection {
    type        = "ssh"
    host        = google_compute_instance.lb-instance.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "file" {
    source      = var.ssh_folder
    destination = "/root/.ssh"
  }

  provisioner "remote-exec" {
    script = var.script_ssh
  }
}

resource "null_resource" "master_provisilboner" {
  triggers = {
    public_ips = join(",", google_compute_instance.master-instance.*.network_interface.0.access_config.0.nat_ip)
  }

  count = var.master-count

  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance[count.index].network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

   provisioner "file" {
    source      = var.ssh_folder
    destination = "/root/.ssh"
  }

  provisioner "remote-exec" {
    script = var.script_ssh
  }
}

resource "null_resource" "only_master_1_provisilboner" {
  triggers = {
    nat_ip               = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip,
    self_link            = google_compute_instance.master-instance.0.self_link,
    desired_status       = google_compute_instance.master-instance.0.desired_status,
    metadata_fingerprint = google_compute_instance.master-instance.0.metadata_fingerprint,
  }

  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "file" {
    source      = var.k8s_folder
    destination = "/root"
  }

  provisioner "file" {
    source      = var.helm_folder
    destination = "/root"
  }

  provisioner "remote-exec" {
    script = var.script_install_package
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "echo 'EXTERNAL_IPS=${join(",", google_compute_instance.master-instance.*.network_interface.0.access_config.0.nat_ip)}' | tee -a /etc/environment",
      ". /etc/environment",
	    "chmod +x /root/**/*.sh",
      ". $HOME/k8s/init.sh",
      ". $HOME/helm/init.sh ${var.harbor_domain} ${var.harbor_username} ${var.harbor_password}",
    ]
  }
}
