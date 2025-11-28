---
title: "How to add and maintain App in an App Catalog"
weight: 30
description: >
  How to create, manage and release an App into an App Catalog
classification: public
---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Intro](#intro)
- [The workflow process](#the-workflow-process)
  - [1. Creating repository structure](#1-creating-repository-structure)
    - [1.1. Create and configure a repo for the App](#11-create-and-configure-a-repo-for-the-app)
  - [2. Providing chart sources](#2-providing-chart-sources)
    - [2.1. Getting the sources from upstream](#21-getting-the-sources-from-upstream)
    - [2.2. Writing a chart from scratch](#22-writing-a-chart-from-scratch)
  - [3. Ensuring quality of the chart](#3-ensuring-quality-of-the-chart)
    - [3.1. Providing all the necessary data and metadata in `Chart.yaml`](#31-providing-all-the-necessary-data-and-metadata-in-chartyaml)
    - [3.2. Retagging and copying images to our registries](#32-retagging-and-copying-images-to-our-registries)
    - [3.3. Adjust chart for custom image registries](#33-adjust-chart-for-custom-image-registries)
    - [3.4. Providing validation schema for `values.yaml`](#34-providing-validation-schema-for-valuesyaml)
    - [3.5. The quality bars checklist](#35-the-quality-bars-checklist)
  - [4. Making the chart available in an app catalog](#4-making-the-chart-available-in-an-app-catalog)
  - [5. Building, validating and testing the chart](#5-building-validating-and-testing-the-chart)
  - [6. Add your repository to `giantswarm/github` and "Changes and Releases"](#6-add-your-repository-to-giantswarmgithub-and-changes-and-releases)
  - [7. Releasing the App in Giantswarm Catalog](#7-releasing-the-app-in-giantswarm-catalog)
- [Related documentation](#related-documentation)

## Intro

This document is meant to be a comprehensive guide and description of the process we use to maintain and release managed apps.
The idea is that you should use this process by default and it fits 90% of use cases.
For the other 10%, common sense applies, as for the first 90% as well :)

In the App Platform, Apps are defined as Helm chart packages. App Catalogs are stored as Helm repositories. Packaging and pushing Apps into an App Catalog is automated using CircleCI and architect orb's [push-to-app-catalog](https://github.com/giantswarm/architect-orb/blob/master/docs/job/push-to-app-catalog.md) job.

For an overview of the App Platform, Apps, and App Catalogs, please read [The Giant Swarm App Platform](https://docs.giantswarm.io/tutorials/fleet-management/app-platform)

## The workflow process

Our apps are currently based on Helm charts only. Here's how we work on an app,
from the very beginning to making a release.

### 1. Creating repository structure

This part of work involves following steps:

- creating and setting up a new repository for an application
  - please fork the <https://github.com/giantswarm/template-app>
- now either:
  - getting sources from an upstream project, making required changes and maintaining it
  - writing chart from scratch

Check below for more details about the bullets above.

#### 1.1. Create and configure a repo for the App

{{% alert title="TL;DR" color="warning" %}}
The `-app` suffix should be in the repository name. Everywhere else, omit `-app`.
{{% /alert %}}

Use the following template repo to generate the basic skeleton for your app's repo: <https://github.com/giantswarm/template-app>.

__Note__: It is encouraged to use [devctl](https://handbook.giantswarm.io/docs/dev-and-releng/repository/app/) instead to avoid manual mistakes.

Once created:

1. Go to <https://github.com/giantswarm/APP-NAME-app/settings> and make sure `Allow merge commits` box is unchecked and `Automatically delete head branches` box is checked.
2. Go to <https://github.com/giantswarm/APP-NAME-app/settings/access> and add
   `giantswarm/bots` with `Write` access and `giantswarm/employees` with
   `Admin` access.

Note: By convention, we name app repos `[APP-NAME]-app`. [Adding the topic](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/classifying-your-repository-with-topics#adding-topics-to-your-repository) `app` to the GitHub repository is also useful. This helps the user distinguish the type of repo.

However, it is no longer required nor advisable to name your app and helm chart (step 2 & 3 below) with the `-app` suffix.

{{% alert title="Attention" color="warning" %}}
Omitting the `-app` suffix for default apps installed as part of a release require `cluster-operator` `>= v3.5.1` on AWS or `>= 0.23.21` on Azure and KVM.

```text
AWS >= 13.1.0
Azure >= 14.0.2
KVM >= 13.1.0
```

{{% /alert %}}

So for `myexample` app, the app's name is `myexample` and the repo is `https://github.com/giantswarm/myexample-app`

If you need a Go project skeleton, start with this template instead: <https://github.com/giantswarm/template>.

### 2. Providing chart sources

#### 2.1. Getting the sources from upstream

There are two main ways to get the sources from upstream to synchrnoize changes while keeping our local changes:

- [Using the git-subtree method]({{< relref "/docs/product/managed-apps/dev-experience/git-subtree.md" >}}).
- [Using vendir to sync paths](https://intranet.giantswarm.io/docs/dev-and-releng/app-developer-processes/maintain-app-with-vendir/).

#### 2.2. Writing a chart from scratch

This includes a rare situation when there's no upstream chart for the app we want. So far, it didn't
actually happen.

### 3. Ensuring quality of the chart

When we provide a chart, we want to be sure that some best practices are met to avoid problems
we have already seen in the past. The list of these practices is below.

#### 3.1. Providing all the necessary data and metadata in `Chart.yaml`

We extensively use `Chart.yaml` properties to provide information about the chart to our platform
and thus our users. Please make sure to check [this sample `Chart.yaml`](https://intranet.giantswarm.io/docs/product/architecture-specs-adrs/specs/managed-apps/2020-05-05-app-versions-representation/#supported-chartyaml-file-format)
for an example of what we expect to be provided in the `Chart.yaml`. Please note, that if you're using
`abs` (see below) to build your chart, [our annotations](https://intranet.giantswarm.io/docs/product/architecture-specs-adrs/specs/managed-apps/2020-05-05-app-versions-representation/#references-to-the-metadata-file-using-annotations-field-in-chartyaml)
will be automatically set for you.

If you fail to set the supported properties, the generated metadata won't contain information
that can help users deploy and configure the app.

For basic properties listen in `Chart.yaml`, remember to:

- Ensure `Chart.yaml` has all required fields, including `appVersion` which is usually optional. See: <https://helm.sh/docs/topics/charts/>.
- Ensure `Chart.yaml` has all fields needed so the app displays nicely in [Happa]({{< relref "/docs/dev-and-releng/app-developer-processes/apps_in_happa.md" >}}).
- If your templates contain empty values (i.e not defined with defaults in `values.yaml`), you can provide multiple value files for validation by creating yaml files (`*-values.yaml`) inside `helm/[APP-NAME]/ci`. For an example, see the pull request [#42](https://github.com/giantswarm/ignition-operator/pull/42) for `ignition-operator`.

#### 3.2. Retagging and copying images to our registries

To avoid problems when upstream registries are down or when our apps are deployed to China,
we use our own image registries and you need to copy any upstream images used to our repos.
To do that, we have the [retagger tool](https://github.com/giantswarm/retagger). Add your images
to the config file in its repo, push the changes and the images will be synchronized for you.

More information about our registries can be found below:

- ({{< relref "/docs/product/architecture-specs-adrs/specs/registry-mirror.md" >}})
- (https://intranet.giantswarm.io/docs/dev-and-releng/container-registry/)

#### 3.3. Adjust chart for custom image registries

Because images are held in other registries than upstream, we have to account for that in the
`values.yaml` configuration file. It is important to keep this configuration format, because the
`registry` part of it is set automatically to the best registry depending on installation's location
(Aliyun in China, Quay elsewhere).

So, your `values.yaml` should have the following top-level section:

```yaml
image:
    registry: quay.io
    repository: giantswarm/my-app
    tag: 0.1.1
```

You need to use these values in the chart to configure images for Deployments and such.

#### 3.4. Providing validation schema for `values.yaml`

We provide a YAML schema for validating `values.yaml` file that is provided at installation time
by a user. That way we can prevent the user from a wide range of typos and misconfiguration errors.

Our detailed documentation about generating the schema is available [on the intranet](https://intranet.giantswarm.io/docs/dev-and-releng/app-developer-processes/helm-values-schema/)

#### 3.5. The quality bars checklist

For charts we support for our customers, we have additional "quality bar" checklists. Please note,
that currently they need a revamp and you should them as suggestions, not hard requirements. Still,
please run [the checklists](https://intranet.giantswarm.io/docs/dev-and-releng/app-developer-processes/application-quality-bars/)
before you publish a chart.

### 4. Making the chart available in an app catalog

More detailed information about [how to push app to app-catalog]({{< relref "/docs/dev-and-releng/app-developer-processes/adding_app_to_appcatalog.md" >}}) is available on the intranet.

The very minimal circle CI configuration file that does the job using `abs` (see below)
looks like this:

```yaml
version: 2.1
orbs:
  architect: giantswarm/architect@2.7.0

workflows:
  package-and-push-chart-on-tag:
    jobs:
      - architect/push-to-app-catalog:
          context: "architect"
          executor: "app-build-suite"
          name: "package and push loki chart"
          app_catalog: "giantswarm-catalog"
          app_catalog_test: "giantswarm-test-catalog"
          chart: "YOUR_CHART"
          # Trigger job on git tag.
          filters:
            tags:
              only: /^v.*/
```

Personalize the README and CircleCI config with your app's name. For enabling CircleCI builds, check the [CircleCI Intranet page](https://intranet.giantswarm.io/docs/dev-and-releng/ci/circle-ci/).

Find the latest `ARCHITECT_ORB_VERSION` here: [https://circleci.com/orbs/registry/orb/giantswarm/architect](https://circleci.com/orbs/registry/orb/giantswarm/architect), then update the CircleCi config with it.

Also, adjust `push-to-app-catalog` jobs to your needs:

- Replace `chart` parameter to reflect the chart name. For `myexample` it has to be `myexample`.
- If adding App to a different App Catalog, change target `app_catalog` and `app_catalog_test`

If you want automatic metadata generation, set `executor: "app-build-suite"` (see <#building-validating-and-testing-the-chart>) in the `push-to-app-catalog` CircleCI configuration ([`architect-orb docs`](https://github.com/giantswarm/architect-orb/blob/master/docs/job/push-to-app-catalog.md#executor-optional-either-architect-or-app-build-suite-defaultarchitect)). This packages your new app with [`app-build-suite`](https://github.com/giantswarm/app-build-suite), enabling metadata integration and packaging ([Spec and more information about metadata](https://intranet.giantswarm.io/docs/product/architecture-specs-adrs/specs/managed-apps/2020-05-05-app-versions-representation/)).
You'll need to modify the `main.yaml` in the `.abs/` directory to match your desired `app-build-suite` configuration options.
Rename `helm/APP-NAME` directory with your app's name, then add your Helm chart to this directory.

**With the default CircleCI project setup from the template-app, commits to branches will trigger the build. If successful,
a chart package will be pushed to [giantswarm-playground-test-catalog](https://github.com/giantswarm/giantswarm-playground-test-catalog).**

Notes:

- Test Catalogs are not exposed to customers.
- Our API does some caching - it takes a few minutes for new releases to show up in Happa

### 5. Building, validating and testing the chart

In order to make the application build process more streamlined and repeatable across developer's
desktop and CI/CD systems, we have created [app-build-suite](https://github.com/giantswarm/app-build-suite) (a.k.a. `abs`).

To get started with `abs`, please check the [quick start](https://github.com/giantswarm/app-build-suite#quick-start)
section of the docs or check the full [tutorial](https://github.com/giantswarm/app-build-suite/blob/master/docs/tutorial.md).

Currently, `abs` also handles [application testing](https://github.com/giantswarm/app-build-suite#test-pipelines),
but we intend to change that in the future. Again, please check the [tutorial](https://github.com/giantswarm/app-build-suite/blob/master/docs/tutorial.md)
for more details.

### 6. Add your repository to `giantswarm/github` and "Changes and Releases"

Open a PR in [giantswarm/github](https://github.com/giantswarm/github) to add your repository to `repositories/meta.yaml`. Ensure `flavour` is set to `app` (the required value for repositories which contain just a Helm chart). This ensures certain files are kept in sync across our repos. Once merged, `architectbot` will open a PR in your repository to add the necessary files.

Open a PR to add your app to [giantswarm/docs](https://github.com/giantswarm/docs/blob/master/scripts/aggregate-changelogs/config.yaml). When you make a release, it automatically updates "[Changes and Releases](https://docs.giantswarm.io/changes/)" with your app's changes in our external docs.

### 7. Releasing the App in Giantswarm Catalog

In order to include your App in the Giantswarm catalog, you need to create a release.

Please follow [How to release a project]({{< relref "/docs/dev-and-releng/releases/how-to-release-a-project" >}}) in order to do that.

## Related documentation

- A lot of more detailed processes are documented already [on the handbook]({{< relref "/docs/dev-and-releng/app-developer-processes/_index.md" >}})
- [Adding Readmes and Icons to Apps in Happa]({{< relref "/docs/dev-and-releng/app-developer-processes/apps_in_happa.md" >}}) describes the process of adding a Readme and an app icon to your new app
- [Quality bars for Managed Apps](https://intranet.giantswarm.io/docs/dev-and-releng/app-developer-processes/application-quality-bars/) contain hints how to make your app fit for being a managed app
- [Kubernetes Annotations and Labels in `giantswarm/fmt`](https://github.com/giantswarm/fmt/blob/master/kubernetes/annotations_and_labels.md) contain some commonly used annotations and labels in kubernetes resources
- [App Release Checklist](https://intranet.giantswarm.io/docs/dev-and-releng/app-developer-processes/app-release-checklist/) contains hints and guidelines on what to do when releasing any Managed App
- [Creating container registries for retagger](https://intranet.giantswarm.io/docs/dev-and-releng/container-registry/)
- [CircleCI Intranet page](https://intranet.giantswarm.io/docs/dev-and-releng/ci/circle-ci/)
