---
title: "Switch from AWS-CNI, Calico and Kube-Proxy to Cilium"
owner:
- https://github.com/orgs/giantswarm/teams/team-phoenix
confidentiality: public
---

This document explains how the upgrade from v18 to v19 legacy releases works and how it can break and affect customer workloads.
This is currently implemented in AWS only.

## Initial state / before the upgrade

Before the upgrade, all Nodes are running `aws-node` pod, `kube-proxy` pod and `calico` pod.

Note: switching CNI in a running cluster without a significant downtime in customer workloads require the old and the new CNI plugin to be running alongside eachother during the migration process.
This means the `pod CIDR` of the new CNI needs to be different from the old one.

## Upgrade process

As soon as the upgrade to v19 is triggered, a bunch of things happen. The following paragraphs outline the process step by step.

### Step 1: Annotation of CRs to prepare for the upgrade

AWS admission controller adds 2 annotations in the `Cluster` CR:

- `cilium.giantswarm.io/pod-cidr`: this annotation holds the podCIDR to be used by Cilium. The default value chosen is `192.168.0.0/16` and can be set before the upgrade in case the default value is not good. Please note that, at the end of the migration process, the cluster will be using a different pod CIDR for all pods.
- `cilium.giantswarm.io/force-disable-cilium-kube-proxy`: this annotation makes `cluster-operator` aware of the fact we don't want to use the `kube-proxy` feature of `Cilium`. This is required because cilium and legacy kube-proxy can't run on the same node as that would cause a downtime in the workloads.

