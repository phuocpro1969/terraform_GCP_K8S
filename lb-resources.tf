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
    private_key = file(var.ssh_file)
  }

  provisioner "file" {
    source      = "./login/"
    destination = "/home/phuocpro1969/.ssh"
  }

  provisioner "remote-exec" {
    scripts = [
      var.script_install,
      var.script_install_proxy,
    ]
  }
}
