---
title: "Karpenter in Vintage AWS Workload Clusters"
weight: 10
description: >
  This page describes how we are using Karpenter with some of our customers and talks about current status and configuration.
classification: public
---

## Installing Karpenter

Karpenter can be installed as a Managed App either via Happa or via an App CR. Before installing Karpenter, you need to make sure that the following prerequisites are met:
- a nodepool to be used for nodes managed by Karpenter must be available. It is totally fine to use an already-existing nodepool that is currently managed via Cluster Autoscaler. However, regardless of whether the nodepool is newly created or already existing, it must have at least one "standard" (managed via Cluster Autoscaler) node running
- some AWS resources must be created as per the Karpenter App [README](https://github.com/giantswarm/karpenter-app/#aws-resources). It is enough to click on the link, ensure that the AWS account and the region are correct, and then click on the "Create" button. This will create the required resources in the AWS account.

In the future, the creation of the AWS resources will be automated. For now, it is manual.

## Karpenter configuration

### Fundamentals

The configuration of Karpenter happens in Workload Clusters directly via `Provisioner` CRs. If you want to centrally manage `Provisioner` CRs in a Git repository, you might consider using Flux in the Management Cluster and rely on its `out-of-band delivery` functionality.

### The `Provisioner` CR

Is described in the [Karpenter docs](https://github.com/aws/karpenter-provider-aws/blob/v0.27.0/website/content/en/v0.26.1/concepts/provisioners.md). It basically states how Karpenter should create nodes. Beware that Karpenter only create "single" nodes - it does NOT rely on the concept of AutoScaling Group. This differs from the way we usually manage nodes in our Giant Swarm nodepools.

### How to configure provisioners

Our suggestion is the following:
- each nodepool should have at least one "normal" node running. In other words, `min` needs to be set to 1. `max` can be set to 1 as well in case you want Karpenter to manage all the nodes in the nodepool. If you want to have some nodes managed by Karpenter and some nodes potentially managed by Cluster Autoscaler, you can set `max` to a higher value.
- in case your nodepool needs to be made of 100% spot instances, create one `Provisioner` with `capacity-type: ["spot"]`
- in case your nodepools needs to be made of spot instances, but you want to fall back to on-demand in case spot instances of the required types are not available, create two provisioners: one with `capacity-type: ["spot"]` and high `weight`, and another one with `capacity-type: ["on-demand"]` and lower weight. These two can also be configured separately as per the example below
- each `Provisioner` has a `limits` section, which basically states when Karpenter should stop spinning up EC2 instances. For instance, if `limits` is set as 1000 vCPUs and 1000Gi of RAM, whenever Karpenter is reaching one of those values in total combined compute managed, it will stop spinning up Virtual Machines. We hence suggest very high limits in each provisioner in case the cluster needs to scale up to a very high number of nodes.

### An example

In the following example, we will create two provisioners working on the same nodepool:
- the higher priority Provisioner (`weight: 10`):
  - will create spot instances only
  - these instances need to be either `4xlarge` or `8xlarge` or `9xlarge` or `12xlarge` or `16xlarge`
  - these instances must not be small (no `t2`, `t3` or `t3a` instances)
- the lower priority Provisioner (`weight: 5`) will be used whenever the higher priority one can't spin up a required EC2 instance, for instance because there is no compute available in the AWS region.
  - it will create on-demand instances only
  - these instances can only be `m6a`, `m6i`, `m5` or `m5a` instances of size `4xlarge`. Whereas with spot instances we accept "whatever" as long as it is cheap, here we enforce stricter conditions since we are paying for the on-demand price

The following example shows a provisioner that works on a single-AZ nodepool. Nothing changes if the nodepool is multi-AZ, except for the fact that the provisioner will create nodes in all the AZs of the nodepool (specified in `topology.kubernetes.io/zone`).

```yaml
apiVersion: v1
items:
- apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: spot-provisioner-abc12
  spec:
    consolidation:
      enabled: true
    labels:
      cluster: testcluster123
      managed-by: karpenter
      node.kubernetes.io/worker: ""
      nodepool: abc12
      role: worker
    limits:
      resources:
        # 4000 vCPUs and 4000Gi of RAM
        cpu: 4k
        memory: 4000Gi
    provider:
      launchTemplate: testcluster123-abc12-LaunchTemplate
      subnetSelector:
        giantswarm.io/machine-deployment: abc12
      tags:
        Name: testcluster123-karpenter-spot-worker
        cluster: testcluster123
        giantswarm.io/cluster: testcluster123
        managed-by: karpenter
        nodepool: abc12
    requirements:
    - key: karpenter.k8s.aws/instance-family
      # avoid small instance families
      operator: NotIn
      values:
      - t3
      - t3a
      - t2
    - key: karpenter.k8s.aws/instance-size
      # avoid instances that are too small or too big (e.g. `large` or `48xlarge`)
      operator: In
      values:
      - 4xlarge
      - 8xlarge
      - 9xlarge
      - 12xlarge
      - 16xlarge
    - key: karpenter.k8s.aws/instance-hypervisor
      operator: In
      values:
      - nitro
    - key: topology.kubernetes.io/zone
      operator: In
      values:
      - eu-central-1a
    - key: kubernetes.io/arch
      operator: In
      values:
      - amd64
    - key: karpenter.sh/capacity-type
      operator: In
      values:
      - spot
    - key: kubernetes.io/os
      operator: In
      values:
      - linux
    startupTaints:
    - effect: NoExecute
      key: node.cilium.io/agent-not-ready
      value: "true"
    ttlSecondsUntilExpired: 86400
    weight: 10  # higher priority
- apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: ondemand-provisioner-abc12
  spec:
    consolidation:
      enabled: true
    labels:
      cluster: testcluster123
      managed-by: karpenter
      node.kubernetes.io/worker: ""
      nodepool: abc12
      role: worker
    limits:
      resources:
        cpu: 4k
        memory: 4000Gi
    provider:
      launchTemplate: testcluster123-abc12-LaunchTemplate
      subnetSelector:
        giantswarm.io/machine-deployment: abc12
      tags:
        Name: testcluster123-karpenter-ondemand-worker
        cluster: testcluster123
        giantswarm.io/cluster: testcluster123
        managed-by: karpenter
        nodepool: abc12
    requirements:
    - key: karpenter.k8s.aws/instance-family
      # only use "standard" instance types
      operator: In
      values:
      - m6a
      - m6i
      - m5a
      - m5
    - key: karpenter.k8s.aws/instance-size
      operator: In
      values:
      # only use 4xlarge
      - 4xlarge
    - key: karpenter.k8s.aws/instance-hypervisor
      operator: In
      values:
      - nitro
    - key: topology.kubernetes.io/zone
      operator: In
      values:
      - eu-central-1a
    - key: kubernetes.io/arch
      operator: In
      values:
      - amd64
    - key: karpenter.sh/capacity-type
      operator: In
      values:
      - on-demand
    - key: kubernetes.io/os
      operator: In
      values:
      - linux
    startupTaints:
    - effect: NoExecute
      key: node.cilium.io/agent-not-ready
      value: "true"
    ttlSecondsUntilExpired: 86400
    weight: 5 # lower priority
kind: List
metadata:
  resourceVersion: ""
```

### Final notes

- As you can see, we are not disabling cluster-autoscaler. In order to have Karpenter spin up nodes instead of Cluster Autoscaler, you can use [this configuration](https://github.com/giantswarm/karpenter-app/#modify-cluster-autoscaler-values) - in particular, the `newPodScaleUpDelay: 300s` option is the relevant one
- Karpenter is still in alpha. It is not yet battle-tested. We are working on it and we are confident that it will be ready for production use soon. In the meantime, we suggest to use it in production only if you are comfortable with the fact that it is still in alpha state.
- We know some things are still being done manually. We are working on making Karpenter a first-class citizen.
- In case you want to use a nodepool that has many nodes in it, we suggest slowly scaling it down to min=max=1 after installing Karpenter. This will allow Karpenter to spin up new nodes as needed. You can then set the `max` to a higher value to have Cluster Autoscaler act as a fallback in case Karpenter can't spin up new nodes.
- Karpenter won't roll your nodes during upgrades. We hence suggest installing it on clusters already on Giant Swarm AWS release 19. Upgrades will require some manual intervention for now. Sync with your Account Engineer for more information.
