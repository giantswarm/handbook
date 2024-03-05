---
title: Our internal developer portal
linkTitle: Developer portal
description: About our internal developer portal at devportal.giantswarm.io
confidentiality: public
weight: 10
---

Since July 2023 we run a developer portal at [devportal.giantswarm.io](https://devportal.giantswarm.io/). Here you should find answers to all your questions, or at least a contact point to direct them to.

## Contact

[Team Honeybadger](https://intranet.giantswarm.io/docs/organizational-structure/teams/honeybadger/) is responsible for running the portal.

We also have a **developer portal working group** (Slack: [#wg-dev-portal](https://gigantic.slack.com/archives/C055VLMTPFE)), which functions as a sounding board for high-level decisions regarding the direction of the portal.

## Usage

To access the developer portal, go to [devportal.giantswarm.io](https://devportal.giantswarm.io/) and sign in using your GitHub user account.

### Who has access

In short: every Giant Swarm staff member should have access.

In more detail: every GitHub user account that is a member in one of the [GitHub teams](https://github.com/orgs/giantswarm/teams) in the `giantswarm` Github organization should have access. This normally includes every person working with Giant Swarm.

## Content and functions

As of August 2023, the portal consists mainly of the catalog, which offers a quick access to information about the software we produce, and a bit more.

### Catalog

The catalog offers a list of so-called _entities_, the most important ones being the _components_, but also _users_ (which represent people) and _groups_ (which represent teams).

#### Catalog list view

The catalog overview by defaults shows only your **owned** components. These are the components owned by one of the teams you are a member of. In the left-hand sidebar you can remove that filter by selecting **all** components. In case you want to access the same components frequently, you can also add a **star** and access your starred components easily via a special filter.

The **filter** input field in the top of the list also allows you to combine freeform search terms, to reduce the list content in addition to the filter facets on the left-hand side.

#### Component details

Components have a 1:1 relationship to the GitHub repositories in which their source code is maintained. However, not all our GitHub repositories are represented in the catalog. We only import repositories that are assigned to a team via the repository metadata maintained in [giantswarm/github](https://github.com/giantswarm/github/tree/main/repositories). There is automation in place to keep the catalog in sync with that metadata.

The catalog presents a few component details that might need explanation:

- **Type**: as of August 2023, all components carry the type `service`, which is due to the fact that this is a required field and we haven't decided how to use it yet. In the future we may differentiate verious component types, e. g. apps, libraries, template repos etc. ([Related issue](https://github.com/giantswarm/giantswarm/issues/27739)).

- **Owner**: the team owning the component, taken from the giantswarm/github repository metadata as mentioned above.

- **Lifecycle**: either `production` or `deprecated`. Imported from giantswarm/github repository metadata.
  - `deprecated` means that we aim to phase this component out. Our future architecture decisions should not rely on this component. We avoid adding functionality.
  - `production` is software that we actively develop.

- **Description**: The description of the Github repository.

- **Tags**: Each component can have any number of free-form tags. When importing data into the catalog, we create the following:
  - `private`: highlights the fact that the Github repo for this component is not publicly accessible. This means, if this tag is absent, the repo is public.
  - `flavor:*`: These are the flavour values from giantswarm/github repository metadata (using the American English spelling).
  - `language:*`: Likewise, exposes the language value from giantswarm/github repository metadata.

- **System**: Components and other entities can be assigned to a System. As of August 2023, we have a first system `app-platform` in the catalog.

  To add a system, you can append it to [`catalog/systems.yaml`](https://github.com/giantswarm/github/blob/main/catalog/systems.yaml). To assign a component to a system, make sure to add the `system` property to the according repository, like in [this example PR](https://github.com/giantswarm/github/pull/1044/files#diff-eacb07a081b75cd32aab835640285ad1413773e06e49af1470c8d4934385f19cR11).

- **Dependencies**: For Go components in our catalog, we display dependency relations. Note that each Go project usually has a lot more dependencies than shown in the portal. If a dependency is missing, it is either not managed by us (module name starting with `github.com/giantswarm/`), or it is not covered in the catalog (e. g. because it is not mentioned in [giantswarm/github](https://github.com/giantswarm/github/tree/main/repositories)) or it has the Github _Dependency Graph_ feature not activated.

#### Techdocs

For each component in the catalog, the portal also provides access to its documentation, as long as this documentation is included in the same repository that holds the component source code. Backstage calls this _Techdocs_. To be more specific, we include all Markdown files which are present in the repository's root folder as well as in the `/docs` folder (and any subfolders), if it exists.

Techdocs always represent the latest state of the repository's default branch.

#### Integrations

In the context of a component, the portal offers additional information from different sources, usually using Backstage plugins:

- **GitHub pull requests**: An overview of the pull requests in the according repository. Click the PR ID on the left-hand side to access the pull request in the GitHub web UI.

- **GitHub actions**: Latest GitHub action runs and their result.

- **CircleCI**: Latest CircleCI job runs and their result.

### Search

Apart from the catalog filter functions, the portal also offers a general search function that covers all content. You find it in the main menu on the left-hand side. Give it a try! It's quite fuzzy and might help you in case the catalog filter functions don't give you the result you are looking for.

While the search result first appears in a modal, the result can also be accessed on a full page that offers more functions. Go check it out! [Here is an example](https://devportal.giantswarm.io/search?query=hello-world).

### Settings

In the [settings](https://devportal.giantswarm.io/settings) section you can adjust some personal preferences, like picking the dark or light theme, or pinning the left sidebar (which is nice if you have a wide screen).

One particular important settings page is the one named [feature flags](https://devportal.giantswarm.io/settings/feature-flags). Here you can enable some features we consider experimental or very niche.

### Templates

Backstage offer a function called **Templates** which we don't make use of, yet. The idea is to create things (like, for example, a new software component) with a lot of guidance. However the term appears in the search result filters, so we wanted to explain it here.

## Why

Ther are mainly two reasons we decided to run our own developer portal:

- Large organizations tend to introduce developer portals as a one-stop shop for their developers. So the product vision of a developer platform naturally includes using a developer portal as a starting point for some use cases, like getting an overview of available services, accessing high level service metrics, or creating a new service to be deployed on the platform. And it's a lot easier to reason about how to integrate with a developer portal when we are actually using one ourselves.

- The motivations for introducing developer portals in our customer's organizations (e. g. higher developer productivity, shorter onboarding) also apply to Giant Swarm in general.

Whether we actually reach the second goal depends on a lot of factors. As an engineer at Giant Swarm, you are invited to tell us (the working group, see [contact](#contact) above) how we are doing and whether you feel the portal is making your job easier or harder, and what we could do to improve it.

## Software and deployment

The developer portal is based on [Backstage](https://backstage.io/), an open source software initially developed by Spotify. Backstage was accepted to the Cloud Native Computing Foundation on September 8, 2020 and is currently (as of August 2023) at the Incubating project maturity level.

The main repository for our deployment is [giantswarm/backstage](https://github.com/giantswarm/backstage).

### Staying informed about changes

To stay tuned about user-facing changes in the portal, you can subscribe to the releases of these repositories. We make an effort to explain the changes as good as we can.

- [giantswarm/backstage](https://github.com/giantswarm/backstage/releases) releases for the general user interface.
- [giantswarm/backstage-catalog-importer](https://github.com/giantswarm/backstage-catalog-importer/releases) releases for details on the catalog data.

Our catalog content is maintained in the [giantswarm/github](https://github.com/giantswarm/github) repository in the [catalog/](https://github.com/giantswarm/github/tree/main/catalog) folder. You can track [content changes](https://github.com/giantswarm/github/commits/main/catalog) there.
