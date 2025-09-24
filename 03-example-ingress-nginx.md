# Example 3 - ingress-nginx

ApplicationSet with Git Generator

1. Install nginx via helm on 3rd cluster, with incorrect ns

```
kctx admin@talos-argocd-3
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install -n nginx --create-namespace nginx ingress-nginx/ingress-nginx --version 4.11.6 --set controller.service.type=NodePort
kubecolor get all -n nginx
```

2. Show folders resources, manifests, etc.
  - argocd/applications/infra/03-ingress-nginx-helm.yaml

3. Show `json` file!
  - resources/helm-charts/clusters/talos-argocd-3/ingress-nginx/params.json

4. Apply manifests

```shell
kubectx admin@talos-argocd-manager

kubectl apply -f argocd/applications/infra/03-ingress-nginx-helm.yaml
```

5. Upgrade cluster, for next demo

```
./scripts/upgrade-talos-argocd-downstream-cluster.sh talos-argocd-3
```
