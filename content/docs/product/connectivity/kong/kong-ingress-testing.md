---
title: "Manual test of Kong Ingress functionality"
description: >
  Documentation of how to test the ingress functionality of Kong Proxy.
weight: 40
---

Tue, 23. Apr 2024 

### Step 1: Set Up AWS Infrastructure for Kong
Ensure that the Kong App is installed in the Workload Cluster.
Make sure that the Kong Proxy service is configured with an attached Amazon Web Services (AWS) Load Balancer (LB).
```bash
k get -n kong-app svc kong-app-kong-app-proxy -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
# Example Output
# a62e0e6cd3ac3434c9c5f688277e56c8-1838414965.eu-central-1.elb.amazonaws.com
```

### Step 2: Apply Configuration to Kong
Apply a values.yaml file to your Kong installation.
Ensure you're using at least version 3.1.0 of the external-dns-app. Check your cluster release requirements to confirm this version is supported.
Set up your image repository and tag, disable enterprise and configure the external-dns annotations for the proxy service:
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
Step 3: Deploy the `hello-world-app`
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
Step 4: Test the Kong Proxy
After applying the ingress configuration, test the Kong proxy functionality by sending requests to the `hello-world-app`.
Verify the routing of requests through the Kong proxy and check the responses to ensure they are being processed correctly.
Additionally, you can test the SSL/TLS configuration by accessing the hello.kong. URL over HTTPS and ensuring that the hello-world-tls certificate is being served correctly.

Replace with your actual wildcard cluster base domain and with the specific image tag you are using for the Kong installation.
