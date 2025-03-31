---
title: "Audit Logs Troubleshooting"
owner:
- https://github.com/orgs/giantswarm/teams/team-planeteers
component:
  - grafana-app
  - loki-app
  - observability-bundle
description: "How to check the action of certain user in a cluster"
classification: public
---

How can I check the action of certain user in a cluster? How can I get more details about certain event on the cluster?

## Using Loki

Today all the management clusters have Loki instance deployed with audit logs included. So we can leverage on Loki to get the logs.

Open Grafana and select the Loki datasource. You can use the following query to get the logs of a certain user:

```sh
opsctl open -a grafana -i <installation-name>
```

Go to `Explore` and select the Loki datasource and use the following query:

```text
{cluster_id="myCluster",scrape_job="audit-logs"} |= `` | json | user_username=`johndoe@example.com`
```

__Note__: Use `_` in json filters to access properties (instead of a dot). In the example query above `user.username` is specified as `user_username`.
