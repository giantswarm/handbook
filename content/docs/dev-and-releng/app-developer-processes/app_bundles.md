---
title: "App Bundles"
weight: 20
classification: public
---

## Overview

The App Bundle is a Helm Chart that instead of providing a regular resources, that normally represents
an application, it provides App CRs, optionally accompanied by ConfigMaps and Secrets. In other words, it is a
way to represent a group of apps as a single app, to the user and to the system. Check out the [public docs](https://docs.giantswarm.io/tutorials/fleet-management/app-platform/defaulting-validation/) if you look for a more detailed explanation.

The App Bundle usage is currently well established in the company.

For example, for CAPI it has been decided to deploy default apps in this way, see [ADR](https://intranet.giantswarm.io/docs/product/architecture-specs-adrs/adr/016-capi-releases/). By bundling a group of default apps we make the installation
simpler and also means we can retire the [Release](https://docs.giantswarm.io/vintage/use-the-api/management-api/crd/releases.release.giantswarm.io/) CRD used in vintage clusters. Hence, a `default-apps-PROVIDER` app bundle will
exist for each CAPI provider.

Another example is grouping apps by the topic, creating specialized bundles, like for example the `security-pack` app.

## Naming Convention

It has been decided for App Bundles to carry the `-bundle` prefix in order to distinguish them from regular apps, see
the [PDR](https://intranet.giantswarm.io/docs/product/pdr/008_app_bundle_naming/).

**Note**, as you may notice the `security-pack` referenced in this doc, for whatever reason, is not compliant with
these rules yet, do not be suggested by it and please stick to the PDR demands.

What may seem as another exception are `default-apps-PROVIDER` apps. These however are subject to a bit different rules,
as being used in a different ways than usual apps, no matter bundled or not. See the reasoning behind these apps in
the previous paragraph.

## Creating a new App Bundle

It's recommended to base new App Bundles on the SOTA (State of the Art) App Bundle.

For default apps this is [default-apps-openstack](https://github.com/giantswarm/default-apps-openstack)
and the app should be published to the [cluster-catalog](https://github.com/giantswarm/cluster-catalog).

For other bundles this is [security-pack](https://github.com/giantswarm/security-pack).

Note, app bundle beyond its fancy name is nothing more than a regular Helm Chart. Whatever the Helm
offers for Charts creation can be used when creating a bundle. Some demands are however posed on the
configuration, yet not by the bundle construction, but by the way how App Platform works. Find more
about in the next paragraphs.

## Installing an App Bundle

The installation process for bundles can be found in the [public docs](https://docs.giantswarm.io/tutorials/fleet-management/app-platform/app-bundle/). Go there to understand:

- the components the installation involves
- the configurational demands by these components

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
CR and means the install [is not blocked](https://docs.giantswarm.io/tutorials/fleet-management/app-platform/defaulting-validation/)
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
`values.yaml` of the app bundle's Helm Chart which needs to pass values to the
child apps.

This relies heavily on Helm templating so care needs to be taken and ideally
there should be test coverage for this. Find an example of such `values.yaml` below.

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

There is a problem with using GitOps and managed apps in general, affecting the
bundles as well. The user values are passed via the `values` key of either a
ConfigMap or a Secret, and must be a single block of YAML. This prevents using
bases and overrides in Flux. This is because [kustomize](https://github.com/kubernetes-sigs/kustomize)
cannot patch strings.

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

This approach has been adapted and explained in our [GitOps Template repository](https://github.com/giantswarm/gitops-template), that represents our GitOps offering.
