#!/bin/bash

# add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# install
sed  "s/DOMAIN/$1/g " $HOME/helm/harbor/values.yaml | sed "s/USERNAME/$2/g" | sed "s/PASSWORD/$3/g" | helm install harbor bitnami/harbor  -n harbor --create-namespace --values -
