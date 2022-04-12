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
    private_key = file(var.ssh_file)
  }

  provisioner "file" {
    source      = "./login/"
    destination = "/home/phuocpro1969/.ssh"
  }

  provisioner "remote-exec" {
    script = var.script_install
  }
}
