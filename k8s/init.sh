#!/bin/bash

# wait package
while ! which kubeadm >/dev/null; do echo "wait kubeadm"; sleep 1s; done

# permissions kube
sudo chmod 777 $(which kubeadm)
sudo chmod 777 $(which kubectl)
sudo chmod 777 $(which kubelet)
sudo chmod 777 $(which helm)

# init kubeadm to start
sudo kubeadm init --upload-certs --config /home/$1/k8s/init_k8s/init.yaml
sudo mkdir -p /home/$1/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/$1/.kube/config -n
sudo chown 1000:1000 /home/$1/.kube/config

# Create Calico CNI
export KUBECONFIG=/home/$1/.kube/config
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

# init permissions for ssh login hosts
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
        sudo chown 1000:1000 /home/$1/.kube/config" \
        | ssh -o StrictHostKeyChecking=no "$1@master$i" -i /home/$1/.ssh/id_rsa
done

for ((i=1; i<=$3; i++))
do
    echo "sudo kubeadm join 10.20.0.10:6443 \
        --token abcdef.0123456789abcdef  \
        --discovery-token-ca-cert-hash sha256:$CERT_HASH" \
        | ssh -o StrictHostKeyChecking=no "$1@worker$i" -i /home/$1/.ssh/id_rsa
done

# kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl label nodes worker1 node-role.kubernetes.io/worker=worker
kubectl label nodes worker1 role=worker

# Create certs
sudo mkdir certs_db
sudo chmod 777 -R certs_db
sudo openssl req -nodes -newkey rsa:2048 -keyout certs_db/dashboard.key -out certs_db/dashboard.csr -subj "/C=US/ST=US/L=US/O=US/OU=US/CN=kubernetes-dashboard"
sudo openssl x509 -req -sha256 -days 3650 -in certs_db/dashboard.csr -signkey certs_db/dashboard.key -out certs_db/dashboard.crt
sudo chmod -R 777 certs_db

# install k8s dashboard
kubectl apply -f /home/$1/k8s/init_k8s/dashboard.yaml
kubectl create secret generic kubernetes-dashboard-certs --from-file=certs_db -n kubernetes-dashboard

# Apply user-Admin
kubectl apply -f /home/$1/k8s/init_k8s/admin-user.yaml

# Apply metrics to k8s dashboard
kubectl apply -f /home/$1/k8s/init_k8s/metrics.yaml
