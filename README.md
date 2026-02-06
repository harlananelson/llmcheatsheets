# LLM Cheatsheets & Reference Library

Guides, templates, and cheatsheets for working with LLMs on data analysis, Quarto authoring, and Claude Code configuration.

---

## What's Here

| Directory | Contents |
|-----------|----------|
| [`guides/`](guides/) | Claude Code setup guide, Copilot analysis primer, LLM usage patterns |
| [`skills/`](skills/) | Skill references: Quarto authoring, txtarchive workflows (load into an LLM) |
| [`cheatsheets/`](cheatsheets/) | Rendered Quarto cheatsheet (HTML) |
| [`templates/`](templates/) | Starter files for CLAUDE.md, settings.local.json, research papers |
| [`scripts/`](scripts/) | CI helper scripts |

---

## Quick Start

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

### Research Papers

Start from [`templates/research-paper-starter-pack/`](templates/research-paper-starter-pack/) -- a Quarto manuscript scaffold wired for DOCX/PDF with CSL and BibTeX.

---

## Licenses

- Documentation: CC BY-SA 4.0 (derives from the Quarto cheatsheet by Posit). See [LICENSE](LICENSE).
- Code and workflows: MIT. See [LICENSE-CODE](LICENSE-CODE).
- Journal CSL files retain their original licenses.

## PHI

Do not commit PHI. Use mock or de-identified data only.
