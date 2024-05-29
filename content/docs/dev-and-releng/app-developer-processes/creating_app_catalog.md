---
title: "Creating an App Catalog"
weight: 20
classification: public
---

# App catalog

## Setting up a new app catalog

1. Choose a catalog name (`[NAME]`).
1. We always use catalogs in pairs. `giantswarm-[NAME]-catalog` is for applications and their versions
that we want to expose to customers. `giantswarm-[NAME]-test-catalog` is for development and testing
of the applications before they are moved to the production catalog. So, go to github and create new
repositories named like the 2 catalogs.
1. Enable GitHub Pages for the master branch. To do that, the repo has to be non-empty. To initialize
it from empty state, you can run `helm repo index .` to create index file for empty catalog. Commit this
file to github.
1. Grant [`Bot Catalog Editors` team](https://github.com/orgs/giantswarm/teams/bot-catalog-editors/repositories)
the `write` permission to the repository.

Catalogs don't drive their content. After creating the catalog, every application that wants to be included
in it needs to have a correct [circleci.com](https://circleci.com) pipeline (see [below](#adding-an-app-catalog-to-a-management-cluster)).
The pipeline is responsible for building the Helm chart and including it in the catalog and its index file.

## Adding an app catalog to a management cluster

Please start by reading [documentation about app catalogs and apps](https://github.com/giantswarm/giantswarm/blob/main/archive/archive-roadmap/MANAGED-SERVICES-CATALOG.MD).

All application catalogs are defined in the management cluster using the [Catalog](https://docs.giantswarm.io/vintage/use-the-api/management-api/crd/catalogs.application.giantswarm.io/) CRD. To deploy the Catalog CRs,
the following process is used:

- App catalog configuration file needs to be added to the [`giantswarm/installations`](https://github.com/giantswarm/installations)
  repository. Please see [configuration structure description](https://github.com/giantswarm/giantswarm/blob/main/archive/archive-roadmap/MANAGED-SERVICES-CATALOG.MD) and a
  [CRD spec](https://github.com/giantswarm/giantswarm/blob/main/archive/archive-roadmap/MANAGED-SERVICES-CATALOG.MD). Example entry for `giantswarm-incubator-test` app catalog
  for gauss installation can be checked here: [`gauss/appcatalog/giantswarm-incubator-test-appcatalog-values.yaml`](https://github.com/giantswarm/installations/blob/master/gauss/appcatalog/giantswarm-incubator-test-appcatalog-values.yaml).
  Another example can look like this:

  ```yaml
  appCatalog:
  name: "giantswarm-playground"
  title: "Giant Swarm Playground"
  catalogType: "test"
  catalogVisibility: "public"
  description: "This catalog holds applications that are not covered by any support plan. Still, we try to make them install and run on Giant Swarm smoothly!"
  logoURL: "/images/repo_icons/incubator.png"
  storage:
    URL: "https://giantswarm.github.io/giantswarm-playground-catalog/"
  ```

- commit the app catalog definition (to installations repo feature branch for testing, and eventually merge to master).
- `opsctl` uses Helm to turn these config files into Catalog CRs on management clusters. Run
  `opsctl ensure catalogs -i [INSTALLATION_NAME]` to execute this process.
  After that your app catalog should be visible and ready to use. To `ensure` all installations at once, run
  `opsctl ensure catalogs -a` (*). These commands
  will delete any orphaned app catalogs as well. Effectively this command
  is about ensuring the desired state of the appcatalog resources as specified in the installations repo.

  *Notes:*

  - `ensure` command can take a few minutes to complete per installation.
  - Some installations require specific VPN connection to be reachable, so `-a`
  might not work for some installations that are not currently reachable for you over the VPN.

The configuration structure supports defining default app catalogs (to be installed across all management clusters), as well as _installation specific_ ones. You choose where to install by either including the file in top-level or in an
installation specific config directory like `ghost/appcatalog`.

As mentioned, app catalogs (`Catalog` CR and optionally any associated `ConfigMap` and/or `Secret`) are managed as Helm
releases using [appcatalog Helm chart](https://github.com/giantswarm/appcatalog/tree/master/helm/appcatalog). App
catalog definitions for management clusters are stored in a form of a Helm values yaml file, overriding and/or extending appcatalog Helm chart default values file settings. As an example please see [giantswarm app catalog definition](https://github.com/giantswarm/installations/blob/master/gauss/appcatalog/giantswarm-appcatalog-values.yaml) for `gauss` installation.
