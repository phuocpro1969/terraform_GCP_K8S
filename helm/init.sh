#!/bin/bash

# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

chmod +x /usr/local/bin/helm

helm plugin install https://github.com/chartmuseum/helm-push.git

# install argocd
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# chmod +x /usr/local/bin/argocd
