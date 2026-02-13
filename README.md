# LLM Cheatsheets & Reference Library

Guides, templates, and cheatsheets for working with LLMs on data analysis, Quarto authoring, and Claude Code configuration. This repo is both a reference library and a bootstrapping toolkit for new or existing projects.

---

## What's Here

| Directory | Contents |
|-----------|----------|
| [`guides/`](guides/) | Claude Code setup, architecture review, Copilot primer, LLM usage patterns, ontology website pattern |
| [`skills/`](skills/) | Skill references: Quarto authoring, txtarchive workflows, ontology website builder (load into an LLM) |
| [`cheatsheets/`](cheatsheets/) | Rendered Quarto cheatsheet (HTML) |
| [`templates/`](templates/) | Starter files for CLAUDE.md, settings.local.json, research papers |
| [`scripts/`](scripts/) | CI helper scripts |

---

## Bootstrap a New Project

Use this checklist when starting a new project or upgrading an older one.

### Step 1: Create `.claude/` directory

```bash
mkdir -p myproject/.claude/rules
```

### Step 2: Add permissions

```bash
cp llmcheatsheets/templates/settings-local-project.json myproject/.claude/settings.local.json
# Edit to match the project (R, Python, or minimal)
```

See [`guides/claude-code-setup.md` Section 4](guides/claude-code-setup.md) for permission patterns by project type.

### Step 3: Create CLAUDE.md

```bash
cp llmcheatsheets/templates/claude-md-project.md myproject/CLAUDE.md
# Fill in: project overview, data sources, key outcome, analysis progression
```

Start small. A CLAUDE.md only needs to answer: *What is this project? What data does it use? What are we trying to do?*

### Step 4: Add rules files (when the project grows)

As the project matures, extract reference material from CLAUDE.md into `.claude/rules/`:

| File | Purpose | Add When |
|------|---------|----------|
| `data-dictionary.md` | Dataset schemas, field definitions | You have complex data |
| `coding-standards.md` | Language-specific patterns | You have conventions to enforce |
| `domain-constraints.md` | Domain invariants | Your domain has hard rules |
| `assumption-registry.md` | Explicit assumptions | You're making analytical claims |
| `validation-gates.md` | Review criteria | Work needs structured review |

**Rule of thumb:** If you'd Ctrl-F for it rather than reading it every time, it belongs in `rules/`, not CLAUDE.md.

**Private content:** Some rules files (career context, proprietary data dictionaries, org-specific constraints) should NOT be committed. Add them to `.gitignore`:

```gitignore
.claude/rules/career.md
.claude/rules/proprietary-*.md
.claude/settings.local.json
```

See [`guides/claude-code-setup.md` Section 5](guides/claude-code-setup.md) for details on what to keep private.

### Step 5: Verify

```bash
cd myproject
claude
# Ask: "What context do you see from CLAUDE.md?"
# Verify it loaded both global and project context.
```

### Reference implementations

| Project | Complexity | What It Demonstrates |
|---------|-----------|---------------------|
| `llmcheatsheets/` | Minimal | Short CLAUDE.md, no rules, CI only |
| `lhn/` | Medium | Knowledge graph navigation, YAML ontology, domain entry points |
| Knowledge Vault (see [guide](guides/knowledge-vault.md)) | Full | 5 rules files, mode selection, authority scoring, agent operations, LLM boundary |

---

## Fix an Older Project

Older projects may have configuration that pre-dates current Claude Code features. Common issues:

### `.claude/context/` does not auto-load

**Problem:** `.claude/context/` is not a Claude Code feature. Files there are invisible to Claude.

**Fix:**
```bash
mkdir -p myproject/.claude/rules
mv myproject/.claude/context/* myproject/.claude/rules/
rmdir myproject/.claude/context
# Update any references in CLAUDE.md from context/ to rules/
```

### CLAUDE.md is too large

**Problem:** CLAUDE.md over ~300 lines consumes context window with reference material irrelevant to the current task.

**Fix:**
1. Move data dictionaries, code recipes, and checklists to `.claude/rules/`
2. Keep only decisions, conventions, priorities, and invariants in CLAUDE.md
3. Add pointers: `See rules/feature-dictionary.md for full schema.`

### No `.claude/rules/` directory

**Problem:** All context is in CLAUDE.md or not documented at all.

**Fix:** Follow the architecture review guide's Phase 1a roadmap:
1. Create `.claude/rules/`
2. Extract reference material from CLAUDE.md
3. Slim CLAUDE.md to ~200-300 lines of rules

