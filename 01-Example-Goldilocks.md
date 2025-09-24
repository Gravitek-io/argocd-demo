# Example 1 - Goldilocks

"Simple" ApplicationSet with helm and values

1. Show folders resources, manifests, etc.

2. Apply manifest

```shell
source .envrc

kubectx admin@talos-argocd-manager

kubectl apply -f argocd/applications/infra/01-goldilocks-helm.yaml
```

3. Check on ArgoCD webapp

4. Promote `talos-argocd-2` to production

```shell
kubecolor get secret argocd-cluster-talos-argocd-2 -o yaml
kubectl label secrets argocd-cluster-talos-argocd-2 argocd.argoproj.io/cluster-type=production --overwrite
```

