---
title: Using Helm at Giant Swarm
linkTitle: Helm
description: >
  We use Helm to deploy our App Platform. This page is for local setup and
  tips and tricks.
confidentiality: public
---

## Aliases

- All actions in Helm are scoped to a namespace.
- You can check all namespaces with the `-A` flag e.g. `helm ls -A`.
- But these aliases based on Vaclav's awesome `kubectl` aliases may help.

```bash
alias helmg="helm -n giantswarm"
alias helmk="helm -n kube-system"
alias helmm="helm -n monitoring"
```

## AppCatalogs

- Our Giant Swarm App Platform is built on Helm [chart repositories](https://helm.sh/docs/topics/chart_repository/#helm).
- app-operator gets the repository URL from the catalog CR but you can also use it locally.

```bash
$ helm repo add control-plane-catalog https://giantswarm.github.io/control-plane-catalog/
```

- Example installing app-operator in KIND.

```
helm install -n giantswarm app-operator control-plane-catalog/app-operator
```

- :caution: Be careful when installing charts manually in test MCs and remove
them after. Don't do this in prod MCs unless there is no alternative.

## Helm 3: Three Way Merge

- This is one of the major changes in Helm 3. Now the current state of the cluster
is included when the strategic merge patch is generated.
- For example if a deployment is scaled down the merge will scale it back up.
- This means manual changes are higher risk with Helm 3.
- To prevent app-operator making changes you can [cordon the app CR]({{< relref "/docs/dev-and-releng/app-developer-processes/cordoning_app_and_chart_crs.md" >}}).
- See the [Helm docs](https://helm.sh/docs/faq/#improved-upgrade-strategy-3-way-strategic-merge-patches)
for more detail on three way merge.

## Templating

### Coding Standards

- See [fmt](https://github.com/giantswarm/fmt#helm-charts).

### Tips & Tricks

Help with common templating issues.

#### Is a chart deployed with Helm 2 or Helm 3?

- You can use the `Release.Service` [built-in object](https://helm.sh/docs/chart_template_guide/builtin_objects/).
- On Helm 3 it is always `Helm`.
- On Helm 2 it is always `Tiller`.

## Values

Tools, tips and tricks for working with Helm values.

### helm-diff plugin

This [plugin](https://github.com/databus23/helm-diff) is useful for comparing values changes.
It can also do other comparisions. See the docs.

```bash
helm plugin install https://github.com/databus23/helm-diff

helm -n giantswarm diff revision release-operator-unique 18 19
```

### helm get values --all

By default `helm get values` only returns the overrides for the chart. In our case
the config specified in the app CR.

The `--all` flag shows all the computed values including those in values.yaml in the
chart.

## Removed API versions

If an apiVersion has been removed then chart-operator will fail to update the helm release. e.g.

```
current release manifest contains removed kubernetes api(s) for this kubernetes version and it is therefore unable to build the kubernetes objects for performing the diff. error from kubernetes: [unable to recognize \"\": no matches for kind \"Role\" in version \"rbac.authorization.k8s.io/v1beta1\", unable to recognize \"\": no matches for kind \"RoleBinding\" in version \"rbac.authorization.k8s.io/v1beta1\
```

The apiVersion in the helm release secret needs to be updated to a supported value.
This can be done with the https://github.com/helm/helm-mapkubeapis plugin.

It can remap both deprecated and removed API versions.

### mapkubeapis plugin

Install the plugin.

```bash
helm plugin install https://github.com/helm/helm-mapkubeapis
```

Scale down chart-operator.

```bash
kubectl -n giantswarm scale deploy chart-operator --replicas 0
```

```bash
helm mapkubeapis -n efk-stack-app efk-stack-app

2022/04/12 13:03:39 Release 'efk-stack-app' will be checked for deprecated or removed Kubernetes APIs and will be updated if necessary to supported API versions.
2022/04/12 13:03:39 Get release 'efk-stack-app' latest version.
2022/04/12 13:03:39 Check release 'efk-stack-app' for deprecated or removed APIs...
2022/04/12 13:03:40 Found 3 instances of deprecated or removed Kubernetes API:
"apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
"
Supported API equivalent:
"apiVersion: rbac.authorization.k8s.io/v1
kind: Role
"
2022/04/12 13:03:40 Found 1 instances of deprecated or removed Kubernetes API:
"apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
"
Supported API equivalent:
"apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
"
2022/04/12 13:03:40 Finished checking release 'efk-stack-app' for deprecated or removed APIs.
2022/04/12 13:03:40 Deprecated or removed APIs exist, updating release: efk-stack-app.
2022/04/12 13:03:40 Set status of release version 'efk-stack-app.v76' to 'superseded'.
2022/04/12 13:03:40 Release version 'efk-stack-app.v76' updated successfully.
2022/04/12 13:03:40 Add release version 'efk-stack-app.v77' with updated supported APIs.
2022/04/12 13:03:40 Release version 'efk-stack-app.v77' added successfully.
2022/04/12 13:03:40 Release 'efk-stack-app' with deprecated or removed APIs updated successfully to new version.
2022/04/12 13:03:40 Map of release 'efk-stack-app' deprecated or removed APIs to supported versions, completed successfully.
```

Scale up chart-operator.

```bash
kubectl -n giantswarm scale deploy chart-operator --replicas 1
```
