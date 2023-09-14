---
title: "Loki at Giantswarm - usage"
linkTitle: Loki usage
description: >
  Guide explaining how to access and explore logs using Loki
confidentiality: public
---

## Context

![context](../images/loki-context.png)

## How to access Logs ?

* Open your installation's Grafana
  * via UI: https://docs.giantswarm.io/getting-started/observability/grafana/access/
  * via CLI (giantswarm only): `opsctl open -i myInstallation -a grafana`

1. Go to `Explore` item in the `Home` menu
2. Select `Loki` datasource on the top left corner
3. Choose how to build your queries:
   * `builder` and play with the dropdowns to build your query
   * `code` to write your query using [LogQL](https://grafana.com/docs/loki/latest/logql/)

{{< blocks/section color="dark" type="row" >}}
{{% blocks/feature %}}
![explore](../images/lokidoc-explore.png)
{{% /blocks/feature %}}

{{% blocks/feature %}}
![builder / code](../images/lokidoc-datasource-query.png)
{{% /blocks/feature %}}
{{< /blocks/section >}}


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
