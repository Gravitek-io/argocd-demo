#!/usr/bin/env bash

#set -ex

# the name of the secret containing the service account token goes here
SERVICE_ACCOUNT=argocd-manager
NAMESPACE=kube-system
ADMIN_CLUSTER="talos-argo-manager"
DOWNSTREAM_CLUSTERS=("talos-argo-1" "talos-argo-2" "talos-argo-3" "talos-argo-4")
DOWNSTREAM_CLUSTERS_BASE_API_IP="172.30.0."

ip_suffix=111 # talos-argo-1 -> 111, talos-argo-2 -> 121, talos-argo-3 -> 131, talos-argo-4 -> 141

for cluster in "${DOWNSTREAM_CLUSTERS[@]}"; do
  context="admin@${cluster}"
  kubectl --context ${context} apply -f argocd/argocd-manager
  ca=$(kubectl --context ${context} -n ${NAMESPACE} get secret/${SERVICE_ACCOUNT}-token -o jsonpath='{.data.ca\.crt}')
  token=$(kubectl --context ${context} -n ${NAMESPACE} get secret/${SERVICE_ACCOUNT}-token -o jsonpath='{.data.token}' | base64 --decode)

  cat <<EOF > secret-cluster-${cluster}.yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  labels:
    argocd.argoproj.io/auto-label-cluster-info: "true"
    argocd.argoproj.io/cluster-name: ${cluster}
    argocd.argoproj.io/cluster-type: development
    argocd.argoproj.io/secret-type: cluster
  name: argocd-cluster-${cluster}
  namespace: argocd
stringData:
  config: |-  
    { "bearerToken": "${token}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${ca}"
      }
    }
  name: ${cluster}
  server: https://${DOWNSTREAM_CLUSTERS_BASE_API_IP}${ip_suffix}:6443
EOF

  kubectl --context admin@${ADMIN_CLUSTER} apply -f secret-cluster-${cluster}.yaml
  rm secret-cluster-${cluster}.yaml
  ip_suffix=$((ip_suffix+10))
done

# Set up projects, repos, app-of-apps
kubectl --context admin@${ADMIN_CLUSTER} apply -f argocd/projects/
kubectl --context admin@${ADMIN_CLUSTER} apply -f argocd/repositories/
kubectl --context admin@${ADMIN_CLUSTER} apply -f argocd/applications/app-of-apps/
