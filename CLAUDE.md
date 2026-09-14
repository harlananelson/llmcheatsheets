# llmcheatsheets

## This repo IS the live gptserpa.com site ("GPT Sherpa")

When the user asks to "update the gptserpa site" (or gptserpa.com), **work in THIS repo** — not in `/projects/gptserpa`. This repo's `_quarto.yml` sets `site-url: https://gptserpa.com`, and the Netlify site (`gptserpa`, id `23e5f146-e332-470f-811e-cf245b659d04`) is connected to this GitHub repo: **push to main auto-deploys to gptserpa.com**.

The separate private `/projects/gptserpa` repo is a **drafting space only** — it is not deployed and must not be (its posts contain unsanitized project names). Content moving from there to here needs the private→public sanitizing pass (e.g., SCDCernerProject → ClinicalDataProject). Decided 2026-06-10.

- `advice/` holds the dated, opinionated advice posts (Quarto listing + RSS); the featured/current article also gets a card on `index.qmd` under "Latest advice".

## Repo Visibility: PUBLIC

This is a **public** repository. It must NOT contain:
- Personal project details or employer-specific information
- Employer/organization references (names, work emails, server names, workspace URLs)
- Databricks workspace IDs, PAT tokens, or internal infrastructure details
- Any PHI or clinical data references

All content should be **generic and reusable** by anyone. Use placeholder names (e.g., "Indiana University Health" -> `{INSTITUTION}`, server names -> `{SERVER}`) in templates. Examples should use generic affiliations or clearly fictional ones.

**Sister repo:** `AI` (private) contains employer-specific Claude Code + Databricks guides. Patterns proven there get generalized before landing here.

LLM reference library: guides, skills, cheatsheets, and templates.

## Repo Structure

```
guides/                  # Markdown guides (Claude Code setup, Copilot primer, LLM usage, ontology website)
skills/                  # Skill files loaded into LLMs (quarto-skill.qmd, txtarchive-skill.md, quarto-ontology-website-skill.md, quarto-kit-skill.md)
catalog/                 # Quarto kit template catalog: templates.yaml (source of truth) + generated TEMPLATES.md (`scripts/qk check` enforces sync)
cheatsheets/             # Rendered Quarto cheatsheet (.qmd + .html + support files)
templates/               # Starter files (CLAUDE.md, settings.json, research paper scaffold)
scripts/                 # CI helper scripts (ci_trigger, ci_logs, ci_tail, ci_wait_and_fetch)
.github/workflows/       # render.yml -- renders cheatsheet on push to main; catalog-check.yml -- runs scripts/qk check
```

## Editing Conventions

- Markdown files: no hard line wrapping (one paragraph per line).
- Template placeholders use `{PLACEHOLDER_NAME}` syntax (all caps, curly braces).
- Keep guides self-contained -- each should be readable without the others.

## Key Files for Cross-Project Impact

Changes to these files affect all projects (via global CLAUDE.md review-on-session-start):

- `guides/claude-code-setup.md` -- Configuration hierarchy, custom skills, custom agents, MCP connectors, new machine checklist
- `guides/claude-code-architecture-review.md` -- Ontology-driven project organization, tiered framework
- `skills/quarto-skill.qmd` -- Full Quarto reference. The condensed global skill `~/.claude/skills/quarto/SKILL.md` is a separate file maintained in `~/projects/AI/claude-config/skills/quarto/` (deployed by its `deploy.sh`) and points here for the full reference; keep the two consistent.
- `skills/txtarchive-skill.md` -- Full txtarchive reference. Same arrangement: the condensed global skill lives in `~/projects/AI/claude-config/skills/txtarchive/`.
- `skills/quarto-kit-skill.md` + `catalog/templates.yaml` + `scripts/qk` -- Quarto kit. Edit the YAML, then run `python3 scripts/qk update-docs && python3 scripts/qk check`; CI (`catalog-check.yml`) fails if `TEMPLATES.md` is out of sync.
- `templates/ontology-scaffold/` -- Level 1 project scaffolding templates

When updating these files, note that the global CLAUDE.md at `/projects/CLAUDE.md` instructs Claude to check for relevant updates here at session start.

## CI

- `render.yml` renders `cheatsheets/quarto_llm_cheatsheet.qmd` to HTML on every push to main.
- `catalog-check.yml` runs `python3 scripts/qk check` on every push and pull request.
- Workflow files cannot be pushed with the stored `gh` OAuth token (no `workflow` scope); push those commits over SSH: `git push git@github.com:harlananelson/llmcheatsheets.git main`.
- Validate locally with `./local_quarto_check.sh` before pushing.
- CI helpers in `scripts/` (ci_trigger.sh, ci_logs.sh, ci_tail.sh, ci_wait_and_fetch.sh).
