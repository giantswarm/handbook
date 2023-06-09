---
title: "Test Environments"
description: >
  When working with test environments there are a couple of things we should try to stick to process wise in order to make everyones life easier and avoid cost.
confidentiality: public
---

## Avoid any avoidable cost

Create test clusters in a way so that they are as cheap as possible and as expensive as necessary.

- Use a **single master node** if possible (AWS only)
- Use **spot instances** (AWS only)
- Use only **one availability zone** if possible. (Cross AZ traffic costs extra.)
- Use the **cheapest possible instance type**. On AWS, use `c5.xlarge`.
- **Minimize the amount of worker nodes**. Set the `min` number of worker nodes to 1 instead of 3 (AWS and Azure only).
- **Delete your test cluster** as soon as you don't need it any more.

## Label the cluster

Note: This is not possible on KVM.

To be able to keep a test cluster for more than 4 hours, add the following [labels](https://docs.giantswarm.io/advanced/labelling-workload-clusters/):

- `creator`: The value should be your Slack user name. With this label, others in the company can address you in case of an issue.
- `keep-until`: As a value, set an ISO date string (format: `YYYY-MM-DD`) for the last day this cluster should still keep running. This is to be evaluated against UTC date/time.
- Your cluster wont' be deleted until you remove the annotation:
```
annotations:
  alpha.giantswarm.io/ignore-cluster-deletion: "true"
```

Clusters

- older than 4 hours AND
- where the `keep-until` date is in the past OR where no `keep-until` label is present
- where `alpha.giantswarm.io/ignore-cluster-deletion` annotation is set to `false`

can be deleted by anyone without notice or [cluster-cleaner](https://github.com/giantswarm/cluster-cleaner) operator will clean them up automatically.

### Leave The Environment Better Than You Found It

- Once you are done with testing, redeploy master before leaving the
  installation.
- Check the dedicated alert channels for the installation you tested on and make
  sure there is nothing broken.
- In case the test environment is broken or unusable, try to fix it, then escalate
  the situation to Biscuit.
