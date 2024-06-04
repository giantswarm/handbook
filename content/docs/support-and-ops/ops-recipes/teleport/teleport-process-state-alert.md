---
title: "Teleport Process State Is Not Okay"
owner:
- https://github.com/orgs/giantswarm/teams/team-bigmac
classification: public
---

This alert indicates that the state of the Teleport cluster is not in a healthy state (state: 0).

State of the Teleport process: 0 - ok, 1 - recovering, 2 - degraded, 3 - starting.

## Overview

When the Teleport process state alert is triggered, it's essential to check the health of the Teleport cluster. This document outlines the steps to verify the status of Teleport auth and proxy pods within the cluster and troubleshoot potential issues.

## Prerequisites

Ensure you have access to the GiantSwarm GitHub organization and are a member of the `team-bigmac` team, as this documentation refers to resources and steps specific to the GiantSwarm infrastructure.

## Configuring AWS CLI Profile for Teleport Cluster

Before proceeding with the troubleshooting steps, set up the AWS CLI profile for the Teleport cluster. This will facilitate easier access to the cluster via AWS EKS. Add the following snippet to your AWS CLI configuration file (usually found at `~/.aws/config`):

```ini
[profile teleport]
region = eu-central-1
source_profile = root
role_arn = arn:aws:iam::082357646246:role/GiantSwarmAdmin
```

This profile configuration allows you to use the AWS CLI to interact with the AWS resources under the specified role and region settings.

## Login to Teleport Production Cluster

First, attempt to login to the Teleport production cluster using the Teleport CLI (`tsh`). This step verifies whether the Teleport cluster is accessible.

```bash
$ tsh login --auth giantswarm --proxy 'teleport.giantswarm.io:443'
$ tsh kube login teleport.giantswarm.io
```

If the `tsh` login process fails, fallback to using EKS to login:

```bash
aws eks update-kubeconfig --profile teleport --region eu-central-1 --name teleport-prod --alias teleport-prod
```

## Verify Teleport Components

Ensure that the Teleport auth and proxy pods are running within the Kubernetes cluster. These commands help verify the operational status of these components:

### Check Teleport Auth Pods

```bash
$ kubectl get pods -l app.kubernetes.io/component=auth -n teleport
```

### Check Teleport Proxy Pods

```bash
$ kubectl get pods -l app.kubernetes.io/component=proxy -n teleport
```

After confirming the pods are running, examine the logs for both auth and proxy components for any errors that could indicate the root cause of the issue:

```bash
$ kubectl logs -l app.kubernetes.io/component=auth -n teleport
$ kubectl logs -l app.kubernetes.io/component=proxy -n teleport
```
