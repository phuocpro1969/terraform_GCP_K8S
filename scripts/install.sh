#!/bin/bash

# update
sudo apt update -y

# disable firewall
sudo ufw disable

# disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# update settings for kubernetes network
sudo /bin/su -c "cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"

# install docker
sudo apt install -y git wget apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y && sudo apt install -y docker-ce
sudo service docker enable
sudo service docker restart
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker $(whoami)

# install docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# install kubernetes
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update -y && sudo apt install -y kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00
sudo apt update -y
