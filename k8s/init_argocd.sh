#!/bin/bash
# wait package
while ! which helm >/dev/null; do echo "wait helm"; sleep 1s; done

helm plugin install https://github.com/chartmuseum/helm-push.git