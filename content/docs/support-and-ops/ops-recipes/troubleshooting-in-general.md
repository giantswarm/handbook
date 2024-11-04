---
title: Troubleshooting
owner:
  - https://github.com/orgs/giantswarm/teams/team-planeteers
description: "Help to debug common problems"
classification: public
---

## Debug toolbox

In Giant Swarm we have created a [debug-toolbox](https://github.com/giantswarm/debug-toolbox) that can be easily deployed in your cluster to help you debug common problems. The toolbox contains a set of tools that can be used to debug common problems in Kubernetes clusters.

### Quick app install

```sh
export CLUSTER=<cluster-name>
export NAMESPACES=<namespace>
export ORG=<org>
kgs template app --catalog giantswarm --name debug-toolbox --namespace org-$ORG --target-namespace $NAMESPACE --version 1.1.0 --cluster-name $CLUSTER
```

### Adding custom policy exceptions

In case you need to add custom policy exceptions to the debug toolbox, you can do so by providing a `user-configmap`. The `user-configmap` should be a yaml file that contains the policy exceptions you want to add.

```sh
export CLUSTER=<cluster-name>
export NAMESPACES=<namespace>
export ORG=<org>
kgs template app --catalog giantswarm --name debug-toolbox --namespace org-$ORG --target-namespace $NAMESPACE --version 1.1.0 --cluster-name $CLUSTER --user-configmap=helm/debug-toolbox/values_pss_example.yaml
```

### Install via Helm

As an alternative to the `kgs` command, you can also install the debug toolbox via Helm:

```sh
helm template debug ./helm/debug-toolbox --values=/<custom_values>/values.yaml
```
