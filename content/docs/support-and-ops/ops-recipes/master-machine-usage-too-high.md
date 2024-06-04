---
title: "Master Machine Usage Too High"
owner:
- https://github.com/orgs/giantswarm/teams/team-phoenix
classification: public
---

What to do once we are paged for "workload cluster master machine CPU usage is too high". 

## Identify the culprit

1. Check the master conditions to see if kubelet has reported any problem
    
    ```
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
    
    ```
    kubectl resource-capacity -pu --sort mem.usage --node-labels node-role.kubernetes.io/control-plane=
    
    NODE                                          NAMESPACE          POD                                                                  CPU REQUESTS   CPU LIMITS      CPU UTIL      MEMORY REQUESTS   MEMORY LIMITS   MEMORY UTIL
    *                                             *                  *                                                                    10401m (86%)   13042m (108%)   2830m (23%)   31137Mi (67%)     43484Mi (93%)   32059Mi (69%)
    
    ip-10-0-5-112.eu-central-1.compute.internal   *                  *                                                                    3585m (89%)    3807m (95%)     1349m (33%)   10609Mi (69%)     14293Mi (93%)   11348Mi (73%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         aws-admission-controller-6bb6dfb7df-z8hkg                            15m (0%)       75m (1%)        1m (0%)       100Mi (0%)        167Mi (1%)      28Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        aws-cloud-controller-manager-w89jc                                   15m (0%)       0m (0%)         2m (0%)       100Mi (0%)        0Mi (0%)        29Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         aws-operator-14-15-0-54559bc49b-26xcg                                15m (0%)       37m (0%)        2m (0%)       100Mi (0%)        100Mi (0%)      61Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         cert-exporter-daemonset-wqwnr                                        50m (1%)       150m (3%)       1m (0%)       50Mi (0%)         50Mi (0%)       15Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        cert-manager-controller-5697745d4d-zjzzh                             50m (1%)       0m (0%)         4m (0%)       100Mi (0%)        0Mi (0%)        266Mi (1%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        cilium-operator-7744d4689c-hpknn                                     0m (0%)        0m (0%)         1m (0%)       0Mi (0%)          0Mi (0%)        42Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        cilium-zhcbh                                                         100m (2%)      0m (0%)         17m (0%)      100Mi (0%)        0Mi (0%)        298Mi (1%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        coredns-workers-cff679f78-blwf4                                      250m (6%)      0m (0%)         3m (0%)       192Mi (1%)        192Mi (1%)      42Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        ebs-csi-controller-678bcd7994-zl8pj                                  55m (1%)       0m (0%)         2m (0%)       211Mi (1%)        0Mi (0%)        138Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         etcd-backup-operator-b54fdc876-8dz92                                 11m (0%)       11m (0%)        5m (0%)       105Mi (0%)        269Mi (1%)      31Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         falco-4tsnk                                                          93m (2%)       111m (2%)       16m (0%)      121Mi (0%)        242Mi (1%)      93Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         falco-falco-exporter-76758                                           100m (2%)      100m (2%)       1m (0%)       128Mi (0%)        128Mi (0%)      20Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   flux-giantswarm    image-reflector-controller-b8f54fcb6-4zl79                           100m (2%)      0m (0%)         5m (0%)       100Mi (0%)        0Mi (0%)        53Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        k8s-api-healthz-ip-10-0-5-112.eu-central-1.compute.internal          50m (1%)       0m (0%)         13m (0%)      20Mi (0%)         0Mi (0%)        13Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        k8s-api-server-ip-10-0-5-112.eu-central-1.compute.internal           1133m (28%)    2550m (63%)     160m (4%)     7168Mi (46%)      11264Mi (73%)   4548Mi (29%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         k8s-audit-metrics-fb84d                                              23m (0%)       23m (0%)        11m (0%)      105Mi (0%)        105Mi (0%)      34Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        k8s-controller-manager-ip-10-0-5-112.eu-central-1.compute.internal   200m (5%)      0m (0%)         23m (0%)      200Mi (1%)        0Mi (0%)        588Mi (3%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        k8s-scheduler-ip-10-0-5-112.eu-central-1.compute.internal            200m (5%)      0m (0%)         2m (0%)       200Mi (1%)        0Mi (0%)        76Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kyverno            kyverno-56b45576df-ddx8q                                             100m (2%)      100m (2%)       726m (18%)    256Mi (1%)        1024Mi (6%)     558Mi (3%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         management-cluster-admission-controller-manager-f4df9d976-rbp4n      100m (2%)      250m (6%)       1m (0%)       250Mi (1%)        250Mi (1%)      25Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         net-exporter-z6ng4                                                   50m (1%)       0m (0%)         1m (0%)       75Mi (0%)         150Mi (0%)      16Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   kube-system        ingress-nginx-controller-app-546758487d-jqgrc                        500m (12%)     0m (0%)         2m (0%)       600Mi (3%)        0Mi (0%)        211Mi (1%)
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         node-exporter-z2qgt                                                  75m (1%)       0m (0%)         1m (0%)       50Mi (0%)         75Mi (0%)       26Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   monitoring         oauth2-proxy-55568fc5cc-h85d6                                        100m (2%)      100m (2%)       1m (0%)       100Mi (0%)        100Mi (0%)      23Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   promtail           promtail-454w6                                                       100m (2%)      200m (5%)       13m (0%)      128Mi (0%)        128Mi (0%)      87Mi (0%)
    ip-10-0-5-112.eu-central-1.compute.internal   giantswarm         vault-exporter-6c64bbc55d-zd7km                                      100m (2%)      100m (2%)       1m (0%)       50Mi (0%)         50Mi (0%)       23Mi (0%)
    ```
    
    You can install the above tool with krew or check [here](https://github.com/robscott/kube-capacity):
    ```
    kubectl krew install resource-capacity
    ```

3. Check `K8s API performance` grafana dashboard on teh installation to verify the ETCD and node pressure if correct

    ```
    » export=INSTALLATION=XXXXX
    » opsctl open -i $INSTALLATION -a grafana
    ```
    
    __Note__: If you notice the CPU and memory overloads the machine for last days, you can think on growing the master machine to next instance type.
