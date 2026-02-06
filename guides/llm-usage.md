# Using This Repository with an LLM

This repository provides context files, references, and templates for LLM-assisted work across multiple tools.

---

## Which Tool, Which Approach

| Tool | Setup |
|------|-------|
| **Claude Code** (CLI) | Uses `CLAUDE.md` files automatically. See [claude-code-setup.md](claude-code-setup.md). |
| **Copilot / ChatGPT** (chat) | Paste the preamble from [copilot-primer.md](copilot-primer.md), then paste your code or txtarchive. |
| **Any LLM** (general) | Attach or paste the relevant files from this repo as context. Follow the diff-first workflow below. |

---

## What's Inside (Intended for LLM Context)

- **Quarto skill reference** ([`skills/quarto-skill.md`](../skills/quarto-skill.md)) -- comprehensive Quarto authoring guide. Load this when you need help with rendering, formatting, cross-refs, or journal workflows.
- **Quarto cheatsheet** ([`cheatsheets/quarto_llm_cheatsheet.qmd`](../cheatsheets/quarto_llm_cheatsheet.qmd)) -- compact rendered reference covering core Quarto syntax.
- **Research paper starter pack** ([`templates/research-paper-starter-pack/`](../templates/research-paper-starter-pack/)) -- manuscript scaffold wired for DOCX/PDF and CSL/BibTeX.
- **Claude Code templates** ([`templates/`](../templates/)) -- starter `CLAUDE.md` and `settings.local.json` files.

---

## "Project Instructions" to Paste at the Start of an LLM Session

Copy this block into the system or first user message.

```text
You are assisting with data analysis and document authoring.
Rules:
- Use ONLY the attached files plus official documentation if needed.
- For R code: use tidymodels (not caret), pacman::p_load(), event_level = "second".
- For Quarto: maintain valid YAML and Pandoc syntax. Assume Quarto >= 1.7.
- Preserve cross-references (@fig-*, @tbl-*, @sec-*) and citation keys (@citekey).
- Never invent references -- use only citations from the provided .bib file.
- Prefer minimal diffs. Show a unified diff for each change.
Output format for edits:
1) Short rationale (1-3 bullets)
2) Unified diff
3) Full updated file content ONLY if I request it
```

---

## Prompt Cookbook

### General Editing (Quarto)

- "In `_quarto.yml`, enable `embed-resources` for HTML and add a dark theme; keep PDF unchanged."
- "Add a callout 'Limitations' after the Discussion section; show a unified diff."

### Data Analysis (R / tidymodels)

- "Review the recipe in 310-Baseline.ipynb. Are there any preprocessing steps missing for a random forest?"
- "Add SHAP variable importance plots to 320-Tuned-RF.ipynb using kernelshap + shapviz."
- "Create a Table 1 using gtsummary::tbl_summary(), stratified by death_flag."

### Research Paper

- "Use `csl/new-england-journal-of-medicine.csl` and convert raw references into proper citekeys using `refs/library.bib`."
- "Create a `templates/journal-reference.docx` style map and adjust headings per IMRAD structure."

### Interactivity

- "Turn `analysis.qmd` into a browser-only interactive doc with Plotly; make it self-contained."
- "Convert `report.qmd` to Shiny: add `server: shiny`, a slider input, and rendered plot."

### Citations & Zotero

- "Wire Zotero via Better BibTeX: assume `refs/library.bib` is kept updated. Replace author-year mentions with `@citekey` syntax."

---

## Edit Workflow (Diff-First)

1. **You**: request a change (file + intent).
2. **LLM**: returns a **unified diff** (plus a brief rationale).
3. **You**: approve or refine.
4. **LLM**: provides the updated file content (or you apply the diff).
5. **You**: render locally and commit.

> This keeps changes auditable and reduces the chance of the LLM silently breaking something.

---

## Conventions

- Quarto version >= 1.7.
- **Citations**: CSL + `.bib`, with `link-citations: true`.
- **Labels**: `fig-`, `tbl-`, `eq-`, `sec-` prefixes; reference with `@label`.
- **R code**: tidymodels ecosystem, `event_level = "second"`, `pacman::p_load()`.
- **Analysis files**: NNN-Description naming (see [copilot-primer.md](copilot-primer.md) for the numbering scheme).
- **Accessibility**: add `fig-alt` text and meaningful `tbl-cap` captions.

---

## Repository Layout

```
llmcheatsheets/
├── guides/                  # This file, Claude Code setup, Copilot primer
├── skills/                  # Quarto skill reference
├── cheatsheets/             # Rendered Quarto cheatsheet (.qmd + .html)
├── templates/               # Starter files (CLAUDE.md, settings.json, paper scaffold)
├── scripts/                 # CI helper scripts
├── .github/workflows/       # GitHub Actions (renders cheatsheet on push)
└── local_quarto_check.sh    # Local render validation
```

---

## Limitations & Responsibilities

- LLMs can **hallucinate** syntax or options. Always validate with `quarto render` + preview.
- For clinical/PHI content, **do not commit sensitive data**. Use mock or de-identified examples.
- If you change journals, update the CSL and reference-doc and re-render.
