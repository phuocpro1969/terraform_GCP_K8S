#!/bin/bash

# install longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update

CURRENT_DIR=$HOME/helm/longhorn

# array=(${EXTERNAL_IPS//,/ })
# for ip in ${array[*]}; do
#     echo "      - $ip"
# done > /root/public_ips.txt
# array=(${EXTERNAL_IPS//,/ })
helm install longhorn longhorn/longhorn -n longhorn-system --create-namespace -f $CURRENT_DIR/values.yaml

# edit loadbalancer IP
IFS=',' read -ra array <<< $EXTERNAL_IPS
sed "s/IPS/${array[1]}/" $CURRENT_DIR/temp.yaml > $CURRENT_DIR/config.yaml
kubectl patch svc -n longhorn-system longhorn-frontend --patch-file $CURRENT_DIR/config.yaml
