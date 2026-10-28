# Quarto Kit Skill

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer) or paste into an LLM session when listing, installing, or expanding templates from this repo's catalog.

This skill consumes the **same source of truth** as the CLI (`scripts/qk`):

| Artifact | Role |
|----------|------|
| [`catalog/templates.yaml`](../catalog/templates.yaml) | Source of truth (edit via PR) |
| [`catalog/TEMPLATES.md`](../catalog/TEMPLATES.md) | Generated human-readable catalog |
| [`scripts/qk`](../scripts/qk) | CLI mirroring these operations |
| [`catalog/drafts/`](../catalog/drafts/) | Human-review-only candidate drafts |

**Do not hardcode the template inventory in this skill.** Always load `catalog/templates.yaml` (or run `python3 scripts/qk list` / `show`).

Licenses: documentation CC BY-SA 4.0 (`LICENSE`); code MIT (`LICENSE-CODE`). **No PHI** in templates, drafts, or installs.

---

## 1) Goals

1. Document what templates this repo includes in a reviewable, PR-friendly source.
2. Keep that source expandable without forking the skill or CLI inventory.
3. Offer both a CLI and an agent skill that share the YAML catalog.
4. Optionally propose candidates from [awesome-quarto](https://github.com/mcanouil/awesome-quarto) for **human review only** (never auto-merge into `templates.yaml`).

---

## 2) Load the catalog (required)

Before answering inventory questions:

```bash
python3 scripts/qk list
python3 scripts/qk list --tag quarto
python3 scripts/qk show <id>
```

Or read `catalog/templates.yaml` directly. Each entry has:

- `id`, `title`, `description`, `tags`, `kind`, `when_to_use`
- `kind: file` | `directory` — a template stored in this repo; has `path`.
- `kind: extension-project-type` — a Quarto project type contributed by an upstream extension; no `path`. Has `install` (`quarto add owner/repo[@ref]`), `project_type` (value for `project: type:`), `min_quarto`, `source`, and optionally `base_type`, `docs`, `usage` (minimal `_quarto.yml`), `notes` (caveats such as list settings that stack and cannot be removed, and the upstream update policy).
- `kind: typst-package` — a Typst Universe package used via `#import` in a `.typ` file or a Quarto `format: typst` document; no `path`, nothing installed (Typst downloads it on first compile). Has `import` (exact `#import "@preview/name:X.Y.Z": ...` line), `version` (must match the import), `min_typst` (the package `typst.toml` `compiler` value), `source`, and optionally `docs`, `usage` (minimal Typst example), `notes`. `qk check` compares local Typst (`typst` or `$QK_TYPST`) with `min_typst`, warn-only unless `--require-typst`; `--skip-typst` turns it off.

The field reference lives in the header comment of `catalog/templates.yaml`.

If YAML and `catalog/TEMPLATES.md` disagree, trust YAML and run `python3 scripts/qk update-docs`, then fix via PR.

---

## 3) Operations (mirror CLI)

### List

```bash
python3 scripts/qk list
python3 scripts/qk list --tag claude-code
```

### Show

```bash
python3 scripts/qk show ontology-scaffold
```

### Install

Copy a catalog entry to a destination. **Refuses overwrite unless `--force`.**

```bash
python3 scripts/qk install claude-md-project ./CLAUDE.md
python3 scripts/qk install settings-local-project ./.claude/settings.local.json
python3 scripts/qk install ontology-scaffold ./.claude-ontology-scaffold
python3 scripts/qk install research-paper-starter-pack /tmp/demo
python3 scripts/qk install research-paper-starter-pack /tmp/demo --force   # overwrite
```

Agent rule: if the destination exists, stop and ask before using `--force`.

For `kind: extension-project-type`, `dest` is the Quarto project directory (default: cwd) and install runs the entry's `quarto add` command there (adds `_extensions/`, which should be committed). It refuses if Quarto is missing or older than `min_quarto` (`--force` overrides the version check only).

```bash
python3 scripts/qk install <extension-id> ./my-site --dry-run    # print the command only
python3 scripts/qk install <extension-id> ./my-site               # run quarto add
python3 scripts/qk install <extension-id> ./my-site --ref 1.2.3   # pin a release
```

Afterwards, set `project: type: <project_type>` in `_quarto.yml` using the entry's `usage` (`qk show <id>`), and pass on its `notes`.

### Check / update docs

```bash
python3 scripts/qk check                   # fails if TEMPLATES.md out of sync or paths/fields missing
python3 scripts/qk check --require-quarto  # also fails if local Quarto is missing or < any min_quarto
python3 scripts/qk update-docs             # regenerate catalog/TEMPLATES.md from YAML
```

`check` always reports the local Quarto version against each entry's `min_quarto`; without `--require-quarto` a missing or old Quarto is only a warning (CI has no Quarto). Set `QK_QUARTO=/path/to/quarto` to point at a specific binary.

### Import candidates (draft only)

```bash
python3 scripts/qk import-candidates
# writes catalog/drafts/awesome-quarto-candidates-<UTC>.md
```

Never promote draft stubs into `templates.yaml` without an explicit human request and a PR.

---

## 4) Expand the catalog (PR workflow)

1. Add or edit an entry in `catalog/templates.yaml`.
2. For `file`/`directory`, ensure `path` exists under `templates/`. For `typst-package`, copy `version` and `min_typst` (`compiler`) from the package's `typst.toml` on Typst Universe (github.com/typst/packages, `packages/preview/<name>/<version>/typst.toml`) and compile the `usage` example with Typst before proposing. For `extension-project-type`, fill `install`, `project_type`, `min_quarto` (from the extension's `_extension.yml` `quarto-required`), and `source` from the upstream repo — verify them there, don't guess.
3. Run `python3 scripts/qk update-docs`.
4. Run `python3 scripts/qk check`.
5. Open a PR describing the template, tags, and when_to_use.
6. CI runs `scripts/qk check` — must pass before merge.

For external ideas (e.g. awesome-quarto):

1. `python3 scripts/qk import-candidates`
2. Human reviews `catalog/drafts/...`
3. Selected items get real template paths + a PR into `templates.yaml`
4. **Never auto-merge** drafts

---

## 5) Agent playbook

When the user asks what templates exist:

1. Load catalog (CLI or YAML) — do not recite a memorized list.
2. Filter by tag or `when_to_use` if they described a goal.
3. Recommend an `id` and show install command.

When installing:

1. Confirm destination.
2. Run `install` without `--force` first.
3. On refuse-overwrite error, report and wait.

When expanding:

1. Draft YAML stub.
2. Remind them to run `update-docs` + `check` + PR.
3. Point at licenses and PHI rule.

---

## 6) Quick reference

| Need | Command |
|------|---------|
| Inventory | `python3 scripts/qk list` |
| Details | `python3 scripts/qk show <id>` |
| Copy template | `python3 scripts/qk install <id> [dest] [--force]` |
| Add extension project type | `python3 scripts/qk install <id> [project-dir] [--dry-run] [--ref REF]` |
| Validate | `python3 scripts/qk check [--require-quarto]` |
| Regen docs | `python3 scripts/qk update-docs` |
| External drafts | `python3 scripts/qk import-candidates` |
