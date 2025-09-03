# argocd-demo

## setup

Local clusters:

```
docker network create --driver bridge --subnet=172.30.0.0/16 talos-shared
talosctl cluster create --name talos-argocd-manager --cidr 10.5.0.0/24
talosctl cluster create --name talos-argocd-1 --cidr 10.5.10.0/24
talosctl cluster create --name talos-argocd-2 --cidr 10.5.20.0/24
talosctl cluster create --name talos-argocd-3 --cidr 10.5.30.0/24
talosctl cluster create --name talos-argocd-3 --cidr 10.5.40.0/24
```
```
docker network connect --ip 172.30.0.101 talos-shared alos-argocd-manager-controlplane-1
docker network connect --ip 172.30.0.102 talos-shared talos-argocd-manager-worker-1
docker network connect --ip 172.30.0.111 talos-shared talos-argocd-1-controlplane-1
docker network connect --ip 172.30.0.112 talos-shared talos-argocd-1-worker-1
docker network connect --ip 172.30.0.121 talos-shared talos-argocd-2-controlplane-1
docker network connect --ip 172.30.0.122 talos-shared talos-argocd-2-worker-1
docker network connect --ip 172.30.0.131 talos-shared talos-argocd-3-controlplane-1
docker network connect --ip 172.30.0.132 talos-shared talos-argocd-3-worker-1
docker network connect --ip 172.30.0.141 talos-shared talos-argocd-4-controlplane-1
docker network connect --ip 172.30.0.142 talos-shared talos-argocd-4-worker-1
```

```
talosctl --context talos-argocd-1 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argocd-1-patch.yaml
talosctl --context talos-argocd-2 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argocd-2-patch.yaml
talosctl --context talos-argocd-3 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argocd-3-patch.yaml
talosctl --context talos-argocd-4 -n 127.0.0.1 patch mc --patch @setup/mc-talos-argocd-4-patch.yaml
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


## Destroy

```
talosctl cluster destroy --name talos-argocd-manager
talosctl config remove talos-argocd-manager 
```