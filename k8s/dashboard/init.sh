#!/bin/bash

CURRENT_DIR=$HOME/k8s/dashboard

# install k8s dashboard
kubectl apply -f $CURRENT_DIR/dashboard.yaml

# create certs
# Create certs k8s dashboard
mkdir $CURRENT_DIR/certs_db
chmod +x $CURRENT_DIR/certs_db
openssl req -nodes -newkey rsa:2048 -keyout $CURRENT_DIR/certs_db/dashboard.key -out $CURRENT_DIR/certs_db/dashboard.csr -subj "/C=US/ST=US/L=US/O=US/OU=US/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 3650 -in $CURRENT_DIR/certs_db/dashboard.csr -signkey $CURRENT_DIR/certs_db/dashboard.key -out $CURRENT_DIR/certs_db/dashboard.crt
chmod +x $CURRENT_DIR/certs_db

# apply cert
kubectl create secret generic kubernetes-dashboard-certs --from-file=$CURRENT_DIR/certs_db -n kubernetes-dashboard

# Apply user-Admin
kubectl apply -f $CURRENT_DIR/admin-user.yaml

# Apply metrics to k8s dashboard
kubectl apply -f $CURRENT_DIR/metrics.yaml

# add external IP for loadbalancer
IFS=',' read -ra array <<< $EXTERNAL_IPS
sed "s/IPS/${array[1]}/" $CURRENT_DIR/temp.yaml > $CURRENT_DIR/config.yaml
kubectl patch svc -n kubernetes-dashboard kubernetes-dashboard --patch-file $CURRENT_DIR/config.yaml
