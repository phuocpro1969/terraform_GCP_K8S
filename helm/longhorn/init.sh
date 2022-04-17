#!/bin/bash

# install longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn -n longhorn-system --create-namespace -f $HOME/helm/longhorn/values.yaml
