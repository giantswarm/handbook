---
title: "Troubleshooting GitOps"
owner:
- https://github.com/orgs/giantswarm/teams/team-honeybadger
confidentiality: public
---

Since we are offering GitOps as interface for our customers, here we collect to tips on how to troubleshoot the problems can occur. 

# Table of Contents
1. [Identify which kustomization owns a resource](#identify-which-kustomization-owns-a-resource)
2. [Download the Git Repository source](#Download-the-Git-Repository-source)
3. [Stop GitOps reconciliation](#Stop-GitOps-reconciliation)


## Identify which kustomization owns a resource

1) Usually the resources contain a set of labels that identify which kustomization belongs to. Example:

```
  labels:
    ...
    kustomize.toolkit.fluxcd.io/name: gorilla-clusters-rfjh2
    kustomize.toolkit.fluxcd.io/namespace: default
```

From the kustomization you can the Git Repository looking at the spec field `sourceRef`.

2) Use flux command line. It offers a subcommand `trace` that describe all details related to GitOps:

```
» flux trace app/alfred-app -n 

Object:        App/alfred-app
Namespace:     rfjh2
Status:        Managed by Flux
---
Kustomization: gorilla-clusters-rfjh2
Namespace:     default
...
---
GitRepository: workload-clusters-fleet
Namespace:     default
...
```

__Note__: If the resource has not labels (or command returns `object not managed by Flux`) the object is not produce as result of helm or kustomize but it could be a owner by a higher resource. Like a pod which does not have the labels but the parent deployment can have them.

## Download the Git Repository source

Giant Swarm engineers usually have no access to the customer repository but in case of emergency they need to verify something in the customer source repository. For that matters, they can download the repository temporaly with:

```sh
export SC=$(kubectl get po -n flux-system -l app=source-controller -o custom-columns=NAME:.metadata.name --no-headers)
export GITREPO_NAME=<GOT_IT_FROM_PREVIOUS_STEP>
kubectl cp -n flux-system $SC:/data/gitrepository/default/$GITREPO_NAME/ .
```

This will download a `<COMMIT_SHA>.tar.gz` file. You can extract it with `tar -xvf <COMMIT_SHA>.tar.gz` to inspect the contents of the repository.

## Stop GitOps reconciliation

In case there is a wrong configuration that breaks something in production or pages person oncall, we might need to stop the Flux Kustomization to fix the problem. For that matter, you can find which kustomization the resources belongs to [here](#identify-which-kustomization-owns-a-resource) and then stop the controller reconciliation using:

```
flux suspend kustomization -n default <KUSTOMIZATION_NAME>
```

Remember to notify the customer of this change.
