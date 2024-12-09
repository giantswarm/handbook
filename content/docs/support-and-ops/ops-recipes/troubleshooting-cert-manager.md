---
title: "Cert Manager Troubleshooting"
owner:
- https://github.com/orgs/giantswarm/teams/team-shield
description: "Troubleshooting steps to resolve issues with cert-manager."
classification: public
---

Whenever a certificate error occurs, we recommend starting your investigation by looking at cert-manager CertificateRequests, Orders, and Challenges. Often, these have useful error messages in their status fields.

## DNS01 challenge issues

When there is a certificate not becoming ready, it is often due to the ACME DNS01/HTTP-01 challenge not being completed. Check the cert manager controller logs:

```bash
stern cert-manager -s 1m -n kube-system -i CERT_NAME
```

> *NOTE:* [stern](https://github.com/stern/stern) is a tool conceived to tail multiple pods and containers logs. It is a good tool to use when you want to check logs from multiple pods at the same time.


In case you see errors like:

```
E0828 14:04:53.727973       1 sync.go:190] "cert-manager/challenges: propagation check failed" err="NS ns-1536.awsdns-00.co.uk.:53 returned REFUSED for _acme-challenge.my-app.gig3-prd.aws.cps.xxx.com." resource_name="my-app-cert-h8qxc-3214626457-1657644764" resource_namespace="aaa-prod-application" resource_kind="Challenge" resource_version="v1" dnsName="my-app.gig3-prd.aws.cps.xxx.com" type="DNS-01"
```

This is related to the DNS challenge not being successful. We found, thanks to this [article](https://community.letsencrypt.org/t/error-renewing-certificate-from-le-ns-returned-refused-for-acme-challenge/174132/1), when there was an incident that pointed us to the right direction. The problem is related to DNS client handling when using both IPv4 and IPv6

To fix it we applied the following configuration to the cert manager app. If there is not `userConfig.configMap` defined already in the app manifest, you can add it like this:

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  name: cert-manager
  namespace: ORG-NAMESPACE
spec:
  # ...
  userConfig:
    configMap:
      name: "CLUSTER_ID-user-values"
      namespace: "ORG-NAMESPACE"
```

Inside the configmap you can set the following values:

```yaml
apiVersion: v1
data:
  values: |
    extraArgs:
      - --dns01-recursive-nameservers=1.1.1.1:53,8.8.8.8:53
      - --dns01-recursive-nameservers-only=true
```

When you apply this configuration, the cert manager will be rolled out, and you can check the logs again to see if the issue is resolved. It is recommended to kick the certificate to renew after the rollout to see if the issue is resolved. Use [cmctl](https://github.com/cert-manager/cmctl/) tool to renew the certificate:

```bash
cmctl renew -n MY_APP_NS MY_APP_CERT_NAME
```

It should do the trick. If not, please reach out to the team BigMac for further investigation.
