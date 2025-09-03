#!/usr/bin/env bash
set -euo pipefail

# ================================
# Config
# ================================
NETWORK_NAME="talos-shared"
NETWORK_SUBNET="172.30.0.0/24"
BASE_API_IP="172.30.0."   # API servers: .2, .3, .4, ...
CLUSTERS=("talos-argo-1" "talos-argo-2") # liste des clusters
POD_CIDR_BASE=10          # génère des podCIDR distincts: 10.5.0.0/16, 10.6.0.0/16...
START_OCTET=5

# ================================
# Préparation réseau partagé
# ================================
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "[+] Creating shared Docker network $NETWORK_NAME ($NETWORK_SUBNET)"
  docker network create --driver bridge --subnet "$NETWORK_SUBNET" "$NETWORK_NAME"
else
  echo "[=] Docker network $NETWORK_NAME already exists"
fi

# ================================
# Création et configuration clusters
# ================================
i=11
octet=$START_OCTET

for cluster in "${CLUSTERS[@]}"; do
  echo
  echo "=== Creating cluster $cluster ==="
  POD_CIDR="${POD_CIDR_BASE}.${octet}.0.0/16"
  octet=$((octet+1))
  API_IP="${BASE_API_IP}${i}"
  i=$((i+1))

  # 1. Créer le cluster
  echo "[+] talosctl cluster create --name $cluster --cidr $POD_CIDR"
  talosctl cluster create --name "$cluster" --cidr "$POD_CIDR"

  # 2. Connecter les nœuds au réseau partagé
  echo "[+] Attaching $cluster containers to $NETWORK_NAME"
  for c in $(docker ps -q --filter "name=${cluster}-"); do
    if ! docker inspect "$c" | grep -q "$NETWORK_NAME"; then
      docker network connect "$NETWORK_NAME" "$c"
    fi
  done

  # 3. Donner IP fixe au controlplane principal
  CP=$(docker ps -q --filter "name=${cluster}-controlplane" | head -n1)
  echo "[+] Assigning fixed API IP $API_IP to $cluster controlplane ($CP)"
  docker network disconnect "$NETWORK_NAME" "$CP" || true
  docker network connect --ip "$API_IP" "$NETWORK_NAME" "$CP"

  # 4. Patch SAN dans machine config
  echo "[+] Fetching current machine config for $cluster"
  talosctl --context "$cluster" -n 127.0.0.1 get mc --output yaml > mc-$cluster.yaml

  echo "[+] Adding SAN $API_IP to API server certs"
  if command -v yq >/dev/null 2>&1; then
    yq -i ".cluster.apiServer.certSANs += [\"$API_IP\"]" mc-$cluster.yaml
  else
    echo "[-] yq not found, please install yq v4+" >&2
    exit 1
  fi

  echo "[+] Applying patched config"
  talosctl --context "$cluster" -n 127.0.0.1 apply-config --file mc-$cluster.yaml --mode=no-reboot

  # 5. Générer kubeconfig avec IP fixe
  echo "[+] Generating kubeconfig for $cluster"
  talosctl --context "$cluster" kubeconfig --force --nodes 127.0.0.1
  KUBECFG="kubeconfig-$cluster"
  sed "s#server: https://.*:6443#server: https://$API_IP:6443#g" kubeconfig > "$KUBECFG"
  echo "[✓] Wrote $KUBECFG"
done

echo
echo "[✓] All clusters created, SAN patched, kubeconfigs ready."
