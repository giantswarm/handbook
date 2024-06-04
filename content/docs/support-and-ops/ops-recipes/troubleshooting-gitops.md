---
title: "Troubleshooting GitOps"
owner:
- https://github.com/orgs/giantswarm/teams/team-honeybadger
classification: public
---

We are offering GitOps as interface for our customers, here we collect tips on how to troubleshoot problems which can occur.

# Table of Contents
1. [Identify which kustomization owns a resource](#identify-which-kustomization-owns-a-resource)
2. [Download the Git Repository source](#download-the-git-repository-source)
3. [Stop GitOps reconciliation](#stop-gitops-reconciliation)


## Identify which kustomization owns a resource

1. resource contains a set of labels that identify which kustomization it belongs to. Example:

    ```
      labels:
        ...
        kustomize.toolkit.fluxcd.io/name: gorilla-clusters-rfjh2
        kustomize.toolkit.fluxcd.io/namespace: default
    ```

    From the kustomization one can tell the source Git repository by looking at the spec field `sourceRef`.

2. Use the flux command line. It offers a subcommand `trace` which describes all details related to GitOps:

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

## Customer Communication

After stopping reconcilation, please notify the customer of the change via slack support channel where the customer will be able to review and make the necessary changes the following business day.

In the case of an issue that cannot be fixed by stopping reconcilation and manually doing, a silence may be required. In this case, please notify via slack support channel a) the situation that we are alerted for and that we cannot help due to customer ownership and no access b) we will silence the alert until the next buisness day.

In case of urgent situations or when pausing reconcilation does not fix the issue and the customer needs to be notified before the next business day, please reference the customer specific escalation matrix found in intranet. This will notify the customer of the situation and that Giant Swarm has no way to fix the problem and that Giant Swarm will silence the alert because of this. The `urgent` remains available for additional help within the Giant Swarm scope but can only be useful after the customer takes care of their fix.
