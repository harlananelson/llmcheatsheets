# Grok subagents + SCDC provenance for agentic DAG work

Grok (xAI) is not a replacement for Anthropic's computer use and Artifacts. It is the orchestration and verification layer that makes agentic work reliable when your actual deliverables live in a targets-based pipeline with explicit data-design decisions, provenance, and schema contracts.

This pattern is battle-tested in projects like SCDCernerProject and translates directly because Grok reads the same `CLAUDE.md` / `.claude/` rules that power rigorous setups.

## Why Grok for the "lens" when agents do the "hands"

Anthropic agents (2026 computer use, dynamic workflows, persistent Artifacts that can call models) are excellent at sustained execution: reading screens, editing files, running commands across a codebase or data pipeline, proposing tar_target changes, or inspecting schemas.

They are weaker at:
- Maintaining live provenance across steps
- Parallel verification of assumptions and live state
- Staying strictly within project-specific rules and decision registries without drift

Grok fills exactly that gap with native support for:
- **Subagents**: Spawn specialized collaborators (`explorer` for mapping a `_targets.R` + schema touchpoints, `reviewer` for cross-checking the data-design-decisions registry, another for recent Anthropic computer-use patterns via web search).
- **`todo_write`**: Treat this as your working copy of the provenance surface. Mirror the project's `DATA-DESIGN-DECISIONS.md` format with tags (`llm_proposed`, `human_reviewed`, `PI_directed`).
- **Plan mode**: Safe read-only exploration of the DAG, shared packages, or schemas before any agent takes action.
- **Tool use + CLAUDE.md compatibility**: Direct terminal access (`tar_visnetwork`, schema greps), file ops, and automatic inheritance of every validation gate, assumption registry, and code-reuse rule from your project rules.

## Practical workflow (Grok orchestrates, Anthropic executes)

1. **Start in plan mode** (Grok): Point at the lineage-graph worktree or current `_targets.R`. Ask it to map relevant targets and schema contracts that would be touched by a proposed change (e.g., adding a `complete_history_flag` join).

2. **Use subagents + todo** (Grok): Break the task into verifiable steps that match your project's rigor:
   - Explorer subagent reads the manifest and live table definitions.
   - Reviewer subagent checks against the DD- registry and generated `api_reference.md` for any shared extract packages.
   - Maintain a `todo_write` list that becomes the draft registry entry.

3. **Hand off execution** (Anthropic computer use / Artifact): "Use the screen and terminal to implement the proposed tar_target change and run a dry validation." The agent does the clicking/typing.

4. **Close the loop** (Grok + human): Grok (or you) generates the exact human verification commands that must be run before the change is permanent:
   - `tar_visnetwork()`
   - Schema spot-check + row counts vs previous manifest
   - Update the real `DATA-DESIGN-DECISIONS.md` with the provenance tag

5. **Multi-model guard**: Run a quick cross-check (Grok orchestration + Anthropic output review) against the latest known computer-use gotchas.

Nothing lands in the DAG or decision log without the human having executed the verification the registry requires.

## Concrete example (adapted from SCDCernerProject patterns)

**Context**: You have a targets pipeline with raw extracts, feature layers, and ML/survival targets. A colleague (or agent) wants to add a care-source completeness flag for longitudinal filtering.

**Grok-orchestrated record** (this becomes the DD- entry or PR description):

```
DD-32 (proposed via Grok subagents + Anthropic computer use)
Decision: Add `complete_history_flag` join + derived flag to ads_with_features for "IUH has full picture" filtering.
Applies to: NEW pipeline survival/ML cohorts (population 2+), any analysis requiring complete longitudinal history.
Data: ads_raw + CohortBuilder_PatientCareSource (via Cerner_PersonID crosswalk), column complete_history_flag.
Provenance: llm_proposed (Grok explorer + Anthropic computer-use inspection of _targets.R + schema view) + human_reviewed 2026-06-06. Verified against data-design registry and shared API contracts.
Verification commands (must run before merge):
  R -e 'targets::tar_visnetwork(); targets::tar_manifest() |> filter(grepl("ads|care_source", name))'
  R -e 'tar_load(ads_with_features); ads_with_features |> count(complete_history) |> glimpse()'
  # + manual spot-check of 3 rows against source extract + confirm no row-count explosion
Update api_reference.md if any shared extract logic changed.
```

The agent can propose and even execute the visible edit. Grok + your rules ensure the provenance, the verification steps, and the gate ("does this match the recorded decision and the live schema?") are never skipped.

## How this fits the broader 2026 picture

- Anthropic's strengths (computer use for real screen/app control, Artifacts that persist state and can call models, dynamic parallel workflows) give you tireless hands.
- Grok's strengths (subagents, structured todos, plan mode, first-class tool use, and seamless CLAUDE.md / .claude/ rule inheritance) give you reliable framing and auditability.
- SCDCernerProject-style artifacts (targets DAG for lineage, explicit data-design-decision registry with provenance, 100% documented shared package APIs, validation gates) give you the durable contract that survives model changes and team handoffs.

Use the right tool for the right part of the work. Keep the human at the provenance and verification layer. The next run of the pipeline (or the next person reading the registry) will thank you.

## Copyable starting points

- Add a `Grok` section to your project `CLAUDE.md` that explicitly calls out subagent usage for pipeline changes and the requirement to update the data-design registry.
- Create a reusable "Grok orchestration skill" (or prompt template) that forces a todo list + verification commands before handing execution to an Anthropic agent.
- When reviewing agent output on a DAG or schema change, always require the exact human-run verification commands to be listed and executed.

This is the meta-thinker pattern at scale: the agents do the work, Grok helps you stay in control of the framing and the permanent record.