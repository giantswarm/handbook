---
title: "Audit Logs Troubleshooting"
owner:
- https://github.com/orgs/giantswarm/teams/team-horizon
confidentiality: public
---

How can I check the action of certain user in a cluster? How can I get more details about certain event on the cluster?

## Gather all logs

We plan to provide audit log analysis via our Loki installations. Until then, we depend on manual steps to debug them.

To do that, we need to collect all logs available first. Since the backend only retains a certain amount of audit logs (depending on size), your data may not reach far enough into the past to get the evidence you are looking for.

You can check the age of the log files using:
```bash
for file in $(kubectl get --raw=/logs/apiserver/ | awk -F'>' '{print $2}' | sed 's/<\/a$//' ); do echo $file; done
```

If the event you are looking for is inside the time window, dump all data to your local machine for efficient processing.

```bash
for file in $(kubectl get --raw=/logs/apiserver/ | awk -F'>' '{print $2}' | sed 's/<\/a$//' ); do kubectl get --raw=/logs/apiserver/$file 2>/dev/null >> /tmp/audit.log ; done
```

Now all events are stored in a temporary file on your local machine.

## Filter out undesired events

There are different options to filter the audit log. In any case one needs to have [jq](https://github.com/jqlang/jq) installed.

1. Filter by verb

```bash
cat /tmp/audit.log | head -n 1 | jq '. | select(.verb=="delete")'
```

1. Filter by user that has performed the action

```bash
cat /tmp/audit.log | jq '. | select(.user.username|test("joe."))'
```

1. Filter by the resources modified

```bash
cat /tmp/audit.log | jq '. | select(.objectRef.name=="prometheus-prometheus-exporters-tls-assets")'
```

## Using Loki

Today all vintage Management Clusters have Loki instance deployed with audit logs included. So we can leverage on Loki to get the logs. Future weeks we will extend Loki to vintage Workload Clusters too. Example of query:

```
{cluster_id="myCluster",scrape_job="audit-logs"} |= `` | json | user_username=`joe@giantswarm.io`
```

__Note__: In json filter to access nested properties you use `_` for getting a child property as the example above (user.username -> user_username).
