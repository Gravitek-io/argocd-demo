# argocd-demo

## setup

Local clusters:

```
talosctl cluster create --name talos-argo-1
talosctl cluster create --name talos-argo-2 --cidr 10.6.0.0/24
talosctl cluster create --name talos-argo-3 --cidr 10.7.0.0/24
talosctl cluster create --name talos-argo-4 --cidr 10.8.0.0/24
```

Install ArgoCD

```
helm upgrade --install --create-namespace --namespace argocd  argo-cd argo/argo-cd -f argocd/helm/custom-values.yaml --version 7.9.1

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443

open http://localhost:8080
```

Define projects

```
kubectl apply -f argocd/projects/
```

Define Repository

```
kubectl apply -f argocd/repositories/
```

Define App Of Apps

```
kubectl apply -f argocd/applications/app-of-apps/
```

Enjoy!
