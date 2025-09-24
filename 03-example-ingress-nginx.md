# Example 3 - ingress-nginx

ApplicationSet with Git Generator

1. Install nginx via helm on 3rd cluster, with incorrect ns

```
kctx admin@talos-argocd-3
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install -n nginx --create-namespace nginx ingress-nginx/ingress-nginx
kubecolor get pods -n nginx
```

2. Show folders resources, manifests, etc.
  - argocd/applications/infra/03-ingress-nginx-helm.yaml

3. Show `json` file!

4. Apply manifests


```shell
kubectx admin@talos-argocd-manager

kubectl apply -f argocd/applications/infra/03-ingress-nginx-helm.yaml
```

3. Check on ArgoCD webapp

4. Check logLevel `talos-argocd-1` and `talos-argocd-2`

```shell
kubectl foreach -q -- get deploy -n cert-manager cert-manager -o jsonpath="{.spec.template.spec.containers[0].args[0]}"
```

