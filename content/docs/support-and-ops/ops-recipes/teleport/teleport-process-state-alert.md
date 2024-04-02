---
title: "Teleport Process State Is Not Okay"
owner:
- https://github.com/orgs/giantswarm/teams/team-bigmac
confidentiality: public
---

This alert indicates that the state of teleport cluster is not in healthy state (state: 0).

State of the teleport process: 0 - ok, 1 - recovering, 2 - degraded, 3 - starting.

# Check if Teleport auth and proxy pods are running

First, login to teleport production cluster

```
$ tsh login --auth giantswarm --proxy 'teleport.giantswarm.io:443'
$ tsh kube login teleport.giantswarm.io
```

Then, check if teleport auth pods are running:

```
$ kubectl get pods -l app.kubernetes.io/component=auth -n teleport
```

Then, check if teleport proxy pods are running:

```
$ kubectl get pods -l app.kubernetes.io/component=proxy -n teleport
```


Then, check the logs for auth and proxy prod for errors:

```
$ kubectl get pods -l app.kubernetes.io/component=auth -n teleport
$ kubectl get pods -l app.kubernetes.io/component=proxy -n teleport
```