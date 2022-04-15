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

# add password to root
sudo echo "root:root" | sudo chpasswd
sudo echo "ubuntu:root" | sudo chpasswd
# sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
# sudo service sshd restart

# install docker
sudo apt install -y git wget apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y && sudo apt install -y docker-ce

sudo mkdir /etc/docker
sudo cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF

sudo service docker enable
sudo systemctl daemon-reload
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

sudo apt install snapd -y

# install helm && argocd
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# install packages
sudo snap install jq
sudo apt install -y unzip nc iproute iproute-doc