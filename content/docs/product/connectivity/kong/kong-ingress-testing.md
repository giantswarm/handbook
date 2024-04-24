---
title: "Manual test of Kong Ingress functionality"
description: >
  Documentation of how to test the ingress functionality of Kong Proxy.
weight: 40
---

### Step 0: Prerequisites
- external-dns-app >3.1.0
```bash
helm list -n kube-system | grep external-dns
# Example Output
# external-dns   kube-system   4   2024-04-23 09:37:02 UTC deployed   external-dns-app-3.1.0
```
- Workload Cluster base domain
```bash
# Vintage clusters

kubectl get -n giantswarm configmap chart-operator-chart-values -o jsonpath='{.data.values}' | grep baseDomain

# CAPI clusters
kubectl get -n giantswarm configmap <wc-name>-chart-operator-chart-values -o jsonpath='{.data.values}' | grep baseDomain

# Example Output
# baseDomain: qw54m.k8s.gaia.eu-central-1.aws.gigantic.io
```

### Step 1: Deploy Kong OSS
*Ensure you're using at least version 3.1.0 of the external-dns-app. Check your cluster release requirements to confirm this version is supported.*

Deploy kong-app with at least the following values to:
- configure the OSS image repository and tag
- disable enterprise
- configure the external-dns annotations for the proxy service:
```yaml
image:
  repository: giantswarm/kong
  tag: "<kong-image-tag>"
enterprise:
  enabled: false
proxy:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "*.kong.<wc-cluster-base-domain>"
    giantswarm.io/external-dns: managed
```

Make sure that the Kong Proxy service is configured with an attached Amazon Web Services (AWS) Load Balancer (LB).
```bash
k get -n kong-app svc kong-app-kong-app-proxy -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
# Example Output
# c62e1e6bb3ac3535c9e5f698277e57c8-2828514061.eu-central-1.elb.amazonaws.com
```

### Step 2: Deploy the `hello-world-app`
Deploy the `hello-world-app` with the following `values.yaml` config:
```yaml
ingress:
  className: kong
  hosts:
  - host: hello.kong.<wc-cluster-base-domain>
    paths:
    - path: /
      pathType: Prefix
  tls:
  - secretName: hello-world-tls
    hosts:
    - hello.kong.<wc-cluster-base-domain>
```

### Step 4: Test the Kong Proxy
After applying the ingress configuration, test the Kong proxy functionality by sending requests to the `hello-world-app`.
Verify the routing of requests through the Kong proxy and check the responses to ensure they are being processed correctly.
Additionally, you can test the SSL/TLS configuration by accessing the `hello.kong.<wc-cluster-base-domain>` URL over HTTPS and ensuring that the `hello-world-tls` certificate is being served correctly.

Replace `<wc-cluster-base-domain>` above with your actual wildcard cluster base domain and `<kong-image-tag>` with the specific image tag you are using for the Kong installation.
