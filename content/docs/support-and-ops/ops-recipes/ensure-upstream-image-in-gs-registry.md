---
title: Ensure an upstream container image is available in our registries
classification: public
---

## Introduction

We may run into the situation that an image should be available in our main container registry (`gsoci.azurecr.io`), but it isn't.

The root cause could be manifold. Some suggestions:

- Geo-replication failed on the ACR side. This could mean that the image can be pulled form some locations, but not from others. In this case, the image should show up in the Azure portal.
- Retagger problems (if it's a third party image like e. g. `golang`)

## Mitigation

Even if the image seems to be available in the registry as shown in the Azure portal, the mitigation is to push it again.

WARNING: Pushing has to happen for multiple architectures (amd64, arm64). Don't use `docker push`, as it will default to your machine's architecture only!

### Install skopeo

Use `brew install skopeo` or use [these instructions](https://github.com/containers/skopeo/blob/main/install.md).

### Log in to ACR

Hopefully you have the Azure CLI `az` and `jq` installed.

Run this command:

```nohighlight
az acr login --name gsoci --expose-token | jq -r .accessToken
```

Copy the long token string (starts with `eyJ`), as you will need it in the next command.

### Copy the image

Now to copy the image with for all architectures, execute a command like the following, with the right source and target image and your token inserted. Do not change the username string!

```nohighlight
skopeo copy --multi-arch all \
  --dest-username 00000000-0000-0000-0000-000000000000 \
  --dest-password "eyJ..." \
  docker://golang:1.24.6-alpine3.22 \
  docker://gsoci.azurecr.io/giantswarm/golang:1.24.6-alpine3.22
```

As a result, you see verbose progress output as layers and manifests are copied.
