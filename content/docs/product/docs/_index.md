---
title: How to write documentation
linkTitle: Documentation
weight: 5
description: >
  This section explains how to document functions of our product for our end users.
---

In this section you learn how to add to and maintain the documentation for our product. We assume here that you are part of a product team or a SIG and want to maintain the content your team/SIG is responsible for.

## Public by default

When we talk about documentation here, we talk about everything under our public documentation site, which is [docs.giantswarm.io](https://docs.giantswarm.io/).

Our goal is to have all documentation for our product be available via that site. This is towards the mission that every question should be answerable by a link to the appropriate document.

## Responsibilities

Our responsibilities for public documentation are layered.

- Ownership for content is assigned **according to team or SIG responsibilities**. For example, Team Horizon "owns" articles related to [Developer Platform Overview](https://github.com/giantswarm/docs/blob/main/src/content/platform-overview/_index.md) as you can see on the front matter (defined by the YAML header fields).

- [SIG Docs](TBD) is responsible for overall content coherence and consistency.

- [SIG User Experience](TBD) (UX) takes responsibility for the overall UI and user experience, having the docs site online and available, have a user-friendly search etc.

## Editing content

In general, modifying content works as follows:

The [giantswarm/docs](https://github.com/giantswarm/docs) repository is where all the documentation content lives. To modify content, clone that repository, create a branch, provide a pull request (PR).

**Note:** You can [run the docs site locally](https://handbook.giantswarm.io/docs/product/docs/docs-dev/) to preview your changes.

### Reviews

For pull requests, **seek an agreement and approval within your team first**. Then feel free to ask SIG Docs for approval, too. Asking SIG Docs for review is recommended, but optional. It might help to keep coherence throughout our documentation, which is maintained by lots of different people.

### Publishing is automatic

Once a pull request in the giantswarm/docs repository gets merged, the changes get published.

> (Under the hood, a new release is created using GitHub actions, immediately after the merge. Then, up to 10 minutes later, the release gets published via the `app-updater-app` on `gollum`. The app for serving `docs.giantswarm.io` lives in workload cluster `c68pn` on `gollum` installation, in the `docs` namespace.)

In the unlikely case that you don't want your changes to be released immediately (e. g. because you want to craft a release manually), simply add

```nohighlight
do not release
```

to your final commit message when merging.

### When to merge a docs PR

Changes to the docs content should be merged as soon as the content is relevant for users.

If a PR adds content for a new function that is not yet available to users, the docs pull request **should not be merged** and therefore remain marked as draft while it is not ready.

### Adding content

When adding content, several questions have to be answered:

- What content should be covered?
- Should the content be delivered as one page, or should there be several?
- What page title should I pick?
- Where should that page title live?
- What customer/user question(s) does this article answer?

Feel free to ping SIG Docs to discuss these questions, or join the weekly sync/special working hours call.

## Style

When writing documentation, there is a lot to be taken care of in terms of tonality, style, voice, and even formatting.

Feel free to give feedback to SIG Docs regarding what you would like to see guidelines for.
Information beyond the details below can be found in the [content styleguide](https://docs.google.com/document/d/1TKzd70koVmrJyXx0JOe15tK0-mIiGYkP3gz_2BxM844/edit).

### Writing goals and principles

Good content is clear, useful, friendly, inclusive and appropriate.

Our priority is to educate our users without patronizing or confusing them, so they can be successful in their work.

### Voice and tone

At Giant Swarm, we drink our own wine. Or, if I were to use a different tone, we dog-food. We know what our customers are going through, since we are using the same technology and tools that they are. That's why we can speak like an experienced and compassionate business partner. We are super professional, yet don't take ourselves too seriously.

We have done the research and the work, so we know a lot. We want to transfer that knowledge to our readers. Please remember to be plain-spoken and very clear.

Don't forget that you can have some fun. Find appropriate opportunities to be more uplifting than standard dry technical documentation.

### Grammar and mechanics

- Group related ideas and use descriptive headers and sub-headers.
- Focus your message. Lead with the main point or the most important content. If you find you're getting too far from the intended topic, you may need to create a second article that is related.
- Use active voice and positive language.
- Use second person and describe actions to the users.
- Use short words and sentences.
- Use specific examples.
- Provide context through embedded screenshots, videos, and GIFs.
- Avoid vague language, acronyms and abbreviations. Acronyms may be used when they are easier to understand than the long form.
- Be consistent in language and layout.
- Feel free to use contractions - e.g. you'll, we've. etc.

When in doubt, read your writing aloud - if it's hard to hear, the tone is too stiff.

### Formatting

- Titles and headers use standard sentence capitalization. In headers and text, capitalize proper names of products, features, and tools.
- Organize article content with H2s and H3s. Use H2s for higher-level topics or goals and use H3s within each section for supporting information or tasks.
- Only use ordered lists for step-by-step instructions.
- Use unordered lists to display examples or multiple notes. If an unordered list is longer than 10 items, use a table instead.
- When using and acronym/abbreviation, use the long form first and then the the acronym form in parentheses, to introduce the acronym.

### Code blocks and syntax highlighting

**Guideline:** For code blocks, we give language hints to ensure proper syntax highlighting.

A YAML block, for example, is opened with triple back-ticks followed by `yaml`:

~~~markdown
```yaml
foo: bar
```
~~~

**Guideline:** Shell commands and their output get the fake hint `nohighlight` to prevent any funky syntax highlighting.

If a code block includes command output, preprend the shell command with a `$ ` (dollar sign and one blank character).

Example:

~~~markdown
```nohighlight
$ gsctl --version
Version:      0.26.0 - https://github.com/giantswarm/gsctl/releases/tag/0.26.0
Build date:   2020-11-18T08:48:37Z
Commit hash:  5c7820239fc68fc9552eb2751ca3c3ceda47001c - https://github.com...
```
~~~

### CLI commands

**Guideline:** Where a CLI provides both long and short form flags, we use the long form for clarity.

**Guideline:** We avoid the equals sign between flag name and value where possible.

Good example:

```nohighlight
gsctl create cluster --owner acme
```

Bad examples:

```nohighlight
gsctl create cluster --owner=acme
gsctl create cluster -o=acme
gsctl create cluster -o acme
```

**Guideline:** We break a command into multiple lines once it becomes longer than ~60 characters,
using the backslash character. This makes it easier to read.

Example:

```nohighlight
gsctl create cluster \
  --owner acme \
  --create-default-nodepool false
```
## Product feature naming

When mentioning a feature, please make sure to use exactly the naming we decided on previously. If there is a canonical name for your feature, you should be able to find it in the [glossary]({{< relref "/docs/glossary/_index.md" >}}). If there isn't one, please kick off a discussion with SIG Product.

For information about the mechanics of the site generator refer to [Docs development environment]({{< relref "/docs/product/docs/docs-dev.md" >}})
