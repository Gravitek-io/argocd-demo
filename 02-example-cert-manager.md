# Example 2 - cert-manager

ApplicationSet with Umbrella chart


1. Show folders resources, manifests, etc.
  - argocd/applications/infra/02-cert-manager-helm.yaml
  - resources/helm-charts/versions/1.33/cert-manager/Chart.yaml
  - resources/helm-charts/versions/1.33/cert-manager/values.yaml

2. Apply manifest

```shell
source .envrc

kubectx admin@talos-argocd-manager

kubectl apply -f argocd/applications/infra/02-cert-manager-helm.yaml
```

3. Check on ArgoCD webapp

4. Check logLevel `talos-argocd-1` and `talos-argocd-2`

```shell
kubectl foreach -q -- get deploy -n cert-manager cert-manager -o jsonpath="{.spec.template.spec.containers[0].args[0]}"
```

