#!/bin/bash

# add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# array=(${EXTERNAL_IPS//,/ })

# install
sed  "s/DOMAIN/$1/ " $HOME/helm/harbor/values.yaml | sed "s/USERNAME/$2/" | sed "s/PASSWORD/$3/"| helm install harbor bitnami/harbor  -n harbor-system --create-namespace

# edit loadbalancer IP
IFS=',' read -ra array <<< $EXTERNAL_IPS
sed "s/IPS/${array[1]}/" $HOME/helm/harbor/temp.yaml > $HOME/helm/harbor/config.yaml
kubectl patch svc -n harbor-system harbor --patch-file $HOME/helm/harbor/config.yaml