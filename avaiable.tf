variable "region" {
  default = "us-central1-a"
}

variable "subnetwork-region" {
  default = "us-central1"
}

variable "project_name" {
  default = "learning-devops-341309"
}

variable "credentials_file_path" {
  default = "./terraform.json"
}

variable "machine_type" {
  default = "e2-standard-2"
}

variable "ubuntu" {
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "network" {
  default = "tf"
}

variable "user" {
  default = "phuocpro1969"
}

variable "ssh_file_private" {
  default = "./ssh/id_rsa"
}

variable "ssh_file_public" {
  default = "./ssh/id_rsa.pub"
}

variable "ssh_port" {
  default = 22
}

variable "master-count" {
  default = 2
}

variable "worker-count" {
  default = 1
}

variable "script_install" {
  default = "./scripts/install.sh"
}

variable "script_install_proxy" {
  default = "./scripts/install_proxy.sh"
}

variable "script_add_host" {
  default = "./scripts/add_host.sh"
}

variable "ssh_folder" {
  default = "./ssh/"
}

variable "k8s_folder" {
  default = "./k8s"
}
