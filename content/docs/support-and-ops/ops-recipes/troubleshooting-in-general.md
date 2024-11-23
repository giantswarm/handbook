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

## Kubectl debug

`kubectl debug` helps debugging cluster resources using interactive debugging containers.

The problem is by default these containers are not very secure, and get denied by our cluster security policies as shown here:
```
$ kubectl debug -n loki loki-backend-0 --image alpine -- /bin/sh
Defaulting debug container name to debugger-9fp9k.
Error from server: admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/loki/loki-backend-0 was blocked due to the following policies 

disallow-capabilities-strict:
  require-drop-all: 'validation failure: Containers must drop `ALL` capabilities.'
disallow-privilege-escalation:
  privilege-escalation: 'validation error: Privilege escalation is disallowed. The
    fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation,
    and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must
    be set to `false`. rule privilege-escalation failed at path /spec/ephemeralContainers/0/securityContext/'
```

### Setting custom securityContext with kubectl debug

⚠️This requires at least `kubectl`v1.31

You should create a yaml file with your securityContext. We should call it `customspec.yaml`:
```yaml
securityContext:
  fsGroup: 10001
  runAsGroup: 10001
  runAsNonRoot: true
  runAsUser: 10001
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  seccompProfile:
    type: RuntimeDefault
```

Then you can run your debug container like so:
```
kubectl debug -n loki loki-backend-0 -it --image alpine --custom customspec.yaml -- /bin/sh
```

Feel free to choose your debug image, so you have the tools you need.
