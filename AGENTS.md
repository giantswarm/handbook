# Handbook editing guidelines

Hugo/Docsy site, published at <https://handbook.giantswarm.io>. Pages live under `content/docs/`, at the same path as the URL.

- **Public.** No customer names, credentials or internal hostnames. Internal content goes in the [Intranet](https://github.com/giantswarm/giantswarm) (see its `AGENTS.md`). See [Publishing intranet docs](https://intranet.giantswarm.io/docs/security/isms/operations/publish-intranet-docs/).
- The Intranet build copies `content/docs/` over its own, so a page here overrides the intranet file at the same path.
- Link to intranet pages by full URL. A `relref` to a page missing here breaks the build. Use `relref` for handbook pages: `{{< relref "/docs/people" >}}` (absolute, no `.md`, no trailing slash).
- Use the terms in the Glossary (`content/docs/glossary/_index.md`). Add missing terms in the same PR.
- `content/docs/rfcs/` is generated from giantswarm/rfc (`make rfcs`). Don't edit it.
- One page per directory, as `_index.md`. Lowercase names, `-` between words.
- Front matter: `title` (rendered as H1, so body headings start at `##`), `description`, `classification: public`; optional `linkTitle`, `weight`, `toc_hide`, `aliases` (add old paths when moving). No review fields (`owner`, `last_review_date`, `expiration_in_days`): review issues only run on the Intranet repo. Copy keys from nearby pages.
- Images go next to the page, linked by file name. Use ` ```mermaid ` blocks for diagrams.
- Search the Handbook and the Intranet for existing pages first. Link to them, don't duplicate.
- Preview: `hugo server`, or `docker-compose up` (http://localhost:8081).
