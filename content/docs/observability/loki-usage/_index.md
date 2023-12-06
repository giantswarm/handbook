---
title: "Loki at Giantswarm - usage"
linkTitle: Loki usage
description: >
  Guide explaining how to access and explore logs using Loki
confidentiality: public
---

## Context

<img src="images/loki-context.png" alt="loki available on AWS, no WC logs, all components, access via Grafana, 1 month retention" >

## How to access Logs ?

* Open your installation's Grafana
  * via UI: https://docs.giantswarm.io/getting-started/observability/grafana/access/
  * via CLI (giantswarm only): `opsctl open -i myInstallation -a grafana`

1. Go to `Explore` item in the `Home` menu
2. Select `Loki` datasource on the top left corner
3. Choose how to build your queries:
   * `builder` and play with the dropdowns to build your query
   * `code` to write your query using [LogQL](https://grafana.com/docs/loki/latest/logql/)

<img src="images/lokidoc-explore.png" width="300" >
<img src="images/lokidoc-datasource-query.png" width="600" >

## LogQL basics

### Query anatomy

```goat
{ installation="myInstallation", pod=~"k8s-api-server-ip-.*" } |= “unable to load root certificate”
|                                                            |  | |                               |
.-----------------------------+------------------------------.  | .---------------+---------------.
                              |                                 |                 |
                              v                                 v                 v
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
|= : contains
!= : does not contain
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
### Audit logs

* Get audit logs using json filter to get only the ones owned by a specific user

```
{cluster_id="myCluster",scrape_job="audit-logs"} |= `` | json | user_username=`fernando@giantswarm.io`
```

__Note__: In json filter to access nested properties you use `_` for getting a child property as the example above (user.username -> user_username).

### System logs

* Look at `containerd` logs for node `10.0.5.119` on `myInstallation` MC:
```
{installation="myInstallation", cluster_id="myInstallation", systemd_unit="containerd.service", node_name="ip-10-0-5-119.eu-west-1.compute.internal"}
```

### Metrics queries

You can also generate metrics from logs.

* Count number of logs per node
```
sum(count_over_time({installation="myInstallation", cluster_id="myInstallation", node_name=~"ip-.*"}[10m])) by (node_name)
```
