---
title: "Checking Flux 2.0 Breaking Changes"
owner:
- https://github.com/orgs/giantswarm/teams/team-teddyfriends
confidentiality: public
---

### Purpose

`Flux 2.0` release is anticipated within the next few weeks (June 2023). As part of this release, there are some breaking changes within `kustomize 5.0` that need to be checked by customers in their gitops configurations before Giant Swarm upgrades to this release in Management Clusters. 

### The Breaking Changes

Note: This does not replace reading the release notes. Please review the full release notes here.
- [flux/v2.0.0](https://github.com/fluxcd/flux2/releases)
<!-- markdown-link-check-disable -->
<!-- link is valid but link-checker is complaining due a 404 ¯\_(ツ)_/¯-->
- [kustomize/v5.0.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.0.0)
<!-- markdown-link-check-enable -->

The main takeaway here is that `patchesStrategicMerge` and `patchesJson6902` are deprecated in `v1beta1` for removal in `v1`.

Whilst you can use `kustomize edit fix`, this is known to break `kustomize build` when updating `patchesStrategicMerge`. 
- This is because `patchesStrategicMerge` allows multiple patches to exist in a single file whilst `patches` does not. See [upstream issue](https://github.com/kubernetes-sigs/kustomize/issues/5049).
- For future automatic splitting of `patchesStrategicMerge` files. See [upstream issue](https://github.com/kubernetes-sigs/kustomize/pull/5059).

### What do I need to do?

- Review the release notes and breaking changes above. 
- Check your gitops implementation for usage of `patchesStrategicMerge` and `patchesJson6902`. 
- Replace with `patches`.
    - if relevant, split `patchesStrategicMerge` entries before converting them to `patch` entries.
- Check your customer specific issue found in your repo or the project board for updates on when Giant Swarm will upgrade.

Please reach out to Giant Swarm with any questions or help.