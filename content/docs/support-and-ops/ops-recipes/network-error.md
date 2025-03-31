---
title: "Network error rate is too high"
owner:
- https://github.com/orgs/giantswarm/teams/team-cabbage
component:
  - cilium-app
  - net-exporter
  - coredns-app
description: "How to troubleshoot network errors"
classification: public
---

## What to do if NetworkErrorRateTooHigh or NetworkCheckErrorRateTooHigh

### Check for cilium errors

Check the following [recipe](./cilium-troubleshooting.md) to see if there are any cilium errors.

### Check machine network connection

To identify quickly if there are actual network issues on the machine you can run

```sh
while true; do echo -n "`date +'%F_%H%M%S%Z'` ";curl https://github.com -o /dev/null --silent -w '%{http_code}\n'; sleep 1; done
```

All responses should be `200` if everything is fine - `000` indicates a general network issue.
You can continue debugging from there after you have some certainty that the network issue also affects the machine.

## What to do if NetworkCheckErrorRateTooHigh or DNSCheckErrorRateTooHigh

In case of `NetworkCheckErrorRateTooHigh` or `DNSCheckErrorRateTooHigh`alert means that net-exporter is not able to connect to `kubernetes` api service.

Check the logs in net-exporter pods to confirm.

If the error is related to looking up `kubernetes` service, it's likely a problem with `cilium` or `coredns`.
If it's a problem related to looking up `giantswarm.io`, it's likely a problem with external connectivity or `coredns`.

Get the pods with errors in Grafana.
`rate(network_error_total[10m]) > 0` for `NetworkCheckErrorRateTooHigh`
`rate(dns_error_total[10m]) > 0` for `DNSCheckErrorRateTooHigh`

If the error appears at the same time in many pods of the cluster could mean that the API is taking a lot of time to resolve the request. Check in the logs of `kubernetes` API pods to get more information,

If there are no logs related to the request maybe is just a networking problem between the pod and the api. You can verify this trying to curl `kubernetes` service cluster-ip.
