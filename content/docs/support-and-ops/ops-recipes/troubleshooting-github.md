---
title: "Troubleshooting GitHub"
owner:
- https://github.com/orgs/giantswarm/teams/team-honeybadger
description: "Troubleshooting GitHub related issues."
classification: public
---

Troubleshooting GitHub related issues.

## Deploy key is already in use

Deploy keys are a great way to limit access to a single GitHub repository. The public part of the SSH key is attached directly to the repository instead of a personal account. The keys are by default granted only read permission on the repository. Optionally they can be granted write access where it can perform the same actions as an organization member with admin access.

A deploy key can be attached to a single repository only. Adding it to another one will result in a `Key is already in use` error.

However, you can technically get this error when you added the key to a repository that no longer exists / was deleted recently. You probably don't want to reuse the key in such a case but instead generate a new pair and use that.

If for some reason you want to reuse the key and the repository where it was attached is deleted, the reason is that GitHub "soft" deletes repositories. It still exists for a time for restoration and the key is still attached to it, it is just completely hidden.

1. Organization repositories can be restored under the GitHub organization settings page under `Deleted Repositories`.
2. Once the repository is restored, remove the key under the `/settings/keys`.
3. Delete the restored repository again if you don't need it anymore.
4. Add the key to the new repository.
