# Template Catalog

> **Generated file.** Do not edit by hand.
> Source of truth: [`catalog/templates.yaml`](templates.yaml).
> Regenerate with: `python3 scripts/qk update-docs`

Reviewable via pull request. Candidates from external lists belong under
`catalog/drafts/` until a human promotes them into `templates.yaml`.

| ID | Title | Kind | Path / install | Tags |
|----|-------|------|------|------|
| `claude-md-global` | Global CLAUDE.md | file | `templates/claude-md-global.md` | `claude-code`, `bootstrap`, `markdown` |
| `claude-md-project` | Project CLAUDE.md | file | `templates/claude-md-project.md` | `claude-code`, `bootstrap`, `markdown`, `project` |
| `settings-local-project` | Project settings.local.json | file | `templates/settings-local-project.json` | `claude-code`, `bootstrap`, `json`, `permissions` |
| `ontology-scaffold` | Ontology scaffold | directory | `templates/ontology-scaffold` | `claude-code`, `ontology`, `scaffold`, `directory` |
| `research-paper-starter-pack` | Research paper starter pack | directory | `templates/research-paper-starter-pack` | `quarto`, `manuscript`, `research`, `directory` |
| `atelier` | Atelier documentation-website project type (mcanouil/quarto-atelier) | extension-project-type | `quarto add mcanouil/quarto-atelier` | `quarto`, `extension`, `project-type`, `website`, `documentation`, `brand` |
| `keisen` | Keisen display tables for Typst (@preview/keisen) | typst-package | `#import "@preview/keisen:0.1.0": *` | `typst`, `package`, `tables`, `reporting`, `pdf` |

## `claude-md-global` — Global CLAUDE.md

- **Path:** `templates/claude-md-global.md`
- **Kind:** `file`
- **Tags:** `claude-code`, `bootstrap`, `markdown`

Cross-project Claude Code context for ~/projects (or similar root). Covers txtarchive, analysis numbering, Quarto pointers, and ontology bootstrap conventions. Copy to your projects root and fill placeholders.

**When to use:** New machine setup or when establishing shared global Claude Code context across multiple projects.

## `claude-md-project` — Project CLAUDE.md

- **Path:** `templates/claude-md-project.md`
- **Kind:** `file`
- **Tags:** `claude-code`, `bootstrap`, `markdown`, `project`

Project-level CLAUDE.md scaffold with data sources, key outcome, analysis progression, packages, gotchas, profiling protocol, and review checklist. Placeholders use {ALL_CAPS} form.

**When to use:** Starting or upgrading a project that needs a short, decision-oriented CLAUDE.md (not a dump of reference material).

## `settings-local-project` — Project settings.local.json

- **Path:** `templates/settings-local-project.json`
- **Kind:** `file`
- **Tags:** `claude-code`, `bootstrap`, `json`, `permissions`

Minimal Claude Code project permissions allow-list (WebSearch, git, gh, txtarchive). Copy to .claude/settings.local.json and tighten for the project stack (R, Python, or minimal).

**When to use:** Bootstrapping .claude/ permissions for a new or older project.

## `ontology-scaffold` — Ontology scaffold

- **Path:** `templates/ontology-scaffold`
- **Kind:** `directory`
- **Tags:** `claude-code`, `ontology`, `scaffold`, `directory`

Directory template for ontology-driven Claude Code configuration: CLAUDE.md.template plus rules/ (schema, constraints, assumptions, authority scoring, method tree, validation gates, output conventions). Replace {PLACEHOLDERS} after install.

**When to use:** When a project outgrows a flat CLAUDE.md and needs typed constraints, assumption tracking, and validation gates (architecture review Level 1+).

## `research-paper-starter-pack` — Research paper starter pack

- **Path:** `templates/research-paper-starter-pack`
- **Kind:** `directory`
- **Tags:** `quarto`, `manuscript`, `research`, `directory`

Quarto manuscript starter (ZIP + README) wired for DOCX/PDF with manuscript.yml, section includes, BibTeX, and CSL placeholder. Unzip, replace CSL/journal reference as needed, then quarto render.

**When to use:** Starting a Quarto research paper / manuscript with citation and multi-format output scaffolding.

## `atelier` — Atelier documentation-website project type (mcanouil/quarto-atelier)

