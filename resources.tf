resource "null_resource" "lb_provisilboner" {
  triggers = {
    public_ip = google_compute_instance.lb-instance.network_interface.0.access_config.0.nat_ip
  }

  connection {
    type        = "ssh"
    host        = google_compute_instance.lb-instance.network_interface.0.access_config.0.nat_ip
    user        = var.user
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "file" {
    source      = var.ssh_folder
    destination = "/home/${var.user}/.ssh"
  }

  provisioner "file" {
    source      = var.script_add_host
    destination = "/tmp/add_host.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.user}/.ssh/scripts/config.sh",
      "sudo chmod +x /tmp/add_host.sh",
      "/bin/bash /home/${var.user}/.ssh/scripts/config.sh ${var.user}",
      "/bin/bash /tmp/add_host.sh ${var.master-count} ${var.worker-count}"
    ]
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
    user        = var.user
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "file" {
    source      = var.ssh_folder
    destination = "/home/${var.user}/.ssh"
  }

  provisioner "file" {
    source      = var.script_add_host
    destination = "/tmp/add_host.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.user}/.ssh/scripts/config.sh",
      "sudo chmod +x /tmp/add_host.sh",
      "sudo /bin/bash /home/${var.user}/.ssh/scripts/config.sh ${var.user}",
      "sudo /bin/bash /tmp/add_host.sh ${var.master-count} ${var.worker-count}"
    ]
  }

}

resource "null_resource" "only_master_1_provisilboner" {
  triggers = {
    public_ip = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
  }

  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.user
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "file" {
    source      = var.k8s_folder
    destination = "/home/${var.user}"
  }

  # provisioner "remote-exec" {
  #   inline = []
  # }
}
