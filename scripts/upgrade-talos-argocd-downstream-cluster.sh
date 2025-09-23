#!/usr/bin/env bash

set -eu

CLUSTER_NAME="talos-argocd-3"
CLUSTER_NEXT_VERSION="1.34.0"

SERVER_URL=$(yq ".clusters[] | select(.name == \"${CLUSTER_NAME}\") | .cluster.server" kubeconfig)
echo "Server URL for ${CLUSTER_NAME}: $SERVER_URL"

talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 patch mc \
    --patch "[{\"op\": \"replace\", \"path\": \"/cluster/controlPlane/endpoint\", \"value\": \"${SERVER_URL}\"}]"

talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 upgrade-k8s --to ${CLUSTER_NEXT_VERSION}