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

4. Check requests CPU with `talos-argocd-1` and `talos-argocd-2`

```shell
kubectl foreach -q -- get deploy -n vpa goldilocks-controller -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}"
```

5. Promote `talos-argocd-2` to production

```shell
kubecolor get secret argocd-cluster-talos-argocd-2 -o yaml

kubectl foreach -q -- get deploy -n vpa goldilocks-controller -o jsonpath="{.spec.template.spec.containers[0].imagePullPolicy}"

kubectl label secrets argocd-cluster-talos-argocd-2 argocd.argoproj.io/cluster-type=production --overwrite
```
