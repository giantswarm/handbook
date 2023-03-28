---
title: "Troubleshooting GitOps"
owner:
- https://github.com/orgs/giantswarm/teams/team-honeybadger
confidentiality: public
---

We are offering GitOps as interface for our customers, here we collect tips on how to troubleshoot problems which can occur. 

# Table of Contents
1. [Identify which kustomization owns a resource](#identify-which-kustomization-owns-a-resource)
2. [Download the Git Repository source](#Download-the-Git-Repository-source)
3. [Stop GitOps reconciliation](#Stop-GitOps-reconciliation)


## Identify which kustomization owns a resource

1) A resource contains a set of labels that identify which kustomization it belongs to. Example:

```
  labels:
    ...
    kustomize.toolkit.fluxcd.io/name: gorilla-clusters-rfjh2
    kustomize.toolkit.fluxcd.io/namespace: default
```

From the kustomization one can tell the source Git repository by looking at the spec field `sourceRef`.

2) Use the flux command line. It offers a subcommand `trace` which describes all details related to GitOps:

```
» flux trace app/alfred-app -n alfred-ns

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

__Note__: If the resource has no labels (or `flux trace` returns `object not managed by Flux`) the object is not produced as result of helm or kustomize but could still be owned by a higher resource. An example would be a *pod* which may not have the labels, but the parent *deployment* does.

## Download the Git Repository source

Giant Swarm engineers usually have no access to customer repositories, but may - in case of emergency - need to verify configuration in the source repository. For that purpose, one can download the relevant commit from the source repository using:

```sh
export SC=$(kubectl get po -n flux-system -l app=source-controller -o custom-columns=NAME:.metadata.name --no-headers)
export GITREPO_NAME=<GOT_IT_FROM_PREVIOUS_STEP>
kubectl cp -n flux-system $SC:/data/gitrepository/default/$GITREPO_NAME/ .
```

This will download a `<COMMIT_SHA>.tar.gz` file. You can extract it with `tar -xvf <COMMIT_SHA>.tar.gz` to inspect the contents of the repository.

## Stop GitOps reconciliation

In case there is a wrong configuration that breaks something in production or pages an oncall person, we might need to stop the flux kustomization while fixing the problem. To do that, one needs to [identify the kustomization the resources belong to](#identify-which-kustomization-owns-a-resource) and then stop the controller reconciliation using:

```
flux suspend kustomization -n default <KUSTOMIZATION_NAME>
```

Remember to notify the customer of this change.
