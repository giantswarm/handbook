---
title: "LabelSelector MatchLabels are immutable"
description: |
  LabelSelector MatchLabels of a Kubernetes resource are immutable. This page describes the error and gives tips how to resolve the issue.
weight: 70
classification: public
---

# spec.selector.matchLabels are immutable in Daemonsets, Deployments etc

When creating a helm chart for an app, keep in mind that `spec.selector.matchLabels` is immutable and cannot be changed when upgrading the app.

If your app has been created from [`template-app`](https://github.com/giantswarm/template-app),
helper templates for creating [labels](https://github.com/giantswarm/template-app/blob/master/helm/{APP-NAME}/templates/_helpers.tpl#L18-L31)
and [selector labels](https://github.com/giantswarm/template-app/blob/master/helm/{APP-NAME}/templates/_helpers.tpl#L33-L39) exist.

## Example usage of label templates

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "resource.default.name"  . }}
  namespace: {{ include "resource.default.namespace"  . }}
  labels:
    {{- include "labels.common" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "labels.selector" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "labels.common" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "resource.default.name"  . }}
      containers:
        - name: my-container
          image: "{{ .Values.Installation.V1.Registry.Domain }}/{{ .Values.image.name }}:{{ .Values.image.tag }}"
          imagePullPolicy: IfNotPresent
```

## Re-enabling app upgrades without manual delete and re-create

Since the selector labels are immutable, it is not possible to do an usual app upgrade.
Though it is possible to utilize [helm chart hooks](https://helm.sh/docs/topics/charts_hooks/)
to resolve this by deleting the old release automatically.

For this, a pod running `kubectl delete` is created by helm before touching the rest of the charts resources.

A complete example of the required helm hooks can be found in [this PR](https://github.com/giantswarm/azure-scheduled-events/pull/20/files).

{{% alert title="Attention" color="warning" %}}
Please take note to not copy the hook files in the PR blindly.

The `"helm.sh/hook"` annotation value need to be only : "pre-upgrade".

You'll also probably add a note to your future self to remove this hook after releasing a version. Otherwise upgrading to future versions will always delete.
{{% /alert %}}
