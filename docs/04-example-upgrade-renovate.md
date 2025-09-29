# Example 4 - renovate & autolabels

## Autolabels

Cluster 3 should be upgraded. If not:

```
./scripts/upgrade-talos-argocd-downstream-cluster.sh talos-argocd-1
```

1. Check Chart.yaml for cert-manager: not the same versions

2. Go to Argocd web interface, on clusters and check versions

3. See cert-manager diff, update

## Renovate

Go to Github, apply some merge

Note that there is no proposition for goldilocks

## End - App of Apps

Set the App Of Apps pattern

```
kubectl apply -f argocd/applications/app-of-apps/infra-apps.yaml 
```