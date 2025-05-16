---
title: Test environments
description: >
  When working with test environments (clusters), please pay attention to the instructions on this page to avoid trouble and save money.
classification: public
weight: 40
---

## Creating a workload cluster for test purposes

The dev portal provides an easy form to create a test cluster. Please give this one a try. It's in an early stage as of March 2025, so Honeybadger would love to get your feedback.

[Create a test cluster](https://devportal.giantswarm.io/create/templates/default/create-test-cluster)

Apart from that, you can also use Happa (where supported) or `kubectl-gs`.

## Avoid any avoidable cost

Create test clusters in a way so that they are as cheap as possible and as expensive as necessary.

- Use **spot instances** (AWS only)
- Use only **one availability zone** if possible. (Cross AZ traffic costs extra.)
- Use the **cheapest possible instance type**. On AWS, use `c5.xlarge`.
- **Minimize the amount of worker nodes**. Set the `min` number of worker nodes to 1 instead of 3 (AWS and Azure only).
- **Delete your test cluster** as soon as you don't need it anymore.
  - [Delete the workload cluster app](https://docs.giantswarm.io/getting-started/provision-your-first-workload-cluster/#deleting-workload-cluster) on the management cluster, the [cluster-apps-operator](https://github.com/giantswarm/cluster-apps-operator/) will take care of the rest:  
    `kubectl delete -n org-${ORGANIZATION} app/${CLUSTER_NAME}`
- On AWS vintage:
  - Use a **single control plane node** if possible

## Label the cluster

Note: This is not possible on KVM.

To be able to keep a test cluster for more than 4 hours, add the following [labels](https://docs.giantswarm.io/advanced/labelling-workload-clusters/):

- `creator`: The value should be your Slack username. With this label, others in the company can address you in case of an issue.
- `keep-until`: As a value, set an ISO date string (format: `YYYY-MM-DD`) for the last day this cluster should still keep running. This is to be evaluated against UTC date/time.
- Your cluster won't be deleted until you remove the annotation:
```
annotations:
  alpha.giantswarm.io/ignore-cluster-deletion: "true"
```

Clusters are deleted automatically by [cluster-cleaner](https://github.com/giantswarm/cluster-cleaner) under the following conditions:

- the cluster is older than **4 hours**
- AND ( the `keep-until` label has a date in the past, or the label is not set)
- AND ( the `alpha.giantswarm.io/ignore-cluster-deletion` annotation is set to `false` or not set )

Also anyone is allowed to delete these clusters without notice.

### Leave the environment better than you found it

- If you replaced any management cluster components: Once you are done with testing, redeploy the original versions.
- Check the dedicated alert channels for the installation you tested on and make sure there is nothing broken.
- In case the test environment is broken or unusable, try to fix it, then escalate the situation to a KaaS team.
