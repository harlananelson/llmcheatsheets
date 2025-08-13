# LLM-Friendly Quarto Cheatsheets & Starters

This repo is a compact set of **LLM-friendly references and templates** for writing Quarto docs (reports, papers, books) and running a **diff-first edit loop** with an LLM.

## What’s here
- `quarto_llm_cheatsheet.qmd` – copy-pastable reference for CLI, YAML, figures/tables, cross-refs, citations, books, interactive docs, and journal workflows.
- `research-paper-starter-pack/` – a ready-to-render manuscript scaffold (DOCX/PDF; CSL/BibTeX wired).
- `LLM_USAGE.md` – how to load this repo as context for an LLM and run a **diff-first** editorial loop.

## Quick start
1. Clone the repo.
2. Open `LLM_USAGE.md` and follow the “Project instructions” block when starting an LLM session.
3. For papers, start in `research-paper-starter-pack/`, add your CSL + Word reference doc, then:
   ```bash
   quarto render --to docx
   # optional:
   # quarto render --to pdf

Attribution & licenses
	•	This repo’s documentation is intended for CC BY-SA 4.0 licensing, as it derives concepts/examples from the Quarto cheatsheet published by Posit (Quarto 1.7, updated 2025-07). See LICENSE.
	•	Any code/workflows in this repo may be licensed under MIT (see LICENSE-CODE).
	•	Journal CSL files retain their original licenses—keep the headers in each .csl file intact.

PHI / IRB

Do not commit PHI. Use mock or de-identified data. Keep references in refs/ and styles in csl/ under version control.

Links
	•	Cheatsheet: quarto_llm_cheatsheet.qmd
	•	Starter: research-paper-starter-pack/
	•	LLM guide: LLM_USAGE.md
