---
linkTitle: App
title: Creating a new app repository
description: The canonical way to create a repository for an app to be
  distributed and deployed via the Giant Swarm app platform.
classification: public
---
These instructions will help you create a new app repository based on our [template-app](https://github.com/giantswarm/template-app).

## Prerequisites

- `devctl` latest version

## Bootstrap Command (devctl app bootstrap)

Creates a new app repository from [`template-app`](https://github.com/giantswarm/template-app) with the following features:

- new repository based on the `template-app` template
- sync methods configured (vendir or kustomize)
- set up patch methods (script or kustomize)
- fully configured CI/CD 
- pull request with the initial setup in `giantswarm/github`

### Example:

```
devctl app bootstrap \
  --name my-app \
  --patch-method script \
  --sync-method vendir \
  --team myteam \
  --upstream-chart helm/upstream \
  --upstream-repo https://github.com/org/repo \
  --github-token-envvar GITHUB_TOKEN
```

### Options:

- `--name`: Name of the app (required)
- `--patch-method`: Method to patch upstream changes (script or kustomize)
- `--sync-method`: Method to sync upstream changes (vendir or kustomize)
- `--team`: Team responsible for the app
- `--upstream-chart`: Path to the upstream chart
- `--upstream-repo`: URL of the upstream repository
- `--github-token-envvar`: Name of environment variable containing GitHub token
- `--dry-run`: Only print what would be done

After running the command check the PR in `giantswarm/github`.

## Create a container repo

To host container images based on the new repository, [set up registry repositories](https://intranet.giantswarm.io/docs/dev-and-releng/container-registry/) for it.

## Final touches

- On the repository home page near `About`, click the gear (⚙️) icon to adjust the repository description and tags. Under "Include in the home page" de-select the Packages and Environments options.
- Add documentation to the `docs/` folder.
- Replace the `README.md` of your new repository with meaningful info about the software you're offering there.
- Learn [how to publish the app in a catalog]({{< relref "/docs/dev-and-releng/app-developer-processes/adding_app_to_appcatalog" >}})

# Manual instructions

## Prerequisites

- the `git` CLI
- the [GitHub CLI](https://cli.github.com/) `gh`
- [`devctl`](https://github.com/giantswarm/devctl) version 6.12.0 or newer

## Step 1 - Preparation

Since you will need the app and repository name several times on the command line, we first create an environment variable `APP_NAME` with the new repository name as the value.

Example:

```nohighlight
export APP_NAME=test-app
```

Here we assume you want to create the new app and repository named `test-app`.

## Step 2 - Repo creation

In your current command line / shell session, navigate to the directory where you keep git clones.

**Note:** No need to create an empty sub folder just for the new repo, as this will happen automatically in the next step.

Now create the repository, using our [template-app](https://github.com/giantswarm/template-app) to pre-fill its content. Execute this command to create the new **public** repository:

```nohighlight
gh repo create \
  --clone \
  --public \
  --template=giantswarm/template-app \
  giantswarm/${APP_NAME}
```

Note: The above command will create a public repository and the repo will include the Apache 2.0 license. You can replace the flag `--public` with `--private` to create a private repository instead.

## Step 3 - Name replacement

Let's fill in the actual app name in a bunch of places in the new repo's content, as otherwise we would have just the placeholder `{APP-NAME}` in there.

Make sure to navigate into your local clone of the repository:

```nohighlight
cd ${APP_NAME}
```

Here are your commands to run:

```nohighlight
mv helm/APP-NAME helm/${APP_NAME}

devctl replace \
  -i '{APP-NAME}' ${APP_NAME} \
  --ignore '.git/**' '**'
```

Commit and push these replacements:

```nohighlight
git commit -a -m "Replace placeholder by ${APP_NAME}"
git push origin $(git rev-parse --abbrev-ref HEAD)
```

## Step 4 - Configure settings

Now configure the GitHub repository settings (permission, branch protection, Renovate access, etc.) with one simple command:

```nohighlight
devctl repo setup giantswarm/${APP_NAME}
```

## Step 5 - Set up repository automation

To maintain team ownership and keep the repository up-to-date with our standards, you should add the new repository to your team's list in [giantswarm/github](https://github.com/giantswarm/github/tree/main/repositories). See the [README](https://github.com/giantswarm/github) for more details.

## Step 6 - Create a container repo

To host container images based on the new repository, [set up registry repositories](https://intranet.giantswarm.io/docs/dev-and-releng/container-registry/) for it.

## Step 7 - Final touches

- On the repository home page near `About`, click the cog icon to adjust the repository description and tags. Under "Include in the home page" de-select the Packages and Environments options.
- Add documentation to the `docs/` folder.
- Replace the `README.md` of your new repository with meaningful info about the software you're offering there.
- Learn [how to publish the app in a catalog]({{< relref "/docs/dev-and-releng/app-developer-processes/adding_app_to_appcatalog" >}})




