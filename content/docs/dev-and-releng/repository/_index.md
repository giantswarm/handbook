---
linkTitle: Create new repository
title: Creating a new GitHub repository
description: A Giant Swarm repository is declared as one entry in its team's file in giantswarm/github and created, set up and released from it by the automation. Here is how you declare one.
aliases:
  - /docs/dev-and-releng/repository/app/
  - /docs/dev-and-releng/repository/generic/
  - /docs/dev-and-releng/repository/go/
---

Do not hit the "Create repository" button on GitHub. A Giant Swarm repository is **declared**: one entry in the owning team's file `repositories/team-<name>.yaml` of [giantswarm/github](https://github.com/giantswarm/github) -- name, description, visibility, `componentType`, `gen.flavours`, `gen.language` -- and the automation creates the repository from the template those fields imply, pushes the scaffold, applies the settings, permissions, branch protection, CircleCI, CODEOWNERS and catalog entry, runs the first release, and keeps the repository as declared from then on. Every field is documented in [`.github/repositories.schema.json`](https://github.com/giantswarm/github/blob/main/.github/repositories.schema.json).

Three ways open that pull request as you:

- the **Repositories** page of the developer portal (*Create*);
- `devctl repo create --team <team> --name <name> --component-type <type> --flavour <flavour> --language <language> --description "<text>" --visibility <public|private> --dry-run` -- the dry run shows the entry, the derived template and the verdict; drop `--dry-run` to open the pull request;
- the **Repo Manager** agent in the portal's chat.

A pull request that only adds new, valid entries -- at most three, by a member of the owning team -- is approved by the machine and merges within minutes; the repository, its first release and its chart follow without a person. Changing, transferring, deprecating or archiving a repository is the same kind of pull request with the owning team's review.

The full guide -- the fields and what each implies, the reviews, the lifecycle values, the inventory and the nightly repair -- is the intranet page [Creating and setting up a repository](https://intranet.giantswarm.io/docs/dev-and-releng/repository-setup/). The former per-type procedures (app, generic, Go) are replaced by the declaration: the type is what `componentType`, `gen.flavours` and `gen.language` say.
