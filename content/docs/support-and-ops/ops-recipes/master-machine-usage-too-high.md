---
title: "Master Machine Usage Too High"
owner:
- https://github.com/orgs/giantswarm/teams/team-phoenix
confidentiality: public
---

What to do once we are paged byWorkload Cluster master machine CPU usage is too high. 

# Table of Contents
1. [Identify the culprit](#identify-the-culprit)
2. [Download the Git Repository source](#Download-the-Git-Repository-source)
3. [Stop GitOps reconciliation](#Stop-GitOps-reconciliation)


## Identify the culprit

1) Check the master conditions to see if kubelet has reported any problem

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

2) Check `K8s API performance` grafana dashboard on teh installation to verify the ETCD and node pressure if correct

```
» export=INSTALLATION=XXXXX
» opsctl open -i $INSTALLATION -a grafana
```

__Note__: If you notice the CPU and memory overloads the machine for last days, you can think on growing the master machine to next instance type.

