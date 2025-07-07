---
title: "Checking for Deprecated Kubernetes APIs with Pluto"
owner:
- https://github.com/orgs/giantswarm/teams/team-planeteers
component:
  - cluster
description: "How to use Pluto to identify deprecated Kubernetes APIs in your manifests and Helm charts."
classification: public
---

## Overview

[`pluto`](https://github.com/FairwindsOps/pluto) is a tool developed by Fairwinds that helps identify deprecated Kubernetes APIs in your manifests and Helm charts. Keeping your Kubernetes resources up to date with the latest API versions is crucial to ensure smooth upgrades and compatibility with future Kubernetes releases.

## Prerequisites

- **Pluto Installation**: [Install `pluto`](https://pluto.docs.fairwinds.com/installation/) on your local machine.

### Installing Pluto

You can install `pluto` via Homebrew, downloading a binary, or using a container:

#### Homebrew (macOS)

```bash
brew install FairwindsOps/tap/pluto
```

#### Binary Download

Download the latest binary from the [releases page](https://github.com/FairwindsOps/pluto/releases) and place it in your PATH.

#### Docker

You can run `pluto` using a Docker container:

```bash
docker run --rm -v $(pwd):/work fairwinds/pluto:latest detect-files /work
```

## Usage

### Checking Kubernetes Manifests

To check Kubernetes manifests for deprecated APIs:

1. **Navigate to the directory** containing your Kubernetes YAML files.
2. **Run Pluto**:

   ```sh
   pluto detect-files -d ./path/to/manifests
   ```

   This command will scan all the YAML files in the specified directory and report any deprecated API versions.

### Checking Helm Charts

To check Helm charts for deprecated APIs:

1. **Navigate to the directory** containing your Helm chart.
2. **Run Pluto**:

   ```sh
   helm template test ./helm/<HELM_CHART_NAME> | pluto detect-files
   ```

   This command will render the Helm template and check the resulting manifests for deprecated APIs.

### Checking Live Kubernetes Cluster

To check the currently deployed resources in a Kubernetes cluster:

1. **Ensure kubectl is configured** to access the desired cluster.
2. **Run Pluto**:

   ```sh
   pluto detect-helm -owide
   ```

   This will scan all Helm releases in the cluster for deprecated APIs.

### Checking Specific API Versions

You can specify which Kubernetes version to check against. For example, to check for deprecations against Kubernetes 1.25:

```sh
pluto detect-files -d ./path/to/manifests --target-versions=k8s=1.25.0
```

## Interpreting Results

`pluto` will output a list of resources with deprecated API versions, including the file path, line number, and suggested API version to migrate to. Here’s an example output:

```text
+----------------------+-----------------------+------------------+-------------------+
| KIND                 | NAME                  | DEPRECATED API   | REPLACEMENT API   |
+----------------------+-----------------------+------------------+-------------------+
| Deployment           | example-deployment    | apps/v1beta1     | apps/v1           |
| Ingress              | example-ingress       | extensions/v1beta1 | networking.k8s.io/v1 |
+----------------------+-----------------------+------------------+-------------------+
```
