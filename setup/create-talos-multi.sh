#!/bin/bash

set -e

# Nombre de clusters secondaires (hors manager)
CLUSTER_COUNT=2

# Préfixes
CLUSTER_PREFIX="talos-argocd"
SHARED_NETWORK_NAME="talos-shared"
SHARED_NETWORK_SUBNET_PREFIX="172.30.0."
LOCAL_NETWORK_SUBNET_PREFIX="10.5."

# Subnets de base
SHARED_NETWORK_SUBNET="${SHARED_NETWORK_SUBNET_PREFIX}.0/16"
LOCAL_NETWORK_SUBNET_BASE="${LOCAL_NETWORK_SUBNET_PREFIX}.0.0/24"

# IPs de base
IP_BASE=101
IP_STEP=10

echo "[+] Création du réseau Docker..."
docker network create --driver bridge --subnet=${NETWORK_SUBNET} ${SHARED_NETWORK_NAME} || echo "Le réseau existe déjà."

# Manager
echo "[+] Création du cluster manager..."
talosctl cluster create --name "${CLUSTER_PREFIX}-manager" --cidr ${LOCAL_NETWORK_SUBNET_BASE}

echo "[+] Connexion de cluster manager au réseau ${SHARED_NETWORK_NAME}..."
docker network connect --ip ${SHARED_NETWORK_SUBNET_PREFIX}.${IP_BASE} ${SHARED_NETWORK_NAME} "${CLUSTER_PREFIX}-manager-controlplane-1"
docker network connect --ip ${SHARED_NETWORK_SUBNET_PREFIX}.$((IP_BASE + 1)) ${SHARED_NETWORK_NAME} "${CLUSTER_PREFIX}-manager-worker-1"

# Downstream clusters
for i in $(seq 1 ${CLUSTER_COUNT}); do
  LOCAL_NETWORK_SUBNET="${LOCAL_NETWORK_SUBNET_PREFIX}.$((i*10)).0/24"
  SHARED_CP_IP=$((IP_BASE + i*IP_STEP))
  SHARED_WK_IP=$((IP_BASE + i*IP_STEP + 1))
  LOCAL_CP_IP="${LOCAL_NETWORK_SUBNET_PREFIX}.$((i*10)).2"

  echo "[+] Création du cluster ${CLUSTER_PREFIX}-${i} avec CIDR $LOCAL_NETWORK_SUBNET..."
  talosctl cluster create --name "${CLUSTER_PREFIX}-${i}" --cidr "$LOCAL_NETWORK_SUBNET"

  echo "[+] Connexion du downstream cluster ${CLUSTER_PREFIX}-${i} au réseau $SHARED_NETWORK_NAME..."
  docker network connect --ip 172.30.0.${SHARED_CP_IP} ${SHARED_NETWORK_NAME} "${CLUSTER_PREFIX}-${i}-controlplane-1"
  docker network connect --ip 172.30.0.${SHARED_WK_IP} ${SHARED_NETWORK_NAME} "${CLUSTER_PREFIX}-${i}-worker-1"

  echo "[+]  Application des patchs Talos..."
  talosctl --context "${CLUSTER_PREFIX}-$i" -n 127.0.0.1 patch mc \
    --patch "[{\"op\": \"add\", \"path\": \"/cluster/apiServer/certSANs\", \"value\": [\"${SHARED_CP_IP}\", \"${LOCAL_CP_IP}\", \"127.0.0.1\" ]}]"
done

echo "[+] Setup terminé !"