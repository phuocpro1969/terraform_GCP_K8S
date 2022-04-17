#!/bin/bash

# install kubernetes
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update -y && sudo apt install -y kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00

# update settings for kubernetes network
sudo tee -a /etc/sysctl.d/kubernetes.conf <<-EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# permissions kube
sudo chmod +x $(which kubeadm)
sudo chmod +x $(which kubectl)
sudo chmod +x $(which kubelet)