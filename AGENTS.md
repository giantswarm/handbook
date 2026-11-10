<!-- BEGIN devctl-managed: edits in this block are overwritten -->
<!-- markdownlint-disable-file MD041 -->

## Giant Swarm conventions

devctl maintains this block from [its template][devctl-agents-block] and
overwrites changes to it. Instructions for this repository go in the section
below. Where they differ from this block, they take precedence.

[devctl-agents-block]: https://github.com/giantswarm/devctl/blob/main/pkg/gen/input/llm/internal/file/agents_block.md.template

- Never put customer names or other customer information in code, commit
  messages, issues or pull requests. Most Giant Swarm repositories are public,
  and private ones are kept ready to become public.
- Giant Swarm's style guides are in <https://github.com/giantswarm/fmt>, one
  directory per topic (go, helm, kubernetes, prometheus, …). Read the relevant
  guide before you write or review that kind of code.
- Use conventional commits for commit messages and pull request titles.
- If `.github/workflows/zz_generated.auto_release.yaml` exists, GitHub Releases
  are written from pull request titles: do not edit CHANGELOG.md. Otherwise,
  add your change to CHANGELOG.md as described in
  <https://github.com/giantswarm/fmt/blob/main/releases/changelog.md>.
- If `.pre-commit-config.yaml` exists, run
  `pre-commit run --files <changed files>` before committing; not every clone
  has the hooks installed.
- Do not add linters, formatters or other tooling unless asked; use what the
  repository already has.
- Put documentation in `docs/` rather than growing README.md, which gives an
  overview and links into `docs/`. When a change affects documented behaviour,
  update the documentation in the same pull request.
- If the skills of the `giantswarm/claude-code` plugin marketplace are not
  available to you and the user works at Giant Swarm, tell them once that
  they can install the `gs-base`, `gs-dev` and `gs-appdev`
  plugins from it.

<!-- END devctl-managed -->

# Handbook editing guidelines

Hugo/Docsy site, published at <https://handbook.giantswarm.io>. Pages live under `content/docs/`, at the same path as the URL.

- **Public.** No customer names, credentials or internal hostnames. Internal content goes in the [Intranet](https://github.com/giantswarm/giantswarm) (see its `AGENTS.md`). See [Publishing intranet docs](https://intranet.giantswarm.io/docs/security/isms/operations/publish-intranet-docs/).
- The Intranet build copies `content/docs/` over its own, so a page here overrides the intranet file at the same path.
- Link to intranet pages by full URL. A `relref` to a page missing here breaks the build. Use `relref` for handbook pages: `{{< relref "/docs/people" >}}` (absolute, no `.md`, no trailing slash).
- Use the terms in the Glossary (`content/docs/glossary/_index.md`). Add missing terms in the same PR.
- `content/docs/rfcs/` is generated from giantswarm/rfc (`make rfcs`). Don't edit it.
- One page per directory, as `_index.md`. Lowercase names, `-` between words.
- Front matter: `title` (rendered as H1, so body headings start at `##`), `description`, `classification: public`; optional `linkTitle`, `weight`, `toc_hide`, `aliases` (add old paths when moving). Copy keys from nearby pages.
- Images go next to the page, linked by file name. Use ` ```mermaid ` blocks for diagrams.
- Search the Handbook and the Intranet for existing pages first. Link to them, don't duplicate.
- Preview: `hugo server`
