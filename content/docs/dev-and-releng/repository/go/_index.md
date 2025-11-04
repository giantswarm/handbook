---
linkTitle: Golang
title: Creating a new Go/Golang repository
description: The canonical way to create a new Go repository.
---

These instructions will help you create a new Go (a.k.a. Golang) project repository based on our [template](https://github.com/giantswarm/template).

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

Now create the repository, using our [template](https://github.com/giantswarm/template) to pre-fill its content. Execute this command to create the new **public** repository:

```nohighlight
gh repo create \
  --clone \
  --public \
  --template=giantswarm/template \
  giantswarm/${REPOSITORY_NAME}
```

Note: At Giant Swarm, most of our software development is done in public under the Apache 2.0 license. You can replace the flag `--public` with `--private` to start with a private repository instead.

## Step 3 - Name replacement

Let's fill in the actual repository name in a bunch of places in the new repo's content, as otherwise we would have just the placeholder `REPOSITORY_NAME` in there.

Make sure to navigate into your local clone of the repository:

```nohighlight
cd ${REPOSITORY_NAME}
```

Here is your command to run:

```nohighlight
devctl replace \
  -i 'REPOSITORY_NAME' ${REPOSITORY_NAME} \
  --ignore '.git/**' '**'
```

Commit and push these replacements:

```nohighlight
git commit -a -m "Replace placeholder by ${REPOSITORY_NAME}"
git push origin $(git rev-parse --abbrev-ref HEAD)
```

## Step 4 - Renovate setup

By default our template comes with a basic `renovate.json5` configuration. For the Go-specific configuration run the following:

```nohighlight
devctl gen renovate --language go
```

## Step 5 - Configure settings

Now configure the GitHub repository settings (permission, branch protection, Renovate access, etc.) with one simple command:

```nohighlight
devctl repo setup giantswarm/${REPOSITORY_NAME}
```

## Step 6 - Set up repository automation

To maintain team ownership and keep the repository up-to-date with our standards, you should add the new repository to your team's list in [giantswarm/github](https://github.com/giantswarm/github/tree/main/repositories). See the [README](https://github.com/giantswarm/github) for more details.

## Step 7 - Final touches

- On the repository home page near `About`, click the cog icon to adjust the repository description and tags. Under "Include in the home page" de-select the Packages and Environments options.
- Add documentation to the `docs/` folder.
- Add badges to the README top if you like. Find some suggestions in the README of your new repo.
- Replace the `README.md` of your new repository with meaningful info about the software you're offering there.
