---
title: "How to check for changes in k8s upgrades"
owner:
- https://github.com/orgs/giantswarm/teams/team-teddyfriends
confidentiality: public
---

### Purpose

When upgrading Giant Swarm releases you will notice that the Kubernetes version is also being upgraded. As part of the upgrade process, it should be a habit to check for the newest changes upstream. This ensures that the diffs, deprecations, and new features from an upstream Kubernetes perspective are known to the customer. 

There is not a right or wrong way to go about this process because there is no single tool that simply gives all of the answers. However, the following tools combine to give a nice overview of the important changes. Let us know if you have thoughts or recommended tools as well!  

### Tools 

1. [Pluto](https://github.com/FairwindsOps/pluto)
This one is a tool that will show you deprecated APIs in your code, helm charts, and resources.

2. [Sysdig Blog](https://sysdig.com/blog/kubernetes-1-27-whats-new/)
Sysdig is writing a good summary on the major changes in K8s that can be used as reference.

3. [k8s.io Release Notes](https://relnotes.k8s.io/)
All kubernetes release notes.

4. [Giant Swarm Releases](https://github.com/giantswarm/releases/) 
Our own release page and we try to give you a better overview on the important changes. 
*Tip: Once we deprecate a release, it is moved to "archived", so you might need to dig in there to find our past versions where the K8s version is changing.*

### Giant Swarm 

When upgrading to a new Giant Swarm version, another idea to see the changes would be to use the tool [yamldiff](https://www.yamldiff.com/). Using Giant Swarm versions as examples: Let's say the current version is `17.4.4` and the target version is `18.3.0`. To use yamldiff you would input the YAML files from both current release on the left and target release on the right to learn about the changed components. 

- [20.0.0 yaml](https://raw.githubusercontent.com/giantswarm/releases/master/aws/v20.0.0/release.yaml)
- [18.3.0 yaml](https://raw.githubusercontent.com/giantswarm/releases/master/aws/archived/v18.3.0/release.yaml)
