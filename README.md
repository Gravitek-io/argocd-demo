# argocd-demo

## setup

Local clusters:

```
export KUBECONFIG=${PWD}/kubeconfig
./setup/create-talos-multi.sh
```


Install ArgoCD

```
kubectx admin@talos-argocd-manager

helm upgrade --install --create-namespace --namespace argocd  argo-cd argo/argo-cd -f argocd/helm/custom-values.yaml --version 7.9.1

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443

open http://localhost:8080
```


Setup downstream clusters, projects, repositories and co

```
./setup/generate-cluster-secret.sh
```

Enjoy!


## Destroy

```
talosctl config context talos-1 # Set other talos context

talosctl cluster destroy --name talos-argocd-manager
talosctl config remove talos-argocd-manager -y
kubectl config delete-cluster talos-argocd-manager
kubectl config delete-user admin@talos-argocd-manager
kubectl config delete-context admin@talos-argocd-manager


talosctl cluster destroy --name talos-argocd-1
talosctl config remove talos-argocd-1 -y
kubectl config delete-cluster talos-argocd-1
kubectl config delete-user admin@talos-argocd-1
kubectl config delete-context admin@talos-argocd-1

talosctl cluster destroy --name talos-argocd-2
talosctl config remove talos-argocd-2 -y
kubectl config delete-cluster talos-argocd-2
kubectl config delete-user admin@talos-argocd-2
kubectl config delete-context admin@talos-argocd-2 
```