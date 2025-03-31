---
title: "Scheduling a cronjob to patch resources"
owner:
- https://github.com/orgs/giantswarm/teams/team-planeteers
component:
  - cluster
description: "Help to debug common problems"
classification: public
---

This document describes how to schedule a cronjob to patch resources in a cluster. This can be useful in many cases, for instance:

- the customer would like to change the instance type used in a nodepool while they upgrade the cluster (e.g. moving from `m5` to `m6a` instances on AWS)
- the customer would like to roll the nodes at a given time (e.g. at 05:00 AM) via our `aws-rolling-node-operator`

## The resources

### Permissions

First of all, our `CronJob` needs to be able to apply changes in the custom resources (CRs) in our cluster. Therefore, we will create the following resources for RBAC. Replace `$ORG` with your organization name and the `rules` section to match with the API Groups and resources you want to patch. The example below is done with the `AWSMachineDeployment` (AWS nodepool) CR in mind.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubectl-patch-sa
  namespace: org-$ORG
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kubectl-patch-role
  namespace: org-$ORG
rules:
- apiGroups: ["infrastructure.giantswarm.io"]
  resources: ["awsmachinedeployments"]
  verbs: ["get", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubectl-patch-rolebinding
  namespace: org-$ORG
subjects:
- kind: ServiceAccount
  name: kubectl-patch-sa
  namespace: org-$ORG
roleRef:
  kind: Role
  name: kubectl-patch-role
  apiGroup: rbac.authorization.k8s.io
```

## The CronJob

Now that we have the permissions, we can create the CronJob. The CronJob will run on Tuesdays at 05:30 AM UTC and will patch the `AWSMachineDeployment` CRs in the cluster. Replace `$ORG` with your organization name and the `spec.jobTemplate.spec.template.spec.containers[0].args` section to match with the API Groups and resources you want to patch. The example below is done with the `AWSMachineDeployment` (AWS nodepool) CR in mind. **Please keep in mind that the default timezone is UTC!**

In the example below, we are setting:

- the `dockerVolumeSizeGB` to `50`
- the `kubeletVolumeSizeGB` to `50`
- the `instanceType` of the nodepool to `m6a.4xlarge`
- the `useAlikeInstanceTypes` flag to `true`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: patch-aws-machine-deployments
  namespace: org-$ORG
spec:
  schedule: "30 05 * * 2"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: kubectl-patch-sa
          containers:
            - name: kubectl-patch-container-abc12
              image: bitnami/kubectl:latest
              command: ["/bin/sh"]
              args:
                - "-c"
                - "kubectl patch awsmachinedeployments.infrastructure.giantswarm.io abc12 -n org-$ORG --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/nodePool/machine/dockerVolumeSizeGB\", \"value\": 50}, {\"op\": \"replace\", \"path\": \"/spec/nodePool/machine/kubeletVolumeSizeGB\", \"value\": 50}, {\"op\": \"replace\", \"path\": \"/spec/provider/worker/instanceType\", \"value\": \"m6a.4xlarge\"}, {\"op\": \"replace\", \"path\": \"/spec/provider/worker/useAlikeInstanceTypes\", \"value\": true}]'"
            - name: kubectl-patch-container-xyz89
              image: bitnami/kubectl:latest
              command: ["/bin/sh"]
              args:
                - "-c"
                - "kubectl patch awsmachinedeployments.infrastructure.giantswarm.io xyz89 -n org-$ORG --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/nodePool/machine/dockerVolumeSizeGB\", \"value\": 50}, {\"op\": \"replace\", \"path\": \"/spec/nodePool/machine/kubeletVolumeSizeGB\", \"value\": 50}, {\"op\": \"replace\", \"path\": \"/spec/provider/worker/instanceType\", \"value\": \"m6a.4xlarge\"}, {\"op\": \"replace\", \"path\": \"/spec/provider/worker/useAlikeInstanceTypes\", \"value\": true}]'"
          restartPolicy: OnFailure
```

## Once you are done

Once you are done, simply run a `kubectl delete -f` of the two files you used to create the aforementioned resources!
