---
title: "Cordoning app and chart CRs"
weight: 20
---

# Overview

- We added cordon support to app and chart CRs for migrating from chartconfig
CRs to app CRs and from Helm 2 to Helm 3.
- These cordon annotations are added by app-operator and cluster-operator as
part of the automated upgrade process.
- But they can also be useful for maintenance or to mitigate incidents.

## Annotations

- For both CRs you need to add 2 annotations to the CR.
- `cordon-reason` should explain why you need to cordon the CR.
- `cordon-until` is how long you expect the cordon to be needed.

## cordon-until

- If `cordon-until` has expired the CR will **remain cordoned**.
- But the operator will update a metric and we will be alerted.
- This is so we don't forget about cordoned CRs.

## app CRD

- The CR is cordoned by adding these 2 annotation.

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  annotations:
    app-operator.giantswarm.io/cordon-reason: "Maintenance in progress"
    app-operator.giantswarm.io/cordon-until: "2020-06-04T18:53:41"
```

- You can add the annotations with these commands.

```bash
kubectl -n giantswarm annotate app app-operator-unique 'app-operator.giantswarm.io/cordon-reason'='Maintenance in progress'
kubectl -n giantswarm annotate app app-operator-unique 'app-operator.giantswarm.io/cordon-until'=$(date -v +1d '+%Y-%m-%dT%H:%M:%S)
```

- You can remove the annotations with these commands.

```bash
kubectl -n giantswarm annotate app chart-operator-unique chart-operator.giantswarm.io/cordon-reason-
kubectl -n giantswarm annotate app chart-operator-unique chart-operator.giantswarm.io/cordon-until-
```

## chart CRD

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: Chart
metadata:
  annotations:
    chart-operator.giantswarm.io/cordon-reason: "Maintenance in progress"
    chart-operator.giantswarm.io/cordon-until: "2020-06-04T18:53:41"
```

- You can add the annotations with these commands.

```bash
kubectl -n giantswarm annotate chart chart-operator-unique 'chart-operator.giantswarm.io/cordon-reason'='Maintenance in progress'
kubectl -n giantswarm annotate chart chart-operator-unique 'chart-operator.giantswarm.io/cordon-until'=$(date -v +1d '+%Y-%m-%dT%H:%M:%S)
```

- You can remove the annotations with these commands.

```bash
kubectl -n giantswarm annotate chart chart-operator-unique chart-operator.giantswarm.io/cordon-reason-
kubectl -n giantswarm annotate chart chart-operator-unique chart-operator.giantswarm.io/cordon-until-
```