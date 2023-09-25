---
title: "Audit Logs Troubleshooting"
owner:
- https://github.com/orgs/giantswarm/teams/team-horizon
confidentiality: public
---

How can I check the action of certain user in a cluster? How can I get more details about certain event on the cluster?

## Gather all logs

Till we have audit logs in loki installation is handy to have some commands at hand to debug audit logs. First we need to collect all logs available. Since API only retain certain amount of audit logs depending on size, you my not have enough data to get the evidence you are looking too. You can check how old are the log files with `for file in $(kubectl get --raw=/logs/apiserver/ | awk -F'>' '{print $2}' | sed 's/<\/a$//' ); do echo $file; done`. If the event you are looking for is inside the time window then start dumping all data to your local to work more efficient.

```bash
for file in $(kubectl get --raw=/logs/apiserver/ | awk -F'>' '{print $2}' | sed 's/<\/a$//' ); do kubectl get --raw=/logs/apiserver/$file 2>/dev/null >> /tmp/audit.log ; done
```

Now all the events are in your local in a temporal file.

## Filter out undesired events

Now you have different options to filter through the logs. I saw you here different examples. Be aware you need to have [jq](https://github.com/jqlang/jq) installed in your system.

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
