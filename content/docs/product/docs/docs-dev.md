---
title: The Docs development environment
linkTitle: Development
weight: 7
description: >
  This section explains how the docs development environment works and how to work with it locally.
---

## Developing on the docs

### Repository overview

The repository named `docs` holds the main **content** of our documentation. The documentation site is created using the static site generator [HUGO](http://gohugo.io/) based on Markdown files in the `src/content/` directory of the `docs` repository.

Additional content is tied in through the scripts

- `scripts/aggregate-changelogs`: Aggregates changelog entries into the `src/content/changes` destination.
- `scripts/update-crd-reference`: Generates reference pages for our custom resource definitions in the `src/content/reference/platform-api` destination.
- `update-helm-chart-reference`: Generates reference pages for our Helm charts in the `src/content/reference/platform-api` destination.
- `scripts/update-external-repos`: Tutorials that need their own code repository. They must have a `docs` subfolder with the Markdown content and optionally some images. Configuration is found in `scripts/update-external-repos/repositories.txt`.

To update these external content types, the `Makefile` provides specific targets:

- `make changes`
- `make update-external-repos`
- `make update-crd-reference`
- `make update-cluster-app-reference`

There are two GitHub Actions workflows that run these scripts automatically:

- `Update generated content`: It runs every day in the morning and creates or update the `Semi-automatic update of generated content` pull requests with the changes from the different sources.
- `Merge generated content updates`: It runs every Friday and merges the `Semi-automatic update of generated content` pull request to release automatically the changes.

**Note**: In order to publish the release information or other automatic generated content, you need to run the `Update generated content` manually and merge the pull request generated after review the changes.

### Iterating on content locally

If you want to iterate quickly on some content you can use the `make dev`
command.

You can access the server at `http://localhost:1313/`. The server can be stopped by hitting `Ctrl + C`.

It will not include content from the external repositories.

#### Previewing changes

You can bring up the final site using the following commands:

```nohighlight
make docker-build
docker-compose up
```

You can access the server at `http://localhost:8080/`. The server can be stopped by hitting `Ctrl + C`.

### Shortcodes

Shortcodes allow the use of a string in any number of places in the docs, while maintaining it only in one place. We use these to place, for example, configuration details.

The goal here is to give users accurate, complete and up-to-date information.

Shortcodes exist as one file each in the folder [src/layouts/shortcodes](https://github.com/giantswarm/docs/tree/master/src/layouts/shortcodes).

#### Usage

A shortcode can only be placed in *Markdown* text. The file name (without `.html` suffix) is used as a placeholder, wrapped in a certain way, like

```markdown
{{/*% placeholder */%}}
```

For example, to place the shortcode from `first_aws_autoscaling_version.html`,
the content would look like this

```markdown
... since version {{/*% first_aws_autoscaling_version */%}} and ...
```

and would get rendered like

```nohighlight
... since version 6.3.0 ...
```

#### List of shortcodes with explanation

- `platform_support_table`: A table that displays information regarding which
providers support a feature described in the context. Look for examples in the
code base too, to understand how it is configured. The shortcode offers three
parameters `aws`, `azure`, and `kvm`. Each one functions the same way:

    - Multiple key-value-pairs can be set, separated by comma. Example: `alpha=v10.0.0,beta=v11.0.0,ga=v12.0.0`.

    - Key-value-pairs use the `=` character to separate key and value.

    - The key must be either `alpha`, `beta`, `ga`, or `roadmap`, with a meaning as follows.

        - `alpha`: Version that made the feature available in an Alpha stage. If no value/version is given, it means that the feature is currently in the Alpha stage.

        - `beta`: Version that made the feature available in a beta stage. If no value/version is given, it means that the feature is currently in the Beta stage.

        - `ga`: Version that made the feature GA (general availability). If no value/version is given, it means that the feature is currently in the GA stage.

        - `roadmap`: The feature is on our roadmap for the given provider. The value muest be the roadmap issue URL.

    - For the keys `alpha`, `beta`, and `ga` the (optional) value is expected to be a semver version number of the workload cluster release. For example, `beta=v10.0.0` indicates that the feature was published in Beta in release v10.0.0. If only the key is present, but no value, this indicates that the version number is unknown.

    - For the `roadmap` key, a value must be given, and the value must be the `https://github.com/giantswarm/roadmap` issue URL about the feature.

- `autoscaler_utilization_threshold`: Utilization threshold for the kubernetes
autoscaler, including percent unit, as we configure it by default. Below this
utilization, the autoscaler will consider a node underused and will scale down.

- `default_aws_instance_type`: The AWS EC2 instance type we use by default for
worker nodes.

- `default_cluster_size_worker_nodes`: The default number of worker nodes we
use when a cluster is created without specifying a number.

- `first_aws_autoscaling_version`: The workload cluster release version that introduced
autoscaling for AWS.

- `first_aws_nodepools_version`: The workload cluster release version that introduced
nodepools for AWS.

- `first_azure_nodepools_version`: The workload cluster release version that introduced nodepools for Azure.

- `first_spotinstances_version`: The workload cluster release version that introduced
spotinstances for AWS.

- `minimal_supported_cluster_size_worker_nodes`: The minimum number of worker
nodes a cluster must have in order to be supported by Giant Swarm.

### About the Header and Footer

The header and footer are to be kept in sync with www.giantswarm.io
In order to do this we copy the HTML and CSS specific to those parts of the page.

Fully automating this is a goal, but for now check out the Makefile target
called `grab-main-site-header-footer` for one idea of how to grab the header and
footer using curl.

Copying just the CSS styles that apply to the header and footer is a bit trickier.
There are some loosely arranged scripts that can be used to help automate this
in the future.

Files starting with `gs_` are involved in making the header and footer appear
and behave correctly.

`partials/gs_header.html` - The unedited html of the header at www.giantswarm.io

`partials/gs_mobile_menu.html` - The unedited html of the mobile navigation menu at www.giantswarm.io

`partials/gs_footer.html` - The unedited html of the footer at www.giantswarm.io

`partials/gs_styles.html` - Automatically extracted styles which apply to
                            elements found in the header and footer, as well
                            as hand written override styles to make it play nicely
                            with CSS already present in docs.

`scripts/gs_menu.js`      - Hand written javascript that recreates the interactive
                            functionality of the navigation menus.

### Deploying

To publish the content in this repository, a release is needed. Releases are created automatically for every push to the `master` branch, so normally whenever a pull request gets merged. [app-updater](https://github.com/giantswarm/app-updater) then updates the `docs-app` app CR on `gollum`.

Latest content should be visible after a short period. When checking, make sure to circumvent any browser cache. For example, do this by keeping the Shift key pressed while hitting the reload button of your browser.

### Linting and validation

Many style rules are checked automatically in CI. You can also execute the check locally before pushing commits using the `make lint` command.

For a reference of all rules please check the [DavidAnson/markdownlint documentation](https://github.com/DavidAnson/markdownlint/blob/master/doc/Rules.md).

There is a project specific configuration in place via the `.markdownlint.yaml` file.

To check locally whether all internal links are correct, use `make linkcheck`.

To check both internal and external links, use `make linkcheck-external`.

### Solutions for specific problems

#### Kubernetes API versions

Keep an eye on API versions of Kubernetes resources.

**Guideline:** Examples and references should cover all possible API versions of Kubernetes versions we provide to our customers.

**Guideline:** If possible, use the latest API version supported by Kubernetes.

**Guideline:** If different Kubernetes versions require different API versions, we offer multiple examples and explain which Kubernetes version requires which API version.

An example for this would be the deprecation of the API version of Ingress resources from `networking.k8s.io/v1beta1` to `networking.k8s.io/v1` in Kubernetes 1.19.

### Editing content

Edit existing content in the `src/content` folder of the docs repository.

#### Front matter

Each documentation page consists of a Markdown file that starts with some metadata called [front matter](https://gohugo.io/content-management/front-matter/). Some hints:

- Please look at the other pages to get an idea of what the front matter is good for.
- When your page's `title` is too long for the navigation menu, add a `linkTitle` field with a short title.
- Please double-check whether the `description` is still up-to-date or could be improved. It will often show up Google search results.

Special front matter fields we use:

- `last_review_date`: Date of the last time somebody checked the entire page for validity.
- `owner`: List of GitHub team URLs for the team(s) or SIG(s) owning the page. The owning team/SIG is the one responsible for keeping the content up-to-date and useful.
- `user_questions`: List of questions this article answers. Written from a user's perspective. E. g. _How do I ..._.

#### Hyperlinks

In order to link to other docs pages, please use this format only:

```markdown
... see the [gsctl reference]({{/*< relref "/ui-api/gsctl" */>}}) for details. ...
```

Note that

- Hyperlinks URLs must start with `/`
- Must usually end with `/`
- Must not contain `https://` or the host name `docs.giantswarm.io`.

This is important to support automation when links have to change, or when checking links.

#### Table of contents and headline anchors

The rendered documentation pages will have a table of contents on the left hand side and an anchor for every intermediate headline. This anchor is normally generated from the headline's content. For example, a headline

```markdown
### Another section with more content
```

will result in a headline

```html
<h3 id="another-section-with-more-content">Another section with more content</h3>
```

This means that anchors and URLs can become quite long. It also means that when the headline text changes, all links to this headline also have to be updated.

To control this behavior, the anchor ID can be edited as a suffix to the markdown headline, like in the following example:

```markdown
### Another section with more content {#more}
```

will result in a headline

```html
<h3 id="more">Another section with more content</h3>
```

