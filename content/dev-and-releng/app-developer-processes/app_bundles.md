---
title: "App Bundles"
weight: 20
---

## Overview

For CAPI we have decided to deploy default apps via App Bundles.
See [ADR](https://intranet.giantswarm.io/docs/product/architecture-specs-adrs/adr/016-capi-releases/)

An App Bundle is an App CR that is created in the management cluster and groups
multiple workload cluster apps. This makes installation simpler and means we can
retire the [Release](https://docs.giantswarm.io/ui-api/management-api/crd/releases.release.giantswarm.io/)
CRD used in vintage clusters.

A `default-apps-PROVIDER` app will exist for each CAPI provider.

We also provide App Bundles that group apps related to a topic
e.g. `security-pack`.

## Creating a new App Bundle

It's recommended to base new App Bundles on the SOTA (State of the Art) App Bundle.

For default apps this is [default-apps-openstack](https://github.com/giantswarm/default-apps-openstack)
and the app should be published to the [cluster-catalog](https://github.com/giantswarm/cluster-catalog).

For other bundles this is [security-pack](https://github.com/giantswarm/security-pack).

## Installing an App Bundle

An App Bundle can be installed via `kubectl gs template app` using the
`--in-cluster` flag.

```nohighlight
$ kubectl gs template app \
--catalog giantswarm \
--name security-pack \
--in-cluster \
--namespace demo1 \ 
--version 0.1.0 \
--user-configmap user-values.yaml
```

We wish to automate the setting of the `--in-cluster` flag by adding an annotation
to the bundle apps Chart.yaml that will be added to its AppCatalogEntry CR where
it can be accessed by front end components. However this is not yet implemented.

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  labels:
    app-operator.giantswarm.io/version: 0.0.0
    giantswarm.io/managed-by: flux
  name: security-pack
  namespace: demo1
spec:
  catalog: giantswarm
  kubeConfig:
    inCluster: true
  name: security-pack
  namespace: demo1
  version: 0.1.0
```

- The `app-operator.giantswarm.io/version` label must have the value `0.0.0`.
- `.spec.kubeConfig.inCluster` must be `true`.
- `.spec.namespace` must match the namespace used for workload cluster apps.
This is the org namespace for CAPI and the cluster namespace for vintage.

Note: Any other value for `.spec.namespace` will be blocked by `app-admission-controller`
this is a security requirement to prevent the user escaping their Management API
permissions.

## Child Apps

The child apps are templated via the App Bundles helm chart. These examples
are taken from the `security-pack` Helm chart.

```yaml
# values.yaml
apps:
  falco:
    appName: falco
    chartName: falco-app
    catalog: giantswarm
    enabled: true
    namespace: security-pack
    version: 0.3.2
```

Each child app should have the `giantswarm.io/managed-by` label set to the name
of the parent app e.g. `default-apps-openstack`. This identifies the parent app
CR and means the install [is not blocked](https://docs.giantswarm.io/app-platform/defaulting-validation/#gitops-support) 
by `app-admission-controller`.

```nohighlight
giantswarm.io/managed-by: {{ .Release.Name | quote }}
```

For CAPI the child app CRs should be created in the org namespace and have a
cluster name prefix e.g. `dev01-coredns`.

For vintage clusters the child app CRs should be created in the cluster namespace
and should not have the cluster name prefix.

This can be done via a template helper.

```nohighlight
# templates/_helpers.tpl
{{/*
When apps are created in the org namespace add a cluster prefix.
*/}}
{{- define "app.name" -}}
{{- if ne .cluster .ns -}}
{{- printf "%s-%s" .cluster .app -}}
{{- else -}}
{{- .app -}}
{{- end -}}
{{- end -}}

# templates/apps.yaml 
{{- $appName := include "app.name" (dict "app" .appName "cluster" $.Values.clusterName "ns" $.Release.Namespace) }}
```

## User Values

Each child app in the bundle needs to be configurable. This is done via the
`values.yaml` of the app bundle's helm chart which needs to pass values to the
child apps.

This relies heavily on helm templating so care needs to be taken and ideally
there should be test coverage for this.

```yaml
userConfig:
  trivy:
    configMap:
      values: |
        trivy:
          networkPolicy:
            enabled: true
```

## GitOps Support

There is a problem with using GitOps and the app bundles concept. The user values
are passed via a `values` key and a single block of YAML. This prevents using
bases and overrides in Flux.

The proposal in [RFC#29](https://github.com/giantswarm/rfc/pull/29) is to use
both `.spec.config` and `.spec.userConfig` and the values will be merged by
app-operator.

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  name: something
  namespace: org-some
spec:
  config:
    configMap:
      name: flux01-default-apps-config
      namespace: org-some
  userConfig:
    configMap:
      name: flux01-userconfig
      namespace: org-some
```
