---
title: "Proxy"
description: >
  CAPI based MCs and WCs behind a proxy server
---

# General information about `proxy` setup

Some customers are enforced to use a corporate proxy server when accessing external resources.
Beside some customer application specific endpoints this also has impact when our stack tries to access:

- container registries (e.g. `quay.io`, `docker.io`)
- `github.com`
- Infrastructure Provider related API endpoints (e.g. `aws` or `azure` endpoints)

Therefore we are enforced to configure the customer specific proxy server in a few places.

## Affected Components

### `containerd`

To make `containerd` use of a proxy configuration for pulling container images, it's required to create a `systemd` drop-in and place it under `/etc/systemd/system/containerd.service.d/http-proxy.conf`.

```bash
[Service]
Environment="HTTP_PROXY={{ .HttpProxy }}"
Environment="http_proxy={{ .HttpProxy }}"
Environment="HTTPS_PROXY={{ .HttpsProxy }}"
Environment="https_proxy={{ .HttpsProxy }}"
Environment="NO_PROXY={{ .NoProxy }}"
Environment="no_proxy={{ .NoProxy }}"
```

### `kubelet`

As some clusters are still using the `in-tree` cloud provider, it's also required to create the same `systemd` drop-in as above and place it under `/etc/systemd/system/kubelet.service.d/http-proxy.conf`.

### workload on top of Kubernetes

Every pod within a Kubernetes cluster need a valid proxy configuration if the pod need to access external systems.

On a `MC` there are a lot of components where access to an external systems is needed:

- `Flux` need access to `github.com`
- The entire monitoring and alerting stack need access to `opsgenie`, `grafana`, ...
- App platform components need access to an OCI artifact system (e.g. `github.com`, `azure`)
- The `CAPI` infrastructure providers (e.g. `CAPZ`, `CAPA` or `CAPVCD`) needs access to the corresponding infrastructure API endpoints.

