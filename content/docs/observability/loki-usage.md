---
title: "Loki at Giantswarm - usage"
linkTitle: Loki usage
description: >
  Guide explaining how to access and explore logs using Loki
confidentiality: public
---

## Context

* logs consultation is on the each management cluster's Grafana.
* Grafana's `Explore` is the way to consult your logs from Loki.

## Logs exploration

* Open your cluster's grafana
  * via UI: https://docs.giantswarm.io/getting-started/observability/grafana/access/
  * via CLI: `opsctl open -i myInstallation -a grafana`

* Go to "Explore" item in the "Home" menu
* Select `loki` datasource on the top left corner

![explore](../lokidoc-explore.png)

* Then, you can either use
   * `builder` and play with the dropdowns to build your query
   * `code` to write your query using [LogQL](https://grafana.com/docs/loki/latest/logql/)

![builder / code](../lokidoc-builder-code.png)

## LogQL basics

### Query anatomy

```goat
{ installation="myInstallation", pod=~"k8s-api-server-ip-.*" } |= “unable to load root certificate”
|                                                            |  | |                               |
                             .+.                                |                .+.
                     log stream selectors               filter operator    filter expression
```

### Log stream selectors

Used to filter the log stream by labels

```
=  : equals
!= : not equals
=~ : regex matches
!~ : regex does not match
```

### Filter operators

Used to filter text within the log stream

```
|= : equals
!= : not equals
|~ : regex matches
!~ : regex does not match
```


## Example of useful LogQL queries

Here are a few LogQL queries you can test and play with to understand the syntax.

### Basic pod logs

* Look for all `k8s-api-server` logs on `myInstallation` MC:
```
{installation="myInstallation", cluster_id="myInstallation", pod=~"k8s-api-server-ip-.*"}
```

* Let's filter out "unable to load root certificate" logs:
```
{installation="myInstallation", cluster_id="myInstallation", pod=~"k8s-api-server-ip-.*"} != "unable to load root certificate"
```

* Let's only keep lines containing "url:/apis/application.giantswarm.io/.*/appcatalogentries" (regex):
```
{installation="myInstallation", cluster_id="myInstallation", pod=~"k8s-api-server-ip-.*"} |~ "url:/apis/application.giantswarm.io/.*/appcatalogentries"
```

### json manipulation

* With json logs, filter on the json field `resource` contents:
```
{installation="myInstallation", cluster_id="myInstallation", pod=~"prometheus-meta-operator-.*"} | json | resource=~"remotewrite.*"
```

* from the above query, only keep field `message`:
```
{installation="myInstallation", cluster_id="myInstallation", pod=~"prometheus-meta-operator-.*"} | json | resource=~"remotewrite.*" | line_format "{{.message}}"
```

### System logs

* Look at `containerd` logs for node `10.0.5.119` on `myInstallation` MC:
```
{installation="myInstallation", cluster_id="myInstallation", systemd_unit="containerd.service", hostname="ip-10-0-5-119.eu-west-1.compute.internal"}
```

### Metrics queries

You can also generate metrics from logs.

* Count number of logs per node
```
sum(count_over_time({installation="myInstallation", cluster_id="myInstallation", hostname=~"ip-.*"}[10m])) by (hostname)
```