- **Install:** `quarto add mcanouil/quarto-atelier`
- **Kind:** `extension-project-type`
- **Project type:** `atelier` (inherits `website`)
- **Requires:** Quarto >= 1.9.36
- **Source:** <https://github.com/mcanouil/quarto-atelier>
- **Docs:** <https://mickael.canouil.fr/posts/2026-10-05-quarto-atelier-project-type/>
- **Tags:** `quarto`, `extension`, `project-type`, `website`, `documentation`, `brand`

Quarto extension by Mickaël Canouil that contributes the `atelier` project type, a `website` underneath. A site's _quarto.yml only needs `project: type: atelier` plus its title, URLs, and navbar. The extension supplies the footer, a light/dark theme driven by the site's _brand.yml, Open Graph and Twitter card tags, a search overlay in the navbar, llms.txt, page navigation, and accessibility scripts (skip link and fixes). Configuration and styling only; it carries no data.

**When to use:** Standing up a documentation website with consistent chrome from a short _quarto.yml, or as the reference implementation when building your own extension-provided project type to share one configuration across many repos.

Minimal `_quarto.yml`:

```yaml
project:
  type: atelier

website:
  title: "My Site"
  site-url: https://example.org/my-site
  repo-url: https://github.com/example/my-site
  navbar:
    left:
      - href: index.qmd
        text: Home

# Quarto does not pass the website block to filters, so repeat the URL
# here for the og:url tag.
extensions:
  atelier:
    site-url: https://example.org/my-site
```

**Notes / caveats:** Overrides merge key by key and the site wins (e.g. move search to the sidebar with website.search.location). List settings such as include-after-body scripts and filters stack with the extension's and cannot be removed; if a site needs to drop one, that default does not belong in a shared project type. Every site moves with the extension, so a bad default reaches all of them: each site keeps its own copy under _extensions/ (commit it), and upstream keeps sites current with a monthly Quarto Extensions Updater pull request that is reviewed before merge. atelier carries the author's own choices (en-GB locale, his footer); it is a model for writing your own project type (e.g. a branded team docs/report site), not necessarily one to adopt as-is. Upstream README pins a release, e.g. `quarto add mcanouil/quarto-atelier@0.10.5`.

## `keisen` — Keisen display tables for Typst (@preview/keisen)

- **Import:** `#import "@preview/keisen:0.1.0": *`
- **Kind:** `typst-package`
- **Version:** 0.1.0
- **Requires:** Typst compiler >= 0.15.0
- **Source:** <https://github.com/mcanouil/keisen>
- **Docs:** <https://m.canouil.dev/keisen/>
- **Tags:** `typst`, `package`, `tables`, `reporting`, `pdf`

Typst package by Mickaël Canouil that implements the display-table grammar of gt (R) and great_tables (Python): describe the header, stub and row groups, column labels and spanners, formats (integer, currency, percent with decimal arithmetic), summary rows, footnotes, and source notes; Keisen lays out the table. Row groups that cross a page break reprint their label. Works in plain Typst and in Quarto documents rendered with `format: typst`.

**When to use:** Publication-quality tables (clinical summaries, regression tables, grouped reports) in Typst PDFs or Quarto Typst output, including reMarkable-friendly layouts, without hand-writing #table cells.

Minimal Typst example:

```typst
#import "@preview/keisen:0.1.0": *

#let sales = (
  (region: "North", product: "A", units: 120, revenue: 2400, margin: 0.12),
  (region: "North", product: "B", units: 80, revenue: 1900, margin: 0.03),
  (region: "South", product: "A", units: 95, revenue: 2100, margin: 0.08),
)

#display-table(
  sales,
  table-header(title: [Mock sales]),
  table-stub(rowname: "product", group: "region", label: [Product]),
  format-integer("units"),
  format-currency("revenue", currency: "USD", decimals: 0),
  format-percent("margin", decimals: 1),
  table-source-note([Mock data only.]),
  theme: theme-booktabs(),
)
```

**Notes / caveats:** Version 0.1.0 (announced 2026-10-22, https://mickael.canouil.fr/posts/2026-10-22-keisen-0-1/); upstream says the API is still settling, so pin the version and re-check on upgrade. min_typst is the `compiler` field of the package's typst.toml. Default currency formatting uses a thin-space thousands separator ("$2 400"). An LLM-readable copy of the docs is at https://m.canouil.dev/keisen/llms.txt. Tables are built from data in the document: use mock or de-identified data only, never PHI.
