#!/usr/bin/env bash

set -eu

CLUSTER_NAME=${1:-talos-argocd-3}
CLUSTER_NEXT_VERSION="1.34.0"

SERVER_URL=$(yq ".clusters[] | select(.name == \"${CLUSTER_NAME}\") | .cluster.server" kubeconfig)

OLD_URL=$(talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 get mc -o yaml | yq '.spec | fromyaml | .cluster.controlPlane.endpoint' | | grep '^https' | head -n1)

echo "Server URL for ${CLUSTER_NAME}: $OLD_URL -> $SERVER_URL"

# Patch MachineConfig to update the controlPlane endpoint, to make upgrade from localhost possible
talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 patch mc \
    --patch "[{\"op\": \"replace\", \"path\": \"/cluster/controlPlane/endpoint\", \"value\": \"${SERVER_URL}\"}]"

# Perform the upgrade
talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 upgrade-k8s --to ${CLUSTER_NEXT_VERSION}

# Reset the controlPlane endpoint to the original value
talosctl --context ${CLUSTER_NAME} -n 127.0.0.1 patch mc \
    --patch "[{\"op\": \"replace\", \"path\": \"/cluster/controlPlane/endpoint\", \"value\": \"${OLD_URL}\"}]"

# Restart the nodes to apply the original configuration
docker container restart ${CLUSTER_NAME}-controlplane-1 ${CLUSTER_NAME}-worker-1