As we already use `kyverno` in our `MC`, we can use the [`kyverno-policies-connectivity` chart](https://github.com/giantswarm/kyverno-policies-connectivity) to inject the proxy configuration into all pods.

> Please note: 
> - due multiple valid reasons, `kyverno` doesn't mutate objects in `namespace/kube-system` per default.
> - static pods are managed by the `kubelet`. For these pods it's not possible to use `kyverno` for mutation. Therefore it's required to inject the proxy configuration during the machine creation phase (could be achieved in `CAPI` based clusters via `kubeadm`)

#### special workload

There are some components, which are part of the default set on top of a cluster. These components can't get configured via `kyverno` as they are either in `namespace/kube-system` (for `cert-manager`) or must exist before we apply applications via the app platform (for `chart-operator`).

##### `cert-manager`

`cert-manager` is needed in every cluster (`MC` and `WC`) and it's running in `namespace/kube-system`. 
It interact with external `ACME` services and therefore the proxy configuration must be explicitly defined in the `pod.spec`.

##### `chart-operator`

`chart-operator` is getting deployed in every `WC` by `cluster-apps-operator` and is responsible for applying charts in the workload cluster.
The proxy configuration must be explicitly defined in the `pod.spec`. 

## `no_proxy`/`NO_PROXY`

As customers wants components using a proxy server for external systems, they also might define some internal systems where no proxy server should be used. For that it's possible to define a comma separated list of domain names, FQDNs, network addresses and network ranges.

As within a Kubernetes cluster there are also some targets where no communication via the proxy is expected (e.g.: accessing Kubernetes services within the cluster, directly accessing pods via their IP address - primarily used by `prometheus` for metrics scraping).

For that, the values of `no_proxy` are separated into two logical parts:

- endpoints which are installation wide like a customer internal container registry or a customer internal network range.
- endpoints which are cluster specific like the `podCIDR`/`serviceCIDR` or the cluster internal base domain (e.g. `cluster.local`)

> Note: the interpretation of the `no_proxy` variable is very language/tool specific and not every language supports e.g. network ranges.
> A very detailed blog post was written by GitLab about [proxy variables](https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/).

# Implementation

## Management Cluster

### during the initial bootstrap

During the initial bootstrap phase of the `MC`, the App Platform isn't running at this time. 
For that reason it's required to define the proxy configuration multiple times.

Following components are applied as helm-charts with a proxy configuration:

- `cert-manager` in `namespace/kube-system`
- `kyverno-policies-connectivity` (this `clusterPolicy` mutate each `pod` and inject the cluster-specific proxy configuration)

### after all controllers/operators are in place

After the initial bootstrap is done and all GiantSwarm specific controllers and operators are in place to treat the `MC` as a `WC`, `cluster-apps-operator` will take over the handling of the installation specific proxy configuration.

### Workload Clusters

The current implemented workflow can be visualized like this:

> The green lines represent the additional steps in the common Cluster provisioning workflow if a proxy server has to be used.

<!-- markdown-link-check-disable -->
<!-- link is valid but for some reasons link-checker complaining about this ... if the file is renamed to whatever.md, the link-checker doesn't complain -->
![](workload_cluster_creation.png)
<!-- markdown-link-check-enable -->

#### `cluster-apps-operator`

With the current implementation, the proxy configuration is treated as being installation specific and is configured on a WC base.

With version [v2.5.0](https://github.com/giantswarm/cluster-apps-operator/blob/master/CHANGELOG.md#250---2022-11-10), `cluster-apps-operator` propagate the global proxy configuration into workload cluster specific resources.

<!-- markdown-link-check-disable -->
<!-- link is valid but it's a private repo-->
The global proxy configuration can be defined via a `secret-values.yaml.patch` for `cluster-apps-operator` in the [`config`-repo](https://github.com/giantswarm/config):
<!-- markdown-link-check-enable -->

```yaml
proxy:
  noProxy: "172.16.0.0/16,internal.corpdomain.net,example.com"
  http: "http://myProxyUser:mySuperSecretPassword@192.168.52.220:3128"
  https: "http://myProxyUser:mySuperSecretPassword@192.168.52.220:3128"
```

`cluster-apps-operator` already creates a `secret` which contains some infrastructure specific values ([for `openstack` and `vcd`](https://github.com/giantswarm/cluster-apps-operator/blob/master/service/controller/resource/clustersecret/desired.go#L42-L65)).
The `secret` for each WC is called `<clusterName>-cluster-values`.
With the extended proxy implementation, the secret now contains a new `cluster` section with a `proxy` sub section:

```yaml
cluster:
  proxy:
    http: http://myProxyUser:mySuperSecretPassword@192.168.52.220:3128
    https: http://myProxyUser:mySuperSecretPassword@192.168.52.220:3128
    noProxy: cluster.local,100.64.0.0/13,100.96.0.0/11,178.170.32.59,172.16.0.0/16,internal.corpdomain.net,example.com,svc,127.0.0.1,localhost
```

This `secret` can now be used to pass the proxy information into `Apps` which get applied into a WC, for example:

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
[...]
spec:
  catalog: default-test
  config:
    configMap:
      name: mycluster-cluster-values
      namespace: org-giantswarm
    secret:
      name: mycluster-cluster-values
      namespace: org-giantswarm
[...]
```

As `cluster-apps-operator` takes care of creating `deployment/chart-operator` in the WC with the values from `(secret|configmap)/<clusterName>-cluster-values` as input, `chart-operator` in every WC automatically gets a valid proxy configuration.

#### `CAPI`

To get `containerd` (and `kubelet` if `in-tree` cloud provider is used) running behind a proxy server, we reference to the `cluster-apps-operator` generated proxy configuration systemd drop-in in the `cluster-*` chart, e.g. for `kubeadmconfig`:

```yaml
files:
  - path: /etc/systemd/system/containerd.service.d/http-proxy.conf
    permissions: "0600"
    contentFrom:
      secret:d
        name: <clusterName>-systemd-proxy
        key: containerdProxy   
```

By doing this, `ClusterAPI` is waiting for the `secret` to get created. 
Once the `secret` got created, it will be used by creating the machines (and injecting this data via `cloud-init` or `ignition`).
