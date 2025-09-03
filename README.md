# argocd-demo

## setup

Local clusters:

```
docker network create --driver bridge --subnet=172.30.0.0/16 talos-shared
talosctl cluster create --name talos-argo-1 --cidr 10.5.0.0/24
talosctl cluster create --name talos-argo-2 --cidr 10.6.0.0/24
talosctl cluster create --name talos-argo-3 --cidr 10.7.0.0/24
talosctl cluster create --name talos-argo-4 --cidr 10.8.0.0/24
```
```
docker network connect --ip 172.30.0.11 talos-shared talos-argo-1-controlplane-1
docker network connect --ip 172.30.0.12 talos-shared talos-argo-1-worker-1
docker network connect --ip 172.30.0.21 talos-shared talos-argo-2-controlplane-1
docker network connect --ip 172.30.0.22 talos-shared talos-argo-2-worker-1
docker network connect --ip 172.30.0.31 talos-shared talos-argo-3-controlplane-1
docker network connect --ip 172.30.0.32 talos-shared talos-argo-3-worker-1
docker network connect --ip 172.30.0.41 talos-shared talos-argo-4-controlplane-1
docker network connect --ip 172.30.0.42 talos-shared talos-argo-4-worker-1
```

```
talosctl --context talos-argo-2 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argo-2-patch.yaml
talosctl --context talos-argo-3 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argo-3-patch.yaml
talosctl --context talos-argo-4 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argo-4-patch.yaml
```


Install ArgoCD

```
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
