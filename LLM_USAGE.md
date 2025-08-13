# Using This Repository with an LLM (for Quarto authoring & review)

This public repository is designed to be **project information for an LLM** that helps you **write, edit, and understand Quarto documents** (articles, books, interactive docs, journal submissions). You can paste/link these materials into your LLM session or attach them so the model has immediate, accurate context.

------------------------------------------------------------------------

## What’s inside (intended for LLM context)

-   **Quarto LLM‑friendly Cheatsheet** – a compact reference for CLI, YAML, execution options, figures, tables, cross‑refs, citations, shortcodes, books, interactive docs, and journal workflows.
-   **Research Paper Starter Pack** – a ready‑to‑render manuscript scaffold (folders for `refs/`, `csl/`, `templates/`, `sections/`) wired for DOCX/PDF and CSL/BibTeX citations.
-   **How‑tos** – sections on Quarto Books, Journal Templates (e.g., NEJM), Zotero + footnotes/bibliography, and interactive documents (R‑server vs. browser‑only).

> Tip: Keep this repo **cohesive and minimal** so the LLM can scan it quickly. Link out to large datasets instead of committing them.

------------------------------------------------------------------------

## How to use this repo with an LLM

1.  **Attach or link** the files the LLM should rely on (cheatsheet, starter pack, your `.qmd` files, `_quarto.yml`, `manuscript.yml`, `refs/*.bib`, `csl/*.csl`).\
2.  **Tell the LLM to prioritize repo content** over web results, and to cite official Quarto docs for anything not found here.\
3.  When asking for edits, **name the file(s)** and the **exact change** you want. Prefer an **edit‑loop** with diffs (see below).\
4.  **Render locally** with `quarto render` to validate output. Never assume the LLM’s output compiles until you render.

------------------------------------------------------------------------

## “Project instructions” you can paste at the start of an LLM session

Copy this into the system or first user message, then attach/link this repo.

``` text
You are my Quarto assistant. Use ONLY the files in this repository plus official Quarto docs if needed.
Rules for edits:
- Maintain valid YAML and Pandoc/Quarto syntax.
- Prefer minimal diffs and show a unified diff for each change.
- Preserve semantics, labels, and cross-references; do not break @fig-*, @tbl-*, or section anchors.
- For citations, use my bibliography (.bib) and CSL; never invent references.
- For journal workflows, follow my templates/reference-doc and only change styles if I ask.
- When referencing features, cite the specific Quarto docs page/section.
- Assume Quarto >= 1.7.
Output format for edits:
1) Short rationale (1–3 bullets)
2) Unified diff
3) The updated file content (ONLY if I ask for full content)
```

------------------------------------------------------------------------

## Prompt cookbook (examples)

### General editing

-   “Open `index.qmd` and add a callout ‘Limitations’ after the Discussion; show a unified diff.”
-   “In `_quarto.yml`, enable `embed-resources` for HTML and add a dark theme; keep PDF unchanged.”

### Research paper (NEJM‑like)

-   “Use `csl/new-england-journal-of-medicine.csl` and ensure `link-citations: true`. Convert raw references in `sections/02-methods.qmd` into proper citekeys using `refs/library.bib`.”
-   “Create a `templates/journal-reference.docx` style map and adjust headings per standard IMRAD structure.”

### Books

-   “Create `_quarto.yml` with `project: type: book`, list chapters in `book: chapters:`, and add cross‑refs and a PDF index.”

### Interactivity

-   “Turn `analysis.qmd` into a browser‑only interactive doc: replace R plots with Plotly or OJS cells; make the HTML self‑contained with `embed-resources: true`.”
-   “Convert `report.qmd` to Shiny (server‑backed): add `server: shiny`, a slider input, and rendered plot chunk; show the diff.”

### Citations & Zotero

-   “Wire Zotero via Better BibTeX: assume `refs/library.bib` is kept updated. Replace author‑year mentions with `@citekey` syntax and add any missing entries.”

------------------------------------------------------------------------

## Edit workflow (diff‑first)

1.  **You**: request a change (file + intent).\
2.  **LLM**: returns a **unified diff** (plus a brief rationale).\
3.  **You**: approve or refine.\
4.  **LLM**: provides the updated file content (or you apply the diff).\
5.  **You**: run `quarto render` locally and commit.

> This keeps changes auditable and reduces the chance of the LLM silently breaking something.

------------------------------------------------------------------------

## Conventions this repo expects

-   Quarto version **\>= 1.7**.\
-   Prefer **DOCX** submissions with a `reference-doc`, plus **PDF** for visual checking.\
-   **Citations**: CSL + `.bib`, with `link-citations: true`.\
-   **Labels**: `fig-`, `tbl-`, `eq-`, `sec-` prefixes; cite with `@label`.\
-   **Interactivity**: choose **Shiny** (server) *or* **web (widgets/OJS/webR)** and document which one you use.\
-   **Accessibility**: add `fig-alt` text and meaningful `tbl-cap` captions.

------------------------------------------------------------------------

## Limitations & responsibilities

-   LLMs can **hallucinate** syntax or options. Validate with `quarto render` + preview.\
-   For clinical/PHI content, **do not commit sensitive data**. Keep the repo clean and use mock or de‑identified examples.\
-   If you change journals, update the **CSL** and **reference‑doc** and re‑render.

------------------------------------------------------------------------

## Repository layout (suggested)

```         
docs/        # LLM‑friendly guides (cheatsheet, this file)
starters/    # ready‑to‑use scaffolds
paper/       # your active manuscript (index.qmd, sections/, refs/, csl/, templates/)
extensions/  # custom Quarto extensions (e.g., journal styles, lua filters)
```

(You can adapt to your preferences; keep paths consistent with `_quarto.yml`.)

------------------------------------------------------------------------

## License & attribution

Include a LICENSE for this repository. If you reuse journal‑specific CSL or templates, respect their licenses and attribution requirements.

------------------------------------------------------------------------

## Quick start

1.  Clone this repo or copy the **Starter Pack** into a new project.\
2.  Drop your CSL and Word `reference-doc` into `csl/` and `templates/`.\
3.  Edit `manuscript.yml`, `index.qmd`, and `sections/*.qmd`.\
4.  Ask your LLM for targeted edits (diff‑first).\
5.  `quarto render --to docx` (and `--to pdf` if needed).

Happy writing!