---
linkTitle: Generic
title: Creating a new generic repository
description: The canonical way to create a new repository that does not fit any of the more specific repository types.
weight: 10
---

These instructions will help you create a repository that does not fit any of the more specific repository types — for example one holding documentation, configuration, shell scripts, or a prototype in a language we have no template for.

If your repository will hold a Go project or an app to be distributed via the app platform, follow the [Golang]({{< relref "/docs/dev-and-releng/repository/go" >}}) or [App]({{< relref "/docs/dev-and-releng/repository/app" >}}) instructions instead. Unlike those, a generic repository does not start from a template repository. Instead you create an empty repository and let our [repository automation](https://github.com/giantswarm/github) fill in the standard files.

## Prerequisites

- the `git` CLI
- the [GitHub CLI](https://cli.github.com/) `gh`
- [`devctl`](https://github.com/giantswarm/devctl) version 6.12.0 or newer

## Step 1 - Preparation

Since you will need the repository name several times on the command line, we first create an environment variable `REPOSITORY_NAME` with the new repository name as the value.

Example:

```nohighlight
export REPOSITORY_NAME=test-repo
```

Here we assume you want to create the new repository named `test-repo`.

## Step 2 - Repo creation

In your current command line / shell session, navigate to the directory where you keep git clones.

**Note:** No need to create an empty sub folder just for the new repo, as this will happen automatically in the next step.

Now create the new **public** repository:

```nohighlight
gh repo create \
  --clone \
  --public \
  --add-readme \
  --license apache-2.0 \
  giantswarm/${REPOSITORY_NAME}
```

Note: At Giant Swarm, most of our software development is done in public under the Apache 2.0 license. You can replace the flag `--public` with `--private` to start with a private repository instead.

## Step 3 - Configure settings

Now configure the GitHub repository settings (permission, branch protection, Renovate access, etc.) with one simple command:

```nohighlight
devctl repo setup giantswarm/${REPOSITORY_NAME}
```

## Step 4 - Set up repository automation

Add the new repository to your team's list in [giantswarm/github](https://github.com/giantswarm/github/tree/main/repositories), in the file `repositories/team-<your-team>.yaml`. This establishes team ownership and keeps the repository up-to-date with our standards. Since there is no template involved, this step is what actually populates your repository — the automation adds and maintains files like `LICENSE`, `DCO`, `SECURITY.md`, `CODEOWNERS`, the GitHub workflows, and the Renovate configuration.

For a generic repository, an entry looks like this:

```yaml
- name: test-repo
  componentType: unspecified
  gen:
    flavours:
      - generic
    language: generic
    ci:
      generate: true
      releaseWorkflow: auto-release
```

- `componentType` influences what our developer portal shows for the repository. Pick the fitting one from `appcatalog`, `cli`, `configuration`, `customer`, `library`, `service`, `template`, `unspecified`.
- `flavours: [generic]` selects the [flavour](https://github.com/giantswarm/devctl/blob/main/docs/flavours.md) for repositories that don't fit any of the more specific ones.
- `language` can be set to `generic`, `go`, `node`, `python` or `kyverno-policy`. It determines the language-specific parts, e. g. which dependencies Renovate watches.
- `ci.generate: true` opts the repository into a generated CircleCI configuration.

**Note regarding automatic releases:** With `releaseWorkflow: auto-release`, every push to the `main` branch computes the next semantic version from the [conventional commits](https://www.conventionalcommits.org/) since the last tag, then tags and publishes a GitHub release — no release PR, no manual approval. This is also the default when `ci.generate` is `true`. If you don't want that, set `releaseWorkflow: legacy` to get releases driven by manually pushed `main#release#patch`-style branches instead.

Once your pull request in `giantswarm/github` is merged, the ["Align files" workflow](https://github.com/giantswarm/github/actions/workflows/align-files.yaml) writes the files into your repository. It runs on a schedule, and you can trigger it manually if you don't want to wait. See the [README](https://github.com/giantswarm/github) for more details.

## Step 5 - Final touches

- On the repository home page near `About`, click the cog icon to adjust the repository description and tags. Under "Include in the home page" de-select the Packages and Environments options.
- Add documentation to the `docs/` folder.
- Replace the `README.md` of your new repository with meaningful info about what the repository holds.
