resource "null_resource" "worker_provisilboner" {
  triggers = {
    private_ip = google_compute_instance.worker-instance.0.network_interface.0.network_ip
  }

  connection {
    type        = "ssh"
    host        = google_compute_instance.worker-instance.0.network_interface.0.network_ip
    user        = var.user
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file)
  }

  provisioner "remote-exec" {
    scripts = [
      var.script_install
    ]
  }
}
