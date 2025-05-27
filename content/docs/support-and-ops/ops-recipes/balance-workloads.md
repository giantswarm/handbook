---
title: Balance nodes with descheduler
owner:
  - https://github.com/orgs/giantswarm/teams/team-phoenix
description: How to balance workloads across nodes with descheduler
last_review_date: 2025-05-27
classification: public
---
In Giant Swarm, we rely on [descheduler](https://github.com/giantswarm/descheduler-app) to help redistribute pods based on specific policies. Here you see how to run descheduler in cronjob mode to automate this process, ensuring the cluster is balanced and optimized.

## Configuration

1. Prepare the configuration for the policy. The default policy can be found [here](https://github.com/giantswarm/descheduler-app/blob/main/helm/descheduler/values.yaml#L72) and it is valid for most cases. If you don't know how to adjust the policy, skip this step and use the default one.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: descheduler-policy
  namespace: kube-system
data:
  policy.yaml: |
    apiVersion: "descheduler/v1alpha1"
    kind: "DeschedulerPolicy"
    profiles:
      - name: default
      ...
```

You may want to adjust the policy to your needs. Next is the list of more meaningful plugins that you can use:

### 1. **PodAntiAffinity**

- **Purpose**: Ensures that pods that should not be co-located on the same node due to pod anti-affinity rules are rescheduled.
- **Configuration**:

```yaml
strategies:
  "PodAntiAffinity":
    enabled: true
```


### 2. **RemoveDuplicates**

- **Purpose**: Evicts duplicate pods (i.e., pods with the same owner reference) that are scheduled on the same node, which can help balance replicas across nodes.
- **Configuration**:

```yaml
strategies:
  "RemoveDuplicates":
    enabled: true
```


### 3. **LowNodeUtilization**

- **Purpose**: Evicts pods from underutilized nodes to better distribute workloads across the cluster.
- **Configuration**:

```yaml
strategies:
  "LowNodeUtilization":
    enabled: true
    params:
      nodeResourceUtilizationThresholds:
        thresholds:
          cpu: 40
          memory: 40
          pods: 10
        targetThresholds:
          cpu: 90
          memory: 90
          pods: 50
```

  - **Thresholds**: Define the minimum utilization level below which a node is considered underutilized.
  - **TargetThresholds**: Define the desired utilization level after redistribution.

### 4. **HighNodeUtilization**

- **Purpose**:  Move pods from nodes with low utilization to nodes with high utilization, together with ClusterAutoScaler to remove idle nodes from the cluster. The primary goal is to enhance node utilization.
- **Configuration**:

```yaml
strategies:
  "HighNodeUtilization":
    enabled: true
    params:
      nodeResourceUtilizationThresholds:
        thresholds:
          cpu: 80
          memory: 80
          pods: 80
```

  - **Thresholds**: Define the maximum utilization level above which a node is considered overutilized.

### 5. **RemovePodsViolatingNodeAffinity**

- **Purpose**: Evicts pods that are scheduled on nodes in violation of their node affinity rules.
- **Configuration**:

```yaml
strategies:
  "RemovePodsViolatingNodeAffinity":
    enabled: true
```


### 6. **RemovePodsViolatingInterPodAntiAffinity**

- **Purpose**: Evicts pods violating inter-pod anti-affinity rules to ensure proper distribution according to these rules.
- **Configuration**:

```yaml
strategies:
  "RemovePodsViolatingInterPodAntiAffinity":
    enabled: true
```


### 7. **RemovePodsViolatingTopologySpreadConstraint**

- **Purpose**: Evicts pods that violate topology spread constraints, which ensure even distribution across specified topology domains.
- **Configuration**:

```yaml
strategies:
  "RemovePodsViolatingTopologySpreadConstraint":
    enabled: true
```


## Deployment

Deploy the app from the [Giant Swarm app catalog](https://github.com/giantswarm/descheduler-app):

```sh
export ORG=<your-org>
export CLUSTER=<your-cluster>
kubectl gs template app \
  --catalog giantswarm \
  --name descheduler \
  -- user-configmap /tmp/values.yaml \ # Optional, if you want to customize the descheduler policy
  --target-namespace org-$ORG \
  --organization $ORG \
  --cluster-name $CLUSTER \
  --version 1.0.1 > descheduler-app.yaml
```

In case of customize the profile, save your config values to a file:

```sh
cat <<EOF > /tmp/values.yaml
deschedulerPolicy:
  profiles:
    - name: default
      pluginConfig:
        - name: "DefaultEvictor"
          args:
            ignorePvcPods: true
            ...
EOF
```

Then add the flag `--user-config=/tmp/values.yaml` to the previous command.

And apply it to the platform API (aka MC API):

```sh
kubectl apply -f descheduler-app.yaml
```

Now the scheduler cronjob has been created and soon it will spawn a new job. By default, the cronjob runs every 2 minutes. **Since we want to use it once, we will remove the app after the job is done.**

In case you want to leave the app running, you can adjust the cronjob schedule by editing the values as described above. Tunning `schedule: "*/2 * * * *"` value to your needs and reapply the app.

1. Also, you can check the logs of the descheduler pods to see the actions taken by the descheduler.

```sh
kubectl logs -n kube-system descheduler-<pod-id>
```

You will see messages of pods being evicted and rescheduled.
