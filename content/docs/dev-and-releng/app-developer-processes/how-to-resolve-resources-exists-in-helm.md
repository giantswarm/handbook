---
title: "How to resolve resources already exists in helm manifest"
weight: 20
classification: public
---

### Problem

- In some cases, the user could not install/upgrade helm release because some resources exist in clusters already.
```
helm install helm/cert-manager-app --name cert-manager-app --namespace cert-manager-app --values helm/cert-manager-app/values.yaml
Error: serviceaccounts "cert-manager-giantswarm-clusterissuer" already exists
```

### How to solve it
- From helm `3.2.0`, you could add helm label and annotations into dangling objects and helm would adopt them as one of their manifests.

To solve the above example, we could put the following label, annotations as below.
```
KIND=serviceaccount
NAME=cert-manager-giantswarm-clusterissuer
RELEASE=cert-manager-app
NAMESPACE=giantswarm
kubectl -n $NAMESPACE annotate $KIND $NAME meta.helm.sh/release-name=$RELEASE
kubectl -n $NAMESPACE annotate $KIND $NAME meta.helm.sh/release-namespace=$NAMESPACE
kubectl -n $NAMESPACE label $KIND $NAME app.kubernetes.io/managed-by=Helm
```

Now run helm install/upgrade again, and you will find it is now part of helm manifest.
