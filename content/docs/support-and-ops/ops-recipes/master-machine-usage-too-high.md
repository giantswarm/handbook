---
title: "Master Machine Usage Too High"
owner:
- https://github.com/orgs/giantswarm/teams/team-phoenix
component:
  - debug-toolbox
description: "What to do once we are paged for 'workload cluster master machine CPU usage is too high'."
classification: public
---

What to do once we are paged for "workload cluster master machine CPU usage is too high".

## Identify the culprit

1. Check the master conditions to see if `kubelet` has reported any problem

    ```sh
    » kubectl describe node master-XXXX
    ...
    Conditions:
      Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
      ----                 ------  -----------------                 ------------------                ------                       -------
      NetworkUnavailable   False   Tue, 11 Apr 2023 11:30:18 +0200   Tue, 11 Apr 2023 11:30:18 +0200   CiliumIsUp                   Cilium is running on this node
      MemoryPressure       False   Thu, 04 May 2023 12:28:22 +0200   Fri, 28 Apr 2023 16:08:33 +0200   KubeletHasSufficientMemory   kubelet has sufficient memory available
      DiskPressure         False   Thu, 04 May 2023 12:28:22 +0200   Fri, 28 Apr 2023 16:08:33 +0200   KubeletHasNoDiskPressure     kubelet has no disk pressure
      PIDPressure          False   Thu, 04 May 2023 12:28:22 +0200   Fri, 28 Apr 2023 16:08:33 +0200   KubeletHasSufficientPID      kubelet has sufficient PID available
      Ready                True    Thu, 04 May 2023 12:28:22 +0200   Fri, 28 Apr 2023 16:08:33 +0200   KubeletReady                 kubelet is posting ready status
    ```

    There you can see if network, memory or disk could be behind the problem.

2. Check if there is any pod consuming lots of CPU/Mem

    ```sh
    kubectl resource-capacity -pu --sort mem.usage --node-labels node-role.kubernetes.io/control-plane=

    NODE                                          NAMESPACE          POD                                                                  CPU REQUESTS   CPU LIMITS      CPU UTIL      MEMORY REQUESTS   MEMORY LIMITS   MEMORY UTIL
    *                                             *                  *                                                                    10401m (86%)   13042m (108%)   2830m (23%)   31137Mi (67%)     43484Mi (93%)   32059Mi (69%)

    ip-10-0-5-112.eu-central-1.compute.internal   *                  *                                                                    3585m (89%)    3807m (95%)     1349m (33%)   10609Mi (69%)     14293Mi (93%)   11348Mi (73%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         aws-admission-controller-6bb6dfb7df-z8hkg                            15m (0%)       75m (1%)        1m (0%)       100Mi (0%)        167Mi (1%)      28Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        aws-cloud-controller-manager-w89jc                                   15m (0%)       0m (0%)         2m (0%)       100Mi (0%)        0Mi (0%)        29Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         aws-operator-14-15-0-54559bc49b-26xcg                                15m (0%)       37m (0%)        2m (0%)       100Mi (0%)        100Mi (0%)      61Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         cert-exporter-daemonset-wqwnr                                        50m (1%)       150m (3%)       1m (0%)       50Mi (0%)         50Mi (0%)       15Mi (0%)
    ...
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         oauth2-proxy-55568fc5cc-h85d6                                        100m (2%)      100m (2%)       1m (0%)       100Mi (0%)        100Mi (0%)      23Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   promtail           promtail-454w6                                                       100m (2%)      200m (5%)       13m (0%)      128Mi (0%)        128Mi (0%)      87Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         vault-exporter-6c64bbc55d-zd7km                                      100m (2%)      100m (2%)       1m (0%)       50Mi (0%)         50Mi (0%)       23Mi (0%)
    ```

    You can install the above tool with `krew` or check [here](https://github.com/robscott/kube-capacity):

    ```sh
    kubectl krew install resource-capacity
    ```

3. Check `K8s API performance` grafana dashboard on teh installation to verify the ETCD and node pressure if correct

    ```sh
    » export INSTALLATION=XXXXX
    » opsctl open -i $INSTALLATION -a grafana
    ```

    __Note__: If you notice the CPU and memory overloads the machine for last days, you can think on growing the master machine to next instance type.
