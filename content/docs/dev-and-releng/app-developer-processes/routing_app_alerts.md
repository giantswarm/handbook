---
title: "How to route app alerts to a team"
description: |
  Routing app alerts via annotations in Chart.yaml or app CRs.
weight: 70
classification: public
---

## App CR Annotation

- If an App CR is annotated with `application.giantswarm.io/team`
this annotation takes precedence.

```sh
kubectl -n giantswarm annotate app app-exporter-unique application.giantswarm.io/team=halo

# port forwarding to the app-exporter service.
# kubectl -n giantswarm port-forward svc/app-exporter-unique 8000:8000
# Forwarding from 127.0.0.1:8000 -> 8000
# Forwarding from [::1]:8000 -> 8000
curl -s http://localhost:8000/metrics  | grep app-exporter
app_operator_app_info{app="app-exporter",catalog="control-plane-catalog",name="app-exporter-unique",namespace="giantswarm",status="deployed",team="halo",version="0.4.0"} 1
```

- Otherwise we check for team or owner annotations in the Helm Chart.yaml.
- If the annotation is missing for existing releases the team can be mapped via the app-exporter configmap.

## Team Annotation

- When a component is owned by a single team you just need to set the `application.giantswarm.io/team`
annotation in Chart.yaml.

```yaml
# Chart.yaml
apiVersion: "v1"
...
name: "app-exporter"
...
annotations:
  application.giantswarm.io/team: "batman"
```

- The annotation is added to the AppCatalogEntry CRs by `app-operator-unique`.

```sh
kubectl get appcatalogentry -A -l app.kubernetes.io/name=app-exporter,latest=true -o yaml | yq  '.items[].metadata.annotations'
"application.giantswarm.io/team": "batman"
```

- It is used by [app-exporter] to set the team label in app info metrics.

```sh
curl -s http://localhost:8000/metrics  | grep app-exporter
app_operator_app_info{app="app-exporter",catalog="control-plane-catalog",name="app-exporter-unique",namespace="giantswarm",status="deployed",team="batman",version="0.4.0"} 1
```

### Team label in resources

Team chart annotation should be propagated to a label for generated resources, because some alerts rely on the specific resource's labels.

The recommended solution is to define a list of common labels in a `_helpers` template, containing this:
```
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "batman" | quote }}
```

See [grafana app](https://github.com/giantswarm/grafana-app/blob/master/helm/grafana/templates/_helpers.tpl#L14) for reference.


## Owners Annotation

- When a component is owned by multiple teams you can set the `application.giantswarm.io/owners`
annotation in Chart.yaml.
- Ownership can be assigned by catalog e.g. `control-plane-catalog` and / or provider e.g. `aws`.

```yaml
apiVersion: v1
appVersion: v1.20.0
description: A Helm chart for the cluster autoscaler.
home: https://github.com/giantswarm/cluster-autoscaler-app
name: cluster-autoscaler-app
version: [[ .Version ]]
annotations:
  application.giantswarm.io/owners: |
    - catalog: control-plane-catalog
      team: biscuit
    - catalog: control-plane-test-catalog
      provider: aws
      team: biscuit
    - catalog: default
      provider: aws
      team: firecracker
    - catalog: default
      provider: azure
      team: celestial
```
