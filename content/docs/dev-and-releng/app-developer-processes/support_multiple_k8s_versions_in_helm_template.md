---
title: "How to support multiple k8s versions in a Helm template"
description: |
  Support multiple k8s versions using Helm capabilities API
weight: 80
classification: public
---

## Rationale

- Sometimes we need to support multiple Kubernetes versions with API versions
that have been removed or not exist yet.
- Helm has a [built in](https://helm.sh/docs/chart_template_guide/builtin_objects/)
Capabilities API that helps with this.

## Ingress example

Real world example from [happa](https://github.com/giantswarm/happa/blob/e9624bace685fd5c31113c7edcce2ab929e756ed/helm/happa/templates/ingress.yaml).

```yaml
{{ if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" }}
apiVersion: networking.k8s.io/v1
{{ else }}
apiVersion: networking.k8s.io/v1beta1
{{ end }}
kind: Ingress
metadata:
  name: happa
  namespace: giantswarm
  labels:
    app: happa
spec:
  ingressClassName: nginx
  rules:
  - host: {{ .Values.happa.host }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
{{ if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" }}
          service:
            name: happa
            port:
              number: 8000
{{ else }}
          serviceName: happa
          servicePort: 8000
{{ end }}
```
