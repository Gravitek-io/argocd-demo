#!/usr/bin/env bash

set -eu

CLUSTER_NAME="${CLUSTER_PREFIX}-manager"
LOCAL_NETWORK_SUBNET="${LOCAL_NETWORK_SUBNET_PREFIX}.0.0/24"

echo "[+] Création du réseau Docker..."
docker network create \
  --driver bridge \
  --subnet=${SHARED_NETWORK_SUBNET} ${SHARED_NETWORK_NAME} \
  || echo "Le réseau existe déjà."

# Vérification de l'existence du cluster
if docker container ls | grep -q "${CLUSTER_NAME}\b"; then
  echo "[!] Le cluster ${CLUSTER_NAME} existe déjà, création ignorée."
  exit 0
fi

# Manager
echo "[+] Création du cluster manager..."
talosctl cluster create \
  --name "${CLUSTER_NAME}" \
  --cidr ${LOCAL_NETWORK_SUBNET} \
  --kubernetes-version "${KUBERNETES_VERSION}"

echo "[+] Connexion de cluster manager au réseau ${SHARED_NETWORK_NAME}..."
docker network connect \
  --ip ${SHARED_NETWORK_SUBNET_PREFIX}.${IP_BASE} \
  ${SHARED_NETWORK_NAME} "${CLUSTER_NAME}-controlplane-1"
docker network connect \
  --ip ${SHARED_NETWORK_SUBNET_PREFIX}.$((IP_BASE + 1)) \
  ${SHARED_NETWORK_NAME} "${CLUSTER_NAME}-worker-1"

echo "[+] Setup terminé !"