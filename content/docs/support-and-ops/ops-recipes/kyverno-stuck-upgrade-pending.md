---
title: "Kyverno Stuck In Pending Upgrade"
owner:
- https://github.com/orgs/giantswarm/teams/team-shield
confidentiality: public
---

There have been cases where the cluster upgrades, for example from AWS v18 -> v19, provoked the security bundle and in particular Kyverno get stuck in Helm `pending-upgrade` till manual intervention.

To force the resolution the best idea is to rollback to previous version.

```
CLUSTER_ID=XXXXX; helm rollback -n "$CLUSTER_ID" "$CLUSTER_ID"-security-bundle $(helm ls -n $CLUSTER_ID -f "$CLUSTER_ID"-security-bundle -o yaml | yq '.[].revision') --force
```
