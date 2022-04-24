resource "null_resource" "lb" {
  depends_on = [google_compute_instance.lb-instance]

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

resource "null_resource" "master" {
  depends_on = [google_compute_instance.master-instance]

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

resource "time_sleep" "wait_master1_add_ssh" {
  depends_on = [
	null_resource.master.0,
	google_compute_instance.master-instance[0]
  ]

  create_duration = "30s"
}

resource "null_resource" "master1_add_data" {
  depends_on = [
	google_compute_instance.master-instance[0]
  ]

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
}

resource "time_sleep" "wait_master1_creating" {
  depends_on = [
	google_compute_instance.master-instance[0]
  ]

  create_duration = "30s"
}

resource "null_resource" "master_1_install_package" {
  depends_on = [
	google_compute_instance.master-instance.0,
	time_sleep.wait_master1_creating
  ]

  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    script = var.script_install_package
  }
}

resource "null_resource" "master1_install_k8s" {
  depends_on = [
	time_sleep.wait_master1_add_ssh,
	null_resource.master_1_install_package
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "echo 'EXTERNAL_IPS=${join(",", google_compute_instance.master-instance.*.network_interface.0.access_config.0.nat_ip)}' | tee -a /etc/environment",
      ". /etc/environment",
      "chmod +x /root/**/*.sh",
      ". $HOME/k8s/init.sh"
    ]
  }
}

resource "time_sleep" "wait_master1_install_k8s" {
  depends_on = [
	null_resource.master1_install_k8s
  ]

  create_duration = "30s"
}

resource "null_resource" "master1_install_k8s_dashboard" {
  depends_on = [
	time_sleep.wait_master1_install_k8s
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      ". $HOME/k8s/dashboard/init.sh"
    ]
  }
}

resource "null_resource" "master1_install_helm" {
  depends_on = [
	time_sleep.wait_master1_install_k8s
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      ". $HOME/helm/init.sh"
    ]
  }
}

resource "time_sleep" "wait_master1_install_helm" {
  depends_on = [
	null_resource.master1_install_helm
  ]

  create_duration = "30s"
}

resource "null_resource" "master1_install_longhorn" {
  depends_on = [
	time_sleep.wait_master1_install_helm
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      ". $HOME/helm/longhorn/init.sh"
    ]
  }
}

resource "null_resource" "master1_install_harbor" {
  depends_on = [
	time_sleep.wait_master1_install_helm
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.master-instance.0.network_interface.0.access_config.0.nat_ip
    user        = var.root
    port        = var.ssh_port
    agent       = false
    private_key = file(var.ssh_file_private)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      ". $HOME/helm/harbor/init.sh ${var.harbor_domain} ${var.harbor_username} ${var.harbor_password}"
    ]
  }
}