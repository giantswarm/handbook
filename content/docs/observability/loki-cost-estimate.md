---
title: "How to evaluate Loki's cost on an installation"
linkTitle: Loki Cost Estimate
---

This document's purpose is to help one evaluate the cost of a loki setup running on an installation.

## Table of contents

* [Loki Cost Estimate dashboard](#loki-cost-estimate-dashboard)
* [Using Cost Explorer (AWS only)](#using-cost-explorer-aws-only)

## Loki Cost Estimate dashboard

Open grafana on the installation you're interested in and go to the dashboard section. There, open the `Loki Cost Estimate` dashboard and select the `cluster` and `tenant` or leave both to the default `all` value.

A lot of guidelines to evaluate Loki's cost are given in the `Explanation` field of the dashboard so this section will not go into every details but will only mention the important things to consider.

Loki's cost is coming from 3 different sources :

* The CPU & Memory consumption from all Loki's and Promtail's pods.
* The object storage cost.
* The data sent to the MC Loki by the promtail pods on WCs.

The dashboard gives access to graphs related to those sources :

![loki-cost-dashboard-screenshot](../images/loki-cost-dashboard.png)

Basing on the total storage space used by Loki to store the logs as well as the base cost of the object storage service from your cloud-provider, one can roughly estimate the cost of storage for the logging-infrastructure.

Similar applies to the data sent to Loki by the promtail pods. If one knows the price for network traffic from the cloud-provider, one can estimate the corresponding cost from the `Total of bytes transmitted over the network` field of the dashboard.

Concerning the CPU and memory this gets a little more tricky but at least you can measure the increase in resources counsumption in your clusters.

## Using Cost Explorer (AWS only)

Alongside the dashboard mentioned above, if your logging-infrastructure is running on an AWS installation, you can open the AWS console and go to the Cost Explorer service. There, you can select the time period you wish to evaluate as well as the tag `giantswarm.io/installation` with the value corresponding to your installation's name :

![cost-explorer-tag](../images/cost-explorer-tag.png)

In addition to those parameters, you can also add more precision to the graph by grouping the result by services :

![cost-explorer-service](../images/cost-explorer-group-by.png)

By selecting those parameters, you will get a similar looking graph :

![cost-explorer](../images/aws-cost-explorer.png)

You can then compare the general cost of your installation between a time period where the logging-infrastructure was not enabled and another one where it was.
