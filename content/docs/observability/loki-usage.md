---
title: "Loki at Giantswarm - usage"
linkTitle: Loki usage
---

## TLDR

* logs consultation is on the each management cluster's Grafana.
* Grafana's `explore` is the way to consult your logs from Loki.

## Logs exploration

* Open your cluster's grafana (`opsctl open -i gauss -a grafana`)
* Go to "explore" and select `loki` datasource

![explore](../lokidoc-explore.png)

* Then, you can either
   * use the `builder` and play with the dropdowns
   * or use `code` to write your query using [logql](https://grafana.com/docs/loki/latest/logql/)

![builder / code](../lokidoc-builder-code.png)

## Example useful logql queries

Here are a few logql queries you can test and play with to understand the syntax.

### Basic pod logs

* Look for all `k8s-api-server` logs on `gauss` MC:
```
{installation="gauss", cluster_id="gauss", pod=~"k8s-api-server-ip-.*"}
```

* Let's filter out "unable to load root certificate" logs:
```
{installation="gauss", cluster_id="gauss", pod=~"k8s-api-server-ip-.*"} != "unable to load root certificate"
```

* Let's only keep lines containing "url:/apis/application.giantswarm.io/.*/appcatalogentries" (regex):
```
{installation="gauss", cluster_id="gauss", pod=~"k8s-api-server-ip-.*"} |~ "url:/apis/application.giantswarm.io/.*/appcatalogentries"
```

### json manipulation

* With json logs, filter on the json field `resource` contents:
```
{installation="gauss", cluster_id="gauss", pod=~"prometheus-meta-operator-.*"} | json | resource=~"remotewrite.*"
```

* from the above query, only keep field `message`:
```
{installation="gauss", cluster_id="gauss", pod=~"prometheus-meta-operator-.*"} | json | resource=~"remotewrite.*" | line_format "{{.message}}"
```

### System logs

* Look at `containerd` logs for node `10.0.5.119` on `gauss` MC:
```
{installation="gauss", cluster_id="gauss", systemd_unit="containerd.service", hostname="ip-10-0-5-119.eu-west-1.compute.internal"}
```

### Metrics queries

You can also generate metrics from logs.

* Count number of logs per node
```
sum(count_over_time({installation="gauss", cluster_id="gauss", hostname=~"ip-.*"}[10m])) by (hostname)
```