See [`guides/claude-code-architecture-review.md` Section 6](guides/claude-code-architecture-review.md) for the full roadmap.

### Stale memory files

**Problem:** `~/.claude/projects/<path>/memory/MEMORY.md` contains outdated information.

**Fix:** Open the file, review, and edit. Memory files are plain markdown.
```bash
ls ~/.claude/projects/
# Find the encoded path for your project, then edit MEMORY.md
```

---

## What Claude Code Auto-Loads

Every session, Claude Code automatically loads these files (in order):

| Source | Loaded | Notes |
|--------|--------|-------|
| `~/projects/CLAUDE.md` | Always (if working under ~/projects/) | Global cross-project context |
| `./CLAUDE.md` | Always | Project-specific context |
| `./.claude/CLAUDE.md` | Always (alternative location) | Same as above |
| `./CLAUDE.local.md` | Always | Personal project-local preferences |
| `./.claude/rules/*.md` | Always (recursive) | All markdown files, auto-discovered |
| `~/.claude/CLAUDE.md` | Always | Personal user preferences |
| `MEMORY.md` | Always | First 200 lines only |

**Not auto-loaded:** `.claude/context/`, `.claude/settings.local.json` content (permissions only, not instructions), files in `docs/` or other directories.

---

## Quick Start Guides

### New Machine Setup (Claude Code)

1. Install Claude Code and authenticate.
2. Copy [`templates/claude-md-global.md`](templates/claude-md-global.md) to `~/projects/CLAUDE.md` and fill in your paths.
3. Copy [`templates/settings-local-project.json`](templates/settings-local-project.json) to each project's `.claude/settings.local.json`.
4. Full walkthrough: [`guides/claude-code-setup.md`](guides/claude-code-setup.md)

### Copilot / ChatGPT Session

1. Copy the PREAMBLE block from [`guides/copilot-primer.md`](guides/copilot-primer.md).
2. Paste it as the first message in your chat session.
3. Attach or paste your txtarchive file as the second message.

### Quarto Help

- **Comprehensive reference:** [`skills/quarto-skill.md`](skills/quarto-skill.md) -- load into Claude Code or paste into an LLM session.
- **Rendered cheatsheet:** [`cheatsheets/quarto_llm_cheatsheet.html`](cheatsheets/quarto_llm_cheatsheet.html) -- open in a browser.
- **LLM workflow guide:** [`guides/llm-usage.md`](guides/llm-usage.md) -- diff-first editing patterns and prompt cookbook.

### TxtArchive (LLM-Friendly Code Archives)

- **Skill reference:** [`skills/txtarchive-skill.md`](skills/txtarchive-skill.md) -- load into an LLM for help creating, unpacking, and round-tripping notebooks.
- **Key workflow:** LLM writes plain-text cell markers, `extract-notebooks` produces valid `.ipynb` files.

### Ontology-Organized Website (Quarto)

- **Skill reference:** [`skills/quarto-ontology-website-skill.md`](skills/quarto-ontology-website-skill.md) -- load into an LLM to build a typed personal website with Quarto.
- **Conceptual guide:** [`guides/quarto-ontology-website.md`](guides/quarto-ontology-website.md) -- explains the pattern and how to adapt it.
- **Key idea:** Every page has a `node-type` in its front matter. Relationships are YAML metadata. Listings auto-generate. Schema variants for developers, researchers, consultants, artists.

### Research Papers

Start from [`templates/research-paper-starter-pack/`](templates/research-paper-starter-pack/) -- a Quarto manuscript scaffold wired for DOCX/PDF with CSL and BibTeX.

### Architecture Review (Ontology-Driven Configuration)

- **Guide:** [`guides/claude-code-architecture-review.md`](guides/claude-code-architecture-review.md) -- maps Claude Code config layers to a typed reasoning architecture.
- **When to use:** When a project grows beyond a simple CLAUDE.md and needs structured constraints, assumption tracking, validation gates, or mode selection.
- **Worked example:** The [Knowledge Vault](guides/knowledge-vault.md) demonstrates the full pattern with 5 rules files, mode selection, and LLM boundary.

---

## Licenses

- Documentation: CC BY-SA 4.0 (derives from the Quarto cheatsheet by Posit). See [LICENSE](LICENSE).
- Code and workflows: MIT. See [LICENSE-CODE](LICENSE-CODE).
- Journal CSL files retain their original licenses.

## PHI

Do not commit PHI. Use mock or de-identified data only.
