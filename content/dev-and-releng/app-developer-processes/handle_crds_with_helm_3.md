---
title: "Handle CRD installation and updates with Helm 3"
description: "This page documents a method for installing and updating CRDs using Helm 3"
---

Helm 3 introduced the `crds/` directory inside a helm chart. ([Reference](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#install-a-crd-declaration-before-using-the-resource))

This approach has some downsides:

1. Resources in the `crds/` directory are only touched on the first installation of a chart.
2. If the CRDs require templating then this comes with additional caveats.

## Installing CRD ressources using a Job

It is possible to overcome the first point by using [helm chart hooks](https://helm.sh/docs/topics/charts_hooks/) to install resources present in the `crds/` through a Job installed by helm `pre-upgrade` and `pre-install` hooks.

## Template helpers

In addition to our [usual template helpers](https://github.com/giantswarm/template-app/blob/142e685/helm/APP-NAME-app/templates/_helpers.tpl), we're defining a set of additional helpers for the install Job.

```
{{/* TODO */}}
{{- define "crdInstall" -}}
{{- printf "%s-%s" ( include "name" . ) "crd-install" | replace "+" "_" | trimSuffix "-" -}}
{{- end -}}

{{/* TODO */}}
{{- define "crdInstallAnnotations" -}}
"helm.sh/hook": "pre-install,pre-upgrade"
"helm.sh/hook-delete-policy": "before-hook-creation,hook-succeeded,hook-failed"
{{- end -}}

{{/* Create a label which can be used to select any orphaned crd-install hook resources */}}
{{- define "crdInstallSelector" -}}
{{- printf "%s" "crd-install-hook" -}}
{{- end -}}
```

## CRD install Job

Loosely defined, this methods takes the contents of the files in the `crds/` directory, stores them in ConfigMaps and executes `kubectl apply` for each ConfigMap.

Because there is a limit on how big ConfigMaps can be, it is advised to keep each CRD in its own file in `crds/`.

Along with additional required NetworkPolicy, PodSecurityPolicy, ServiceAccount and RBAC resource definitions, an example of the Job defintion can be found in repository [giantswarm/prometheus-operator-app](https://github.com/giantswarm/prometheus-operator-app/tree/a8315a8/helm/prometheus-operator-app/templates/crd-install).

## Caveats

- If the CRD definitions are huge then it's possible that the chart will fail to install with this method. Helm releases are stored as Secrets which are limited to 1MB in size, and using this method means the CRDs are included in the Secret twice (as CRDs from `crds/` and also in the Job configMaps).
- Because helm does not support templating in the `crds/` directory, one cannot use any templating for CRDs. A solution to this is to not use `crds/` at all and to place the CRD manifests in `files/` instead.
	- This however comes with its own additional caveats - if the Helm chart creates resources which consume these CRDs, then they _must_ exist in `crds/` because Helm will fail initially to install the chart as it doesn't know about the CRDs (upgrades to existing charts will work though). This means this method cannot be used to install CRDs which require templating, and which are also used in the main chart itself - this is a chicken-and-egg problem which cannot be solved with this method.
- CRD deletion should never be managed by the Chart hooks in order to avoid accidental removal.
