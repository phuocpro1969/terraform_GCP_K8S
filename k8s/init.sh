#!/bin/bash

# wait package
 while ! which kubeadm >/dev/null; do echo "wait kubeadm"; sleep 1s; done

# init kubeadm to start
sudo kubeadm init --upload-certs --config /home/$1/k8s/init_k8s/init.yaml
sudo mkdir -p /home/$1/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/$1/.kube/config -n
sudo chown $(id -u):$(id -g) /home/$1/.kube/config

sudo chmod 600 /home/$1/.ssh/id_rsa

# export variables
sudo echo $(sudo kubeadm init phase upload-certs --upload-certs) | sudo tee /tmp/newCert.txt
STR="$(sudo head -n 1 /tmp/newCert.txt)"
CERT_KEY=${STR##* }

CERT_HASH=$(sudo openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
| sudo openssl rsa -pubin -outform der 2>/dev/null \
| sudo openssl dgst -sha256 -hex \
| sudo sed 's/^.* //')

for ((i=2; i<=$2; i++))
do
    echo "sudo kubeadm join 10.20.0.10:6443 \
        --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:$CERT_HASH \
        --control-plane \
        --certificate-key $CERT_KEY \
        --apiserver-advertise-address 10.20.0.1$i" \
        | ssh -o StrictHostKeyChecking=no "$1@master$i" -i /home/$1/.ssh/id_rsa

    echo " sudo mkdir -p /home/$1/.kube  && \
        sudo cp -i /etc/kubernetes/admin.conf /home/$1/.kube/config && \
        sudo chown $(id -u):$(id -g) /home/$1/.kube/config" \
        | ssh -o StrictHostKeyChecking=no "$1@master$i" -i /home/$1/.ssh/id_rsa
done

for ((i=1; i<=$3; i++))
do
    echo "sudo kubeadm join 10.20.0.10:6443 \
        --token abcdef.0123456789abcdef  \
        --discovery-token-ca-cert-hash sha256:$CERT_HASH" \
        | ssh -o StrictHostKeyChecking=no "$1@worker$i" -i /home/$1/.ssh/id_rsa
done