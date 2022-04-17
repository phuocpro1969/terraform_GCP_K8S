#!/bin/bash

# create dir .kube
mkdir -p $HOME/.kube

# init permissions for ssh login hosts
chmod 600 $HOME/.ssh/id_rsa.pri

# Create certs k8s dashboard
mkdir $HOME/certs_db
chmod +x $HOME/certs_db
openssl req -nodes -newkey rsa:2048 -keyout $HOME/certs_db/dashboard.key -out $HOME/certs_db/dashboard.csr -subj "/C=US/ST=US/L=US/O=US/OU=US/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 3650 -in $HOME/certs_db/dashboard.csr -signkey $HOME/certs_db/dashboard.key -out $HOME/certs_db/dashboard.crt
chmod +x $HOME/certs_db

while ! which kubeadm >/dev/null; do echo "wait install kubeadm"; sleep 10s; done
while ! which kubectl >/dev/null; do echo "wait install kubectl"; sleep 10s; done
while ! which kubelet >/dev/null; do echo "wait install kubelet"; sleep 10s; done

kubeadm config images pull

if [ ! "$(systemctl is-active kubelet.service)" = "active" ]; then

# init kubeadm to start
kubeadm init --upload-certs --config $HOME/k8s/init_k8s/init.yaml
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config -n
chown 1000:1000 $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Create Calico CNI
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

# export variables
echo $(kubeadm init phase upload-certs --upload-certs) | tee /tmp/newCert.txt
STR="$(head -n 1 /tmp/newCert.txt)"
CERT_KEY=${STR##* }

CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
| openssl rsa -pubin -outform der 2>/dev/null \
| openssl dgst -sha256 -hex \
| sed 's/^.* //')

sudo tee -a  /etc/environment <<-EOF
KUBECONFIG=$HOME/.kube/config
CERT_KEY=$CERT_KEY
CERT_HASH=$CERT_HASH
EOF

. /etc/environment
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl label nodes master1 node-role.kubernetes.io/master=master
kubectl label nodes master1 role=master

for ((i=2; i<=$MASTER_COUNT; i++))
do
    echo "kubeadm join 10.20.0.10:6443 \
        --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:$CERT_HASH \
        --control-plane \
        --certificate-key $CERT_KEY \
        --apiserver-advertise-address 10.20.0.1$i" \
        | ssh -o StrictHostKeyChecking=no "$USER@master$i" -i $HOME/.ssh/id_rsa.pri

    echo "mkdir -p $HOME/.kube  && \
         cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
         chown 1000:1000 $HOME/.kube/config" \
        | ssh -o StrictHostKeyChecking=no "$USER@master$i" -i $HOME/.ssh/id_rsa.pri

    kubectl taint nodes master$i node-role.kubernetes.io/master-
    kubectl label node master$i node-role.kubernetes.io/master-
    kubectl label nodes master$i role=master
done

for ((i=1; i<=$WORKER_COUNT; i++))
do
    echo "kubeadm join 10.20.0.10:6443 \
        --token abcdef.0123456789abcdef  \
        --discovery-token-ca-cert-hash sha256:$CERT_HASH" \
        | ssh -o StrictHostKeyChecking=no "$USER@worker$i" -i $HOME/.ssh/id_rsa.pri

    kubectl label node worker$i node-role.kubernetes.io/worker-
    kubectl label nodes worker$i role=worker
done

# install k8s dashboard
kubectl apply -f $HOME/k8s/init_k8s/dashboard.yaml
kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs_db -n kubernetes-dashboard

# Apply user-Admin
kubectl apply -f $HOME/k8s/init_k8s/admin-user.yaml

# Apply metrics to k8s dashboard
kubectl apply -f $HOME/k8s/init_k8s/metrics.yaml

fi