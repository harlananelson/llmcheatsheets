# Template Catalog

> **Generated file.** Do not edit by hand.
> Source of truth: [`catalog/templates.yaml`](templates.yaml).
> Regenerate with: `python3 scripts/qk update-docs`

Reviewable via pull request. Candidates from external lists belong under
`catalog/drafts/` until a human promotes them into `templates.yaml`.

| ID | Title | Kind | Path | Tags |
|----|-------|------|------|------|
| `claude-md-global` | Global CLAUDE.md | file | `templates/claude-md-global.md` | `claude-code`, `bootstrap`, `markdown` |
| `claude-md-project` | Project CLAUDE.md | file | `templates/claude-md-project.md` | `claude-code`, `bootstrap`, `markdown`, `project` |
| `settings-local-project` | Project settings.local.json | file | `templates/settings-local-project.json` | `claude-code`, `bootstrap`, `json`, `permissions` |
| `ontology-scaffold` | Ontology scaffold | directory | `templates/ontology-scaffold` | `claude-code`, `ontology`, `scaffold`, `directory` |
| `research-paper-starter-pack` | Research paper starter pack | directory | `templates/research-paper-starter-pack` | `quarto`, `manuscript`, `research`, `directory` |

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
