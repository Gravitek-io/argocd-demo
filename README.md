# argocd-demo

## setup

Local clusters:

```
talosctl cluster create --name talos-argo-1
talosctl cluster create --name talos-argo-2 --cidr 10.6.0.0/24
talosctl cluster create --name talos-argo-3 --cidr 10.7.0.0/24
talosctl cluster create --name talos-argo-4 --cidr 10.8.0.0/24
```

