# argocd-demo

## setup

Management cluster :

```
source .envrc

./scripts/create-talos-argocd-manager.sh
```

Install ArgoCD

```
kubectx admin@talos-argocd-manager

helm upgrade --install --create-namespace --namespace argocd  argo-cd argo/argo-cd -f argocd/helm/custom-values.yaml --version 8.5.6

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443

open http://localhost:8080
```



Setup downstream clusters, projects, repositories and co

```
./scripts/create-talos-argocd-downstream.sh

./scripts/enroll-talos-argocd-downstream.sh
```

Add apps

```shell
# Set up projects, repos, app-of-apps
kubectl --context admin@talos-argocd-manager apply -f argocd/repositories/
kubectl --context admin@talos-argocd-manager apply -f argocd/applications/app-of-apps/
```

Enjoy!

## Upgrade Talos cluster

```
./scripts/upgrade-talos-argocd-downstream-cluster.sh
```

## Destroy

```
./scripts/destroy-all.sh
```