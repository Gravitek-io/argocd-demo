# argocd-demo

## setup

Management cluster :

```
./script/create-talos-argocd-manager.sh
```

Install ArgoCD

```
kubectx admin@talos-argocd-manager

helm upgrade --install --create-namespace --namespace argocd  argo-cd argo/argo-cd -f argocd/helm/custom-values.yaml --version 8.3.3

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443

open http://localhost:8080
```



Setup downstream clusters, projects, repositories and co

```
./script/create-talos-argocd-downstream.sh

./script/enroll-talos-argocd-downstream.sh
```

Enjoy!


## Destroy

```
./scripts/destroy-all.sh
```