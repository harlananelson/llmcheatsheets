# Grok Build subagents + provenance for agentic data pipelines

> **Updated 2026-06-10.** This guide originally described "Grok" generically. The product is **Grok Build** — xAI's terminal coding agent (beta May 2026, powered by the coding-specialized `grok-build-0.1` model). Facts below are corrected against xAI's documentation (docs.x.ai).

Grok Build is not a replacement for Claude Code, computer use, or Artifacts. It is a second orchestration and verification layer that makes agentic work more reliable when your actual deliverables live in a targets-based pipeline with explicit data-design decisions, provenance, and schema contracts.

This pattern is battle-tested in projects like ClinicalDataProject and translates directly because Grok Build reads the same `CLAUDE.md` / `.claude/` rules that power rigorous setups — officially and with zero configuration.

## What Grok Build actually provides (verified)

- **Zero-config Claude Code compatibility**: per xAI's docs, Grok Build *"automatically reads Claude Code marketplaces, plugins, skills, MCPs, agents, hooks, and instruction files"* — `CLAUDE.md`, `CLAUDE.local.md`, and `.claude/rules/`. Its own native convention is the `AGENTS.md` family (walked from cwd to repo root) plus a `.grok/` config directory. There is no GROK.md. Run `grok inspect` to see exactly which config sources, skills, and MCP servers a session loaded.
- **Typed parallel subagents**: `spawn_subagent` launches general-purpose, explore, or plan subagents that run concurrently, with git worktree isolation so parallel edits cannot collide, plus orchestration primitives to wait on or kill them.
- **`todo_write`**: same semantics as Claude Code's TodoWrite — exactly one item in-progress at a time, completions marked immediately, list reseeded after context compaction.
- **Plan mode**: `enter_plan_mode` gives a read-only exploration phase — write tools are blocked except the session plan file. You approve, comment on individual steps, or rewrite the plan before execution; post-approval changes surface as reviewable diffs.
- **Full tool orchestration**: terminal (`run_terminal_command`), file ops (`read_file`, `search_replace`, `write`, `grep`), web (`web_search`, `web_fetch`), and MCP discovery/invocation.

## Why a second agent for the "lens" when one already does the "hands"

Claude's agentic surfaces (computer use in the CLI, dynamic workflows running parallel subagent fleets, persistent Artifacts that can call models) are excellent at sustained execution: reading screens, editing files, running commands across a codebase or data pipeline, proposing tar_target changes, or inspecting schemas.

What a single agent cannot give you is **independence**. A reviewer that shares no weights, no training quirks, and no session state with the proposer catches a different class of error than a same-model self-review. Because Grok Build reads the same project rules, the cross-vendor review happens under the same contract:

- **Subagents**: spawn specialized collaborators (an explore subagent for mapping a `_targets.R` + schema touchpoints, another for cross-checking the data-design-decisions registry, another for recent agentic-pattern gotchas via web search).
- **`todo_write`**: treat this as your working copy of the provenance surface. Mirror the project's `DATA-DESIGN-DECISIONS.md` format with tags (`llm_proposed`, `human_reviewed`, `PI_directed`).
- **Plan mode**: safe read-only exploration of the DAG, shared packages, or schemas before any agent takes action.
- **Rule inheritance**: every validation gate, assumption registry, and code-reuse rule in your `CLAUDE.md` / `.claude/rules/` applies to both vendors automatically. No copy-paste, no drift.

## Practical workflow (one agent executes, the other reviews)

1. **Start in plan mode** (Grok Build): point at the lineage-graph worktree or current `_targets.R`. Ask it to map relevant targets and schema contracts that would be touched by a proposed change (e.g., adding a `complete_history_flag` join).

2. **Use subagents + todo** (Grok Build): break the task into verifiable steps that match your project's rigor:
   - An explore subagent reads the manifest and live table definitions.
   - A second subagent checks against the DD- registry and generated `api_reference.md` for any shared extract packages.
   - Maintain a `todo_write` list that becomes the draft registry entry.

3. **Hand off execution** (Claude Code / computer use / Artifact): "Implement the proposed tar_target change and run a dry validation." The agent does the clicking/typing.

4. **Close the loop** (cross-vendor + human): generate the exact human verification commands that must be run before the change is permanent:
   - `tar_visnetwork()`
   - Schema spot-check + row counts vs previous manifest
   - Update the real `DATA-DESIGN-DECISIONS.md` with the provenance tag

5. **Cross-vendor guard**: have the non-executing agent review the proposed registry entry — an independent model reviewing the proposal under the same project rules.

Nothing lands in the DAG or decision log without the human having executed the verification the registry requires.

## Concrete example (adapted from ClinicalDataProject patterns)

**Context**: You have a targets pipeline with raw extracts, feature layers, and ML/survival targets. A colleague (or agent) wants to add a care-source completeness flag for longitudinal filtering.

**Cross-vendor record** (this becomes the DD- entry or PR description):

```
DD-32 (proposed via Grok Build subagents + Claude execution)
Decision: Add `complete_history_flag` join + derived flag to feature_table for "health system has the full longitudinal picture" filtering.
Applies to: NEW pipeline survival/ML cohorts (population 2+), any analysis requiring complete longitudinal history.
Data: raw_extract + patient_care_source (via source person crosswalk), column complete_history_flag.
Provenance: llm_proposed (Grok Build explore subagent + Claude inspection of _targets.R + schema view) + human_reviewed 2026-06-10. Verified against data-design registry and shared API contracts.
Verification commands (must run before merge):
  R -e 'targets::tar_visnetwork(); targets::tar_manifest() |> filter(grepl("feature|care_source", name))'
  R -e 'tar_load(feature_table); feature_table |> count(complete_history) |> glimpse()'
  # + manual spot-check of 3 rows against source extract + confirm no row-count explosion
Update api_reference.md if any shared extract logic changed.
```

The agent can propose and even execute the visible edit. The cross-vendor review + your rules ensure the provenance, the verification steps, and the gate ("does this match the recorded decision and the live schema?") are never skipped.

## How this fits the broader mid-2026 picture

- Claude's strengths (computer use in the terminal, dynamic workflows, Artifacts that persist state and call models, rubric-graded agent sessions, and Fable 5's long-horizon autonomy) give you tireless hands.
- Grok Build's strengths (typed parallel subagents with worktree isolation, structured todos, plan mode with approval gates, first-class tool use, and zero-config CLAUDE.md / .claude/ rule inheritance) give you an independent reviewer under the same contract.
- ClinicalDataProject-style artifacts (targets DAG for lineage, explicit data-design-decision registry with provenance, 100% documented shared package APIs, validation gates) give you the durable contract that survives model changes and team handoffs.

Use the right tool for the right part of the work. Keep the human at the provenance and verification layer. The next run of the pipeline (or the next person reading the registry) will thank you.

## Copyable starting points

- Add a `Grok Build` section to your project `CLAUDE.md` that explicitly calls out subagent usage for pipeline changes and the requirement to update the data-design registry. (Grok Build reads it automatically; an `AGENTS.md` mirroring the key rules covers its native convention too.)
- Create a reusable orchestration skill (or prompt template) that forces a todo list + verification commands before handing execution to the other agent.
- When reviewing agent output on a DAG or schema change, always require the exact human-run verification commands to be listed and executed.

This is the meta-thinker pattern at scale: the agents do the work, the cross-vendor review keeps it honest, and you stay in control of the framing and the permanent record.
