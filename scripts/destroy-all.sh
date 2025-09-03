#!/usr/bin/env bash

set -e

talosctl config context talos-1
kubectx -u

# Manager
CLUSTER_NAME="${CLUSTER_PREFIX}-manager"

if ! docker container ls | grep -q "${CLUSTER_NAME}\b"; then
    echo "[!] Le cluster ${CLUSTER_NAME} n'existe plus, suppression ignorée."
else
    echo "[!] Suppression du clutter ${CLUSTER_NAME}..."
    talosctl cluster destroy --name ${CLUSTER_NAME}
    talosctl config remove ${CLUSTER_NAME} -y
    kubectl config delete-cluster ${CLUSTER_NAME}
    kubectl config delete-user admin@${CLUSTER_NAME}
    kubectl config delete-context admin@${CLUSTER_NAME}
fi

# Downtream clusters
for i in $(seq 1 ${CLUSTER_COUNT}); do
    if ! docker container ls | grep -q "${CLUSTER_NAME}\b"; then
        echo "[!] Le cluster ${CLUSTER_NAME} n'existe plus, suppression ignorée."
        continue
    fi
    CLUSTER_NAME="${CLUSTER_PREFIX}-${i}"
    echo "[!] Suppression du clutter ${CLUSTER_NAME}..."
    talosctl cluster destroy --name ${CLUSTER_NAME}
    talosctl config remove ${CLUSTER_NAME} -y
    kubectl config delete-cluster ${CLUSTER_NAME}
    kubectl config delete-user admin@${CLUSTER_NAME}
    kubectl config delete-context admin@${CLUSTER_NAME}
done