---
title: "Kyverno Stuck In Pending Upgrade"
owner:
- https://github.com/orgs/giantswarm/teams/team-shield
confidentiality: public
---

There have been cases where during cluster upgrades, for example from AWS v18 -> v19, the Kyverno migration logic takes longer than the default `app-operator` installation timeout. This can result in Kyverno getting stuck in Helm `pending-upgrade` and requiring manual intervention.

To force the resolution the best idea is to rollback to previous version, which will cause `app-operator` to re-reconcile the App and refresh the stuck Helm charts.

```
CLUSTER_ID=XXXXX; helm rollback -n "$CLUSTER_ID" "$CLUSTER_ID"-security-bundle $(helm ls -n $CLUSTER_ID -f "$CLUSTER_ID"-security-bundle -o yaml | yq '.[].revision') --force
```
