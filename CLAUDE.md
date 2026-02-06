# llmcheatsheets

LLM reference library: guides, skills, cheatsheets, and templates.

## Repo Structure

```
guides/                  # Markdown guides (Claude Code setup, Copilot primer, LLM usage)
skills/                  # Skill files loaded into LLMs (quarto-skill.md, txtarchive-skill.md)
cheatsheets/             # Rendered Quarto cheatsheet (.qmd + .html + support files)
templates/               # Starter files (CLAUDE.md, settings.json, research paper scaffold)
scripts/                 # CI helper scripts (ci_trigger, ci_logs, ci_tail, ci_wait_and_fetch)
.github/workflows/       # render.yml -- renders cheatsheet on push to main
```

## Editing Conventions

- Markdown files: no hard line wrapping (one paragraph per line).
- Template placeholders use `{PLACEHOLDER_NAME}` syntax (all caps, curly braces).
- Keep guides self-contained -- each should be readable without the others.

## CI

- `render.yml` renders `cheatsheets/quarto_llm_cheatsheet.qmd` to HTML on every push to main.
- Validate locally with `./local_quarto_check.sh` before pushing.
- CI helpers in `scripts/` (ci_trigger.sh, ci_logs.sh, ci_tail.sh, ci_wait_and_fetch.sh).
