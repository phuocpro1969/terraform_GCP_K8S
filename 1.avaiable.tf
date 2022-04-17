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
  default = "root"
}

variable "ssh_file_private" {
  default = "./ssh/id_rsa.pri"
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
  default = "./scripts/init.sh"
}

variable "script_add_host" {
  default = "./scripts/add_host.sh"
}

variable "script_install_docker" {
  default = "./scripts/install_docker.sh"
}

variable "script_install_kubernetes" {
  default = "./scripts/install_kubernetes.sh"
}

variable "script_install_package" {
  default = "./scripts/install_package.sh"
}

variable "script_install_proxy" {
  default = "./scripts/install_proxy.sh"
}

variable "script_ssh" {
  default = "./scripts/ssh.sh"
}

variable "ssh_folder" {
  default = "./ssh/"
}

variable "k8s_folder" {
  default = "./k8s"
}

variable "helm_folder" {
  default = "./helm"
}

variable "harbor_domain" {
  default = "harbor-devops.tk"
}

variable "harbor_username" {
  default = "harbor"
}

variable "harbor_password" {
  default = "harbor"
}

variable "root" {
  default = "root"
}

variable "root_password" {
  default = "root"
}

variable "user_password" {
  default = "root"
}