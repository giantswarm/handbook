---
title: "Handle CRD installation and updates with Helm 3"
description: "This page documents a method for installing and updating CRDs using Helm 3"
classification: public
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
	- This however comes with its own additional caveats - if the Helm chart creates resources which consume these CRDs, then they _must_ exist in `crds/` because Helm will fail initially to install the chart as it doesn't know about the CRDs (upgrades to existing charts will work though). This means this method cannot be used to install CRDs which require templating, and which are also used in the main chart itself - this is a chicken-and-egg problem which cannot be solved with this method. To slightly improve this situation, the App Platform offers a workaround allowing to install both, CRDs and CRs of these CRDs kinds, in a semi-single step. See the next paragraph for more details.
- CRD deletion should never be managed by the Chart hooks in order to avoid accidental removal.

## Installing CRDs and CRs in a semi-single run

### Chart Operator

Starting with the `2.31.0` version of Chart Operator it supports doing a two-step installation of an application.

What changes in comparison to a normal installation is that, right after it, the Chart Operator executes the
upgrade. This upgrade is internal, meaning it is not shown to the user, yet observative user may spot signs of it
being done, by for example Helm release revision being `2` instead of `1`.

In addition, the internal upgrade is not done until explicitly requested. App owner may request it for its app
by annotating its `Chart.yaml` with:

```yaml
annotations:
  application.giantswarm.io/two-step-install: "true"
```

To sum up, starting with the aforementioned version Chart Operator does install the app, and then when explicitly
asked to, it also runs the upgrade internally, immediately after the first step.

### Accounting for two-step installation in Helm Chart

With a two-step installation in place, the app owners can now configure their apps to install both CRDs and CRs
when apps are configured for the cluster for the first time. Obviously the rule from [caveats](#caveats) still
applies, Helm Chart however can be configured to skip the CRs on the installation, when CRDs do not yet exist,
and then to provide them on upgrade, when CRDs are already in place. This is exactly what the internal upgrade is
for.

There are two things to take care when configuring Helm Chart for it:
- skipping CRs installation when CRDs do not exist
- retaining faulty behaviour for installation outside the App Platform, or for old Chart Operators inside the App
Platform

#### Check for CRDs

In the most basic form, CRs can be conditioned on the CRDs existance with the Helm's `lookup` function. Result
can be then used in the IF conditions enclosing the CRs in question.

Below is the example of `lookup` used in [Flux app](https://github.com/giantswarm/flux-app/blob/master/helm/flux-app/templates/source.yaml) for checking the `GitRepository` CRD, note some fields have been removed for brevity.

```yaml
{{- $is_gitrepository_crd := (lookup "apiextensions.k8s.io/v1" "CustomResourceDefinition" "" "gitrepositories.source.toolkit.fluxcd.io") -}}
{{- if $is_gitrepository_crd }}
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: "{{ .name }}"
  namespace: "{{ $.Release.Namespace }}"
...
{{- end }}
```

Unfortunately, relying solely on the `lookup`'s result "breaks" the Helm Chart in some ways. It now does not fail
when both, CRDs and CRs, are requested, but it neither install the latter. It neither informs the user of
skipping them, and even if it was it would take us back to the square one because user would need to perform the
update manually, as he must do now.

So except skipping CRs, the Helm Chart must know when to do it, i.e. when Chart Operator can do the internal
upgrade.

#### Check for App Platform

As stated, the Helm Chart must know when to skip the CRs. We know it can do it only when:
- it is being installed with the App Platform, and
- App Platform runs the Chart Operator that supports the internal upgrade.

Now, the check for that is not the prettiest thing to see:

```yaml
{{- define "appPlatform.twoStepInstall" -}}
{{- $is_chart_operator := lookup "application.giantswarm.io/v1alpha1" "Chart" "giantswarm" "chart-operator" -}}
{{- $is_chart_operator_bad := true }}
{{- if $is_chart_operator }}
{{- $is_chart_operator_bad = (semverCompare "< 2.31.0-0" $is_chart_operator.spec.version) }}
{{- end }}

{{- $is_this_chart_cr := lookup "application.giantswarm.io/v1alpha1" "Chart" "giantswarm" . -}}
{{- $is_outside_app_platform := true }}
{{- if $is_this_chart_cr }}
{{- $is_outside_app_platform = false }}
{{- end }}

{{- if or $is_chart_operator_bad $is_outside_app_platform }}
{{- print "unsupported: true" -}}
{{- else -}}
{{- print "unsupported: false" -}}
{{- end -}}
{{- end -}}
```

The first part checks for Chart Operator Chart CR in the `giantswarm` namespace. Then, it checks the version
supports the internal upgrade, by comparing it to the version that first introduced this.

The second part looks for this app's Chart CR since its existence means the app is installed inside the App
Platform.

When Chart Operator exists and supports the upgrade, and when app is being installed as a managed app, then the
function renders two-step installation as supported.

Now this piece of code can be used into Helm Chart's `_helpers.tpl`, and used to enrich the condition from
previous paragraph, see below.

```yaml
{{- $two_step_upgrade := include "appPlatform.twoStepInstall" .Release.Name | fromYaml }}
...
{{- $is_gitrepository_crd := (lookup "apiextensions.k8s.io/v1" "CustomResourceDefinition" "" "gitrepositories.source.toolkit.fluxcd.io") -}}
{{- if or $two_step_upgrade.unsupported $is_gitrepository_crd }}
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: "{{ .name }}"
  namespace: "{{ $.Release.Namespace }}"
...
{{- end }}
```

With this, the CR should be skipped when app is being installed as a managed app by a conformant Chart Operator
for a cluster that does not yet have the CRDs in place, and rendered in other cases.
