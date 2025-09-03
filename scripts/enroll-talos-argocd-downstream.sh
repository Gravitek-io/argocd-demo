#!/usr/bin/env bash

set -eu

# the name of the secret containing the service account token goes here
SERVICE_ACCOUNT=argocd-manager
NAMESPACE=kube-system
CLUSTER_MANAGER_NAME="${CLUSTER_PREFIX}-manager"
DOWNSTREAM_CLUSTERS_BASE_API_IP="172.30.0."

for i in $(seq 1 ${CLUSTER_COUNT}); do

  CLUSTER_NAME="${CLUSTER_PREFIX}-${i}"
  SHARED_CP_IP="${SHARED_NETWORK_SUBNET_PREFIX}.$((IP_BASE + i*IP_STEP))"

  context="admin@${CLUSTER_NAME}"
  kubectl --context ${context} apply -f argocd/argocd-manager
  ca=$(kubectl --context ${context} -n ${NAMESPACE} get secret/${SERVICE_ACCOUNT}-token -o jsonpath='{.data.ca\.crt}')
  token=$(kubectl --context ${context} -n ${NAMESPACE} get secret/${SERVICE_ACCOUNT}-token -o jsonpath='{.data.token}' | base64 --decode)

  cat <<EOF > secret-cluster-${CLUSTER_NAME}.yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  labels:
    argocd.argoproj.io/auto-label-cluster-info: "true"
    argocd.argoproj.io/cluster-name: ${CLUSTER_NAME}
    argocd.argoproj.io/cluster-type: development
    argocd.argoproj.io/secret-type: cluster
  name: argocd-cluster-${CLUSTER_NAME}
  namespace: argocd
stringData:
  config: |-  
    { "bearerToken": "${token}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${ca}"
      }
    }
  name: ${CLUSTER_NAME}
  server: https://${SHARED_CP_IP}:6443
EOF

  kubectl --context admin@${CLUSTER_MANAGER_NAME} apply -f secret-cluster-${CLUSTER_NAME}.yaml
  rm secret-cluster-${CLUSTER_NAME}.yaml

done

# Set up projects, repos, app-of-apps
kubectl --context admin@${CLUSTER_MANAGER_NAME} apply -f argocd/repositories/
kubectl --context admin@${CLUSTER_MANAGER_NAME} apply -f argocd/applications/app-of-apps/
