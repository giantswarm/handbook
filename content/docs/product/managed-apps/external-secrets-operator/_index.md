---
title: External Secrets Operator
linkTitle: External Secrets Operator
description: >
  External Secrets Operator is a managed application within our platform.
  This is what you need to know
confidentiality: public
---

## What is External Secrets Operator

External secrets operator (ESO) is a kubernetes operator that reads secrets
from an external source and deliver them securely as kubernetes secrets for
your workloads to consume.

As part of our offering, we make External Secrets Operator available on all
management clusters, and also as a managed application for you to deploy on
your workload clusters.

ESO can be used either alongside, or in place of Mozilla SOPs to bind secrets
into the cluster that may otherwise have required you to commit to source
control or deploy manually to the cluster.

## Resource requirements

Onec running, ESO has a small footprint on your cluster, requiring only the
inclusion of 3 additional pods with a CPU requirement of 300m and a memory
requirement of 1.5GiB.

During the installation process, we require a little more as the CRD installer
pod needs to cache kubernetes resources as part of its deployment.

This may require an additional 1.5GiB of memory to be consumed whilst we
install and upgrade ESO. However, this usage is ephemeral and will be released
back to the cluster as soon as the install job is complete.

## Usage

To begin using ESO, it requires the inclusion of two resources to your cluster.

The first resource that needs to be created is the `SecretStore`.

The secret store binds ESO to your secret manager, whether that be AWS KMS,
Azure Key Vault, Hashicorp Vault or another of the [many supported secret
providers](https://external-secrets.io/v0.8.1/provider/aws-secrets-manager/).

The second resource that needs to be created is the `ExternalSecret`. Here, you
will bind one or many external secrets to the kubernetes secret that will be
managed by this resource.

It is possible to define multiple `SecretStores` on the cluster which works best
inside a multi-tenant environment where different teams may have different
secret providers, or only have restricted access to part of the secret provider
as may be the case when using Hashicorp Vault Enterprise.

An External Secret may bind one or many secrets to the kubernetes secret however
where this is the case, only a single SecretStore may be referenced in the
ExternalSecret. You can find more information on [binding multiple secrets
here](https://external-secrets.io/v0.8.1/guides/getallsecrets/).

## Installation

ESO can be installed as a managed app from our catalogs. There is no special or
additional configuration required to install and it can be installed directly by
creating an AppCR against the cluster using our `GitOps` approach or through
Happa.

### Example AppCR

```yaml
---
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  name: external-secrets
  namespace: abc123
spec:
  catalog: giantswarm-catalog
  kubeConfig:
    inCluster: false
  name: external-secrets
  namespace: org-example
  userConfig:
    configMap:
      name: external-secrets-userconfig-abc123
      namespace: abc123
  version: 0.4.2
```

More advanced users may wish to configure specific parts of the values
themselves and can find the application chart at
[https://github.com/giantswarm/external-secrets](https://github.com/giantswarm/external-secrets)

For more information on configuring apps within the Giant Swarm App Platform,
please follow the documentation at
[https://docs.giantswarm.io/getting-started/app-platform/app-configuration/](https://docs.giantswarm.io/getting-started/app-platform/app-configuration/)
