#!/bin/bash

# install longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update

# array=(${EXTERNAL_IPS//,/ })
# for ip in ${array[*]}; do
#     echo "      - $ip"
# done > /root/public_ips.txt

helm install longhorn longhorn/longhorn -n longhorn-system --create-namespace -f $HOME/helm/longhorn/values.yaml
