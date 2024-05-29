---
title: "Cilium Troubleshooting"
owner:
- https://github.com/orgs/giantswarm/teams/team-phoenix
classification: public
---

If we suspect the CNI is misbehaving 

# Table of Contents
1. [Command Line Tool](#command-line-tool)
1. [Check Component Status](#check-component-status)
1. [Cilium Connectivity Test](#cilium-connectivity-test)
1. [Check Hubble UI](#hubble-ui)

## Command Line Tool

To run `cilium` command line tool (ctl) you can take use the binary from the cilium agent pod lie

```bash
kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app.kubernetes.io/name=cilium-agent -o jsonpath="{.items[0].metadata.name}" ) sh
```

or you install [cilium client](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli) in your local and ensure the current kubeconfig points to the right cluster.

## Check Component Status

1) Inside the Workload Cluster verify that `cilium-operator` deployment on `kube-system` has all pods running and no errors on the logs.
2) Inside the Workload Cluster verify that all pods on the `cilium` daemonset on `kube-system` are running.

## Cilium Connectivity Test

1) Open a terminal connection against any of the pods of the `cilium` daemonset:

```
$> kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app.kubernetes.io/name=cilium-agent -o jsonpath="{.items[0].metadata.name}" ) sh
```

2) Check cilium status

```
$> cilium status

KVStore:                 Ok   Disabled
Kubernetes:              Ok   1.24 (v1.24.13) [linux/amd64]
Kubernetes APIs:         ["cilium/v2::CiliumClusterwideNetworkPolicy", "cilium/v2::CiliumEndpoint", "cilium/v2::CiliumLocalRedirectPolicy", "cilium/v2::CiliumNetworkPolicy", "cilium/v2::CiliumNode", "core/v1::Namespace", "core/v1::Node", "core/v1::Pods", "core/v1::Service", "discovery/v1::EndpointSlice", "networking.k8s.io/v1::NetworkPolicy"]
KubeProxyReplacement:    Strict   [eth0 10.1.20.111, eth1 10.1.20.119]
Host firewall:           Disabled
CNI Chaining:            none
CNI Config file:         CNI configuration file management disabled
Cilium:                  Ok   1.13.0 (v1.13.0-c9723a8d)
NodeMonitor:             Listening for events on 4 CPUs with 64x4096 of shared memory
Cilium health daemon:    Ok
IPAM:                    IPv4: 8/126 allocated from 10.10.1.0/25,
IPv6 BIG TCP:            Disabled
BandwidthManager:        Disabled
Host Routing:            Legacy
Masquerading:            IPTables [IPv4: Enabled, IPv6: Disabled]
Controller Status:       42/42 healthy
Proxy Status:            OK, ip 10.10.1.29, 0 redirects active on ports 10000-20000
Global Identity Range:   min 256, max 65535
Hubble:                  Ok   Current/Max Flows: 4095/4095 (100.00%), Flows/s: 35.96   Metrics: Disabled
Encryption:              Disabled
Cluster health:          6/6 reachable   (2023-05-17T10:41:28Z)
```

## Hubble UI

1) In order to open the hubble UI you will need to use kubectl port-forwarding:

```
$> kubectl -n kube-system port-forward svc/hubble-ui 3000:80
```

Once the command is running you can open your browser at `http://127.0.0.1:3000/`.
