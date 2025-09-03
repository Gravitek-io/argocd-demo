#!/usr/bin/env bash

set -e

# Downstream clusters
for i in $(seq 1 ${CLUSTER_COUNT}); do

  LOCAL_NETWORK_SUBNET="${LOCAL_NETWORK_SUBNET_PREFIX}.$((i*10)).0/24"
  SHARED_CP_IP="${SHARED_NETWORK_SUBNET_PREFIX}.$((IP_BASE + i*IP_STEP))"
  SHARED_WK_IP="${SHARED_NETWORK_SUBNET_PREFIX}.$((IP_BASE + i*IP_STEP + 1))"
  LOCAL_CP_IP="${LOCAL_NETWORK_SUBNET_PREFIX}.$((i*10)).2"
  CLUSTER_NAME="${CLUSTER_PREFIX}-${i}"

  # Vérification de l'existence du cluster
  if docker container ls | grep -q "${CLUSTER_NAME}\b"; then
    echo "[!] Le cluster ${CLUSTER_NAME} existe déjà, création ignorée."
    continue
  fi

  echo "[+] Création du cluster CLUSTER_NAME avec CIDR ${LOCAL_NETWORK_SUBNET}..."
  talosctl cluster create \
    --name "${CLUSTER_NAME}" \
    --cidr "${LOCAL_NETWORK_SUBNET}" \
    --config-patch-control-plane "[{\"op\": \"replace\", \"path\": \"/cluster/apiServer/certSANs\", \"value\": [\"${SHARED_CP_IP}\", \"${LOCAL_CP_IP}\", \"127.0.0.1\" ]}]"

  echo "[+] Connexion du downstream cluster ${CLUSTER_NAME} au réseau ${SHARED_NETWORK_NAME}..."
  docker network connect \
    --ip ${SHARED_CP_IP} \
    ${SHARED_NETWORK_NAME} "${CLUSTER_NAME}-controlplane-1"
  docker network connect \
    --ip ${SHARED_WK_IP} \
    ${SHARED_NETWORK_NAME} "${CLUSTER_NAME}-worker-1"

done

echo "[+] Setup terminé !"