Defaulting is implemented [here](https://github.com/giantswarm/aws-admission-controller/blob/v4.6.0/pkg/aws/v1alpha3/cluster/mutate_cluster.go#L288).

### Step 2: New app creation

After the Cluster CR is updated, `cluster-operator` ensures the new set of apps in the WC, including the creation of the new Cilium app.
Please note that `cluster-operator` also provides a default configuration for the cilium App. See code [here](https://github.com/giantswarm/cluster-operator/blob/v5.2.0/service/controller/resource/clusterconfigmap/desired.go#L100).

Please note that the configuration is influenced by the annotation set in Step 1.

### Step 3: aws-node preparation

Now `aws-operator` kicks in and start by doing some preparation work to ensure a smooth upgrade process.
First, `aws-operator` changes the `aws-node` daemonset in `kube-system` to:

- Add the `AWS_VPC_K8S_CNI_EXCLUDE_SNAT_CIDRS` ENV var to the Cilium CIDR (the value of the `cilium.giantswarm.io/pod-cidr` annotation set to the `Cluster` CR in step 1). This is needed to prevent `aws-node` from SNATting traffic from the old podCIDR to the new podCIDR as this would break kubernetes networking (Pod to Pod traffic has to be NAT free by design). See [code](https://github.com/giantswarm/aws-operator/blob/v14.0.0/service/controller/resource/prepareawscniformigration/create.go#L83).
- Add a second container named 'routes-fixer' in the PodSpec. The goal of this container is to add a route entry in the routing tables for AWS CNI network interfaces to route traffic towards Cilium pods through the cilium overlay network interface. Without this change, aws-CNI pods wouldn't be able to connect to cilium pods. See [code](https://github.com/giantswarm/aws-operator/blob/v14.0.0/service/controller/resource/prepareawscniformigration/create.go#L108).

Note: At the end of this first stage, all nodes are still running `aws-node` (with the changes defined above), `kube-proxy` and `calico` and they keep working as they were doing before. A `cilium` pod is also running on all nodes, but it will still be crashlooping. The reason is we use the `kubernetes` IPAM mode in cilium and that means we need to change controller-manager's flags to add `--cluster-cidr` and `--allocate-node-cidrs`.
We need to roll the master nodes in order for this change to be effective.

### Step 4: Master nodes rolling

`aws-operator` begins rolling master nodes, one by one. Once the leader cluster-operator replicas is started, `cilium` replicas begin to become Ready.

Note: even if Cilium is running and ready, pods' networking is still managed by AWS-CNI in old nodes (nodes not replaced yet). This happens because Cilium's config file has a lower priority than AWS-CNI one (See [cluster-operator](https://github.com/giantswarm/cluster-operator/blob/v5.2.0/service/controller/resource/clusterconfigmap/desired.go#L113)).

When all master nodes are rolled, we end up in the following situation:

- Master nodes are running `cilium`, `kube-proxy`, and `calico` but not `aws-node` any more. Networking for pods running in those nodes is managed by `cilium`. Please note that Kubernetes Services are still implemented by `kube-proxy` and the kube-proxy-replacement feature in Cilium is still disabled (thanks to the annotation in `Cluster` CR set by `aws-admission-controller` in Step 1 and still in place).
- Worker nodes are still running `aws-node`, which manages networking for all pods in the node.

At this stage all pods can connect to each other normally, let's understand why:

- `aws-node` pods can connect to other `aws-node` pods running in the same node or in another node as they normally did, there is no change here.
- `cilium` pods can connect to other `cilium` pods in the same node or in another node using the cilium overlay network.
- `cilium` pods treat `aws-node` traffic as non-pod traffic and forwards it to the default gateway. This works fine as the default gateway is on the VPC and the VPC knows how to handle it.
- `aws-node` pods send traffic to cilium-managed pods to the cilium interface thanks to the routing rule injected by the sidecar pod in `aws-node`. Also, there is no SNAT happening (see step 2).

### Step 5: Node pools rolling

Next, `aws-operator` starts rolling the node pools.
Process is very similar as what happened with master nodes. Workers are replaced in batches and new nodes come up without `aws-node` pod running and with networking handled by `cilium` only. Pod to Pod and Node to Pod traffic keeps working normally as described in the previous paragraph.

Eventually all nodes will be running without `aws-node` and all pods in the cluster will be managed by `cilium`. Please note that `kube-proxy` is still running and the `kube-proxy-replacement` feature is still disabled in the `cilium` pods. Calico is also still running.

### Step 6: cleanup and switch to cilium's kube-proxy

The final phase of the upgrade process is about removing `aws-node`, `kube-proxy`, and `calico` and enabling `kube-proxy-replacement` feature in `cilium`.

This is the sequence of operations made by `aws-operator`:

- Delete all manifests regarding aws-node, kube-proxy and calico from the cluster (see [code](https://github.com/giantswarm/aws-operator/blob/v14.0.0/service/controller/resource/awscnicleaner/create.go#L85)).
- Remove the `cilium.giantswarm.io/force-disable-cilium-kube-proxy` annotation from the `Cluster` CR. This will make `cluster-operator` change the `cilium` App's configuration and reinstall cilium in all nodes with the `kube-proxy-replacement` enabled (see [code](https://github.com/giantswarm/aws-operator/blob/v14.0.0/service/controller/resource/awscnicleaner/create.go#L103)).
- Edit the `AWSCluster` CR to update the `Spec.Provider.Pods.CIDRBlock` field with the new `cilium` podCIDR and delete the `cilium.giantswarm.io/pod-cidr` annotation from the Cluster CR (see [code](https://github.com/giantswarm/aws-operator/blob/v14.0.0/service/controller/resource/awscnicleaner/create.go#L147)).

This is the most critical part of the upgrade and the moment when customer workloads are more likely to be affected. Once `kube-proxy` pods are deleted and before `cilium` pods are restarted with the new settings, the cluster is temporarily in a "frozen" state: `kube-proxy`'s iptables rules are still in place, but if there is any change in any of the pods those won't be reflected as `kube-proxy` is not running. In normal circumstances this is a situation that lasts only a few seconds though so impact should be minimal.

Another critical process happening in this phase is the cleanup of `kube-proxy` rules. Cilium pods, once `kube-proxy-replacement` is enabled, run a new init container that cleans up the legacy iptables rules left behind by `kube-proxy`. This is unfortunately needed as otherwise k8s services won't be working properly.

## Known limitations

- In step 1, the defaulting of `cilium.giantswarm.io/pod-cidr` annotation is provided as a best effort, only on clusters that were previously using default values for the podCIDR. If this annotation cannot be created safely, `aws-admission-controller` stops the upgrade process by rejecting the Update request. It's always possible to set the annotation before triggering the upgrade. `aws-admission-controller` will ensure the values is valid when the upgrade is triggered.
- This whole process requires automated changes to the `Cluster` and `AWSCluster` CRs and thus is not meant to be compatible with GitOps.
- While we worked hard to prevent that from happening, it's still possible that some downtime will be happening on the workloads. This is a CNI switch after all.
- The AWS CNI Pod subnets will remain after the upgrade, they will not be deleted while upgrading to v19 release. We will work on removing them in future releases if neccessary.  

## AWS-CNI leftovers

After a successful upgrade of a v18 cluster to v19, there will be a few AWS resources originally created for AWS CNI that will not be cleaned up. Those resources include:

- Subnets (one for each availability zone)
- Routing table
- VPC CIDR block.

We keep those resources around for two reasons:

1. to ease a rollback. Should anything unexpected happen during the upgrade, keeping those resources will make it easier to revert to v18.
2. to avoid upgrade errors. It's not uncommon to have VPC peerings set up agains AWS CNI subnets and that would make automated deletion through cloudformation fail.

In order to clean up those resources, it's enough to remove the `aws-operator.giantswarm.io/legacy-aws-cni-pod-cidr` annotation from the `AWSCluster` CR *after the upgrade is completed* and force an update of the `tccp` cloudformation stack. Please ask your AE if you need help.
