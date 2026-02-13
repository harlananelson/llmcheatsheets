# Knowledge Vault Skill

> **Usage:** Load this file into Claude Code or paste into an LLM session. It contains
> everything needed to scaffold a knowledge vault — a linked markdown note system with
> explicit rules that teach Claude how to navigate, connect, and maintain notes.

This skill produces a complete vault directory with CLAUDE.md, rules files, templates,
an index, and starter topic pages. The vault is immediately operational — Claude can
begin capturing and connecting notes as soon as scaffolding is complete.

For the conceptual guide, see [`guides/knowledge-vault.md`](../guides/knowledge-vault.md).

---

## 1) Directory Structure

Create this tree at the target location (default: `~/projects/vault/`):

```
vault/
├── 00_inbox/
├── 01_thinking/
│   └── notes/
├── 02_reference/
│   ├── tools/
│   ├── approaches/
│   └── sources/
├── 03_creating/
│   └── drafts/
├── 04_published/
├── 05_archive/
├── 06_system/
│   └── templates/
│       └── note-template.md
├── CLAUDE.md
├── .claude/
│   ├── rules/
│   │   ├── ontology-schema.md
│   │   ├── knowledge-constraints.md
│   │   ├── authority-scoring.md
│   │   ├── vault-operations.md
│   │   └── note-conventions.md
│   └── settings.local.json
├── index.md
└── .gitignore
```

---

## 2) CLAUDE.md

The slim routing file (~150-200 lines). Defines purpose, modes, LLM boundary,
agent operations, key invariants, and pointers to rules files.

```markdown
# Knowledge Vault

**Purpose:** {VAULT_PURPOSE}

This extends the global `/projects/CLAUDE.md`. Rules files in `.claude/rules/`
are auto-loaded every session.

---

## 1. Vault Purpose

{DESCRIBE_WHAT_THIS_VAULT_STORES}

The vault is organized as linked markdown files in numbered folders that encode
status (inbox -> thinking -> creating -> published -> archive).

---

## 2. Mode Selection

### Capture Mode
Quick inbox deposits. Zero friction. Triggered by "capture", "jot down", "quick note".
- Create note in `00_inbox/` with minimal metadata
- Do NOT search for connections (that's synthesis)
- Do NOT update index (batch later)

### Synthesis Mode
Linking, connecting, developing notes. Triggered by "connect", "develop", "link",
"find connections", "what relates to".
- Orient first: read `index.md` + relevant topic pages
- Search for related content with Grep
- Add wiki-style links woven into prose
- Update topic pages with new connections
- Update `index.md` after changes

### Creation Mode
Building new insight documents, drafts, guides. Triggered by "draft", "write up",
"create a guide", "develop into".
- Read all source notes before starting
- Create in `03_creating/drafts/`
- Track sources via links back to vault notes

---

## 3. LLM Boundary

### Claude MAY
- Create, link, and move notes between folders
- Propose connections between notes
- Update `index.md` and topic pages
- Suggest that a note is ready to advance in status
- Search for related content and surface connections
- Create topic pages (MOCs) for emerging themes

### Claude MUST NOT
- Delete notes without explicit user confirmation
- Assign authority scores directly (use deterministic formula in `rules/authority-scoring.md`)
- Skip reading the relevant topic page before modifying a topic area
- Move notes to `04_published/` or `05_archive/` without confirmation
- Claim a note is "mature" or "validated" without user review

### Claude MUST
- Orient before acting: read `index.md` + relevant topic page first
- Record breadcrumbs in topic pages after navigating a topic area
- Search for connections after creating any new note
- Update `index.md` after creating, moving, or archiving notes
- Preserve existing links when editing notes

---

## 4. Agent Operations

### Orientation Protocol
Before any vault operation:
1. Read `index.md` to understand current vault state
2. Identify relevant topic pages from the index
3. Read those topic pages to understand the local neighborhood
4. Then act

### Breadcrumbs
After working in a topic area, update the topic page with:
- What was done (notes created, links added, connections found)
- Date of activity
- Open questions or threads to follow

### Connection Search
Every new note triggers:
1. Grep vault for key terms from the new note
2. Read candidate related notes
3. Add bidirectional links where genuine connections exist
4. Update relevant topic pages

### Index Maintenance
After creating, moving, or archiving notes:
- Add/update the entry in `index.md`
- Keep entries as one-line summaries for quick scanning

---

## 5. Key Invariants

1. **Notes named as claims, not topics.** Claims are composable; topics are containers.
2. **Notes must stand alone.** Links add depth, not prerequisites.
3. **Every new note triggers connection search.** The network IS the value.
4. **Quality over quantity.** Develop before proliferating.
5. **Folder encodes status.** 00=inbox, 01=thinking, 03=creating, 04=published, 05=archive.
6. **Links are woven into prose.** Not listed as footnotes.
7. **Topic pages are maps, not containers.**

---

## 6. Reference Files (auto-loaded from .claude/rules/)

| File | Contents |
|------|----------|
| `rules/ontology-schema.md` | Node types, edge types, key invariants |
| `rules/knowledge-constraints.md` | Quality constraints for notes and connections |
| `rules/authority-scoring.md` | Deterministic formula for source quality |
| `rules/vault-operations.md` | How Claude navigates and operates the vault |
| `rules/note-conventions.md` | Note format, naming, linking, status lifecycle |

---

## 7. Folder Reference

| Folder | Purpose | Entry point |
|--------|---------|-------------|
| `00_inbox/` | Zero-friction capture | Capture mode |
| `01_thinking/` | Active development, topic pages (MOCs) | Synthesis mode |
| `01_thinking/notes/` | Individual developing notes | Synthesis mode |
| `02_reference/` | External knowledge (tools, approaches, sources) | Any mode |
| `03_creating/drafts/` | Work in progress toward output | Creation mode |
| `04_published/` | Finished, stable output | User moves here |
| `05_archive/` | Inactive content | User moves here |
| `06_system/templates/` | Note and document templates | Any mode |
```

---

## 3) Rules Files

### `ontology-schema.md`

```markdown
# Ontology Schema — Knowledge Vault

> Defines node and edge types for the vault's knowledge graph.

---

## Node Types

### Note
The atomic unit of the vault. A self-contained piece of thinking.
- **name:** Claim-form title (assertion, not topic label)
- **status:** inbox | developing | mature | published | archived
- **created:** date
- **topics:** list of TopicPage references
- **composable:** must be understandable without reading other notes

### Claim
A specific assertion extracted from or embedded in a Note.
- **claim_type:** hypothesis | conclusion | observation | principle | heuristic
- **confidence:** low | medium | high (user-assigned)
- **provenance:** first_principles | empirical | consensus | heuristic | anecdotal

### Source
External knowledge with quality metadata. Scored by deterministic formula.
- **source_type:** peer_reviewed | preprint | documentation | blog | book | conversation | experience
- **authority_score:** computed by formula, never LLM-assigned

### TopicPage (Map of Content)
Navigation node that links to related Notes and describes a topic landscape.
- **scope:** what this topic covers and its boundaries
- **notes:** linked Note references
- **open_questions:** threads to follow
- **breadcrumbs:** log of recent activity

### Question
An explicit open question that drives inquiry.
- **question_type:** factual | methodological | conceptual | strategic
- **status:** open | exploring | answered | deferred

### Insight
A higher-order connection between Notes that emerges from linking.
- **connects:** list of Note references
- **novel:** goes beyond what any source note says individually

### Method
A procedure, tool, or approach referenced by Notes.
- **method_type:** statistical | computational | experimental | analytical

---

## Edge Types

| Edge | From -> To | Semantics |
|------|-----------|-----------|
| `supports` | Source/Note -> Claim | Evidence increases confidence |
| `refutes` | Source/Note -> Claim | Evidence decreases confidence |
| `extends` | Note -> Note | Builds on, takes further |
| `contextualizes` | Note -> Claim | Modifies interpretation |
| `derived_from` | Note -> Source | Note draws on this source |
| `questions` | Question -> Note/Claim | Targets for investigation |
| `answers` | Note -> Question | Addresses this question |
| `maps` | TopicPage -> Note | Topic page includes this note |
| `connects` | Insight -> Note | Insight links these notes |
| `supersedes` | Note -> Note | Newer replaces older |

---

## Key Invariants

1. Every Note links to at least one TopicPage
2. Every Source has an authority_score computed by formula
3. TopicPages link and describe — they don't hold primary content
4. Bidirectional linking: if A links to B, B should acknowledge A

---

## LLM Boundary

**LLM MAY:** Propose nodes, identify relationships, suggest connections,
generate link text, propose topic page updates.

**LLM MAY NOT:** Assign authority scores, mark notes as mature/published
without user review, delete nodes.
```

### `knowledge-constraints.md`

```markdown
# Knowledge Constraints

---

## Composability

Every note must stand alone. Cover all links — is it still coherent?

## Naming

Notes named as claims, not topics.

| Good (claim) | Bad (topic) |
|--------------|-------------|
| knowledge-bases-and-codebases-share-structure | knowledge-bases |
| batch-correction-requires-benchmarking | batch-correction |

Exception: Topic pages ARE named as topics (they're maps, not assertions).

## Linking

Links woven into prose, not listed as footnotes. Articulate WHY two things
connect — the articulation IS the value.

## Depth Over Breadth

Before creating a new note: does an existing note cover this? Is this
genuinely a distinct claim? Or just a fragment for inbox?

A "developing" note: clear claim, 2-3 paragraphs, at least one link, at
least one topic reference.

A "mature" note: all above, plus multiple links, sources cited,
counterarguments addressed.

## Connection Quality

Connections should be specific, genuine, and articulated. If a note has
more than 5-7 outgoing links, some are probably weak — prune.
```

### `authority-scoring.md`

```markdown
# Authority Scoring

> Deterministic formula for scoring source quality.
> LLM proposes inputs; formula computes score. LLM MAY NOT assign scores directly.

## Formula

authority_score = (
    source_type_weight     * 0.35
  + domain_specificity     * 0.25
  + recency_weight         * 0.20
  + venue_quality_weight   * 0.20
)

Output range: [0, 1]

## Source Type Weight (0.35)

| Source Type | Weight |
|-------------|--------|
| Meta-analysis / systematic review | 1.00 |
| Peer-reviewed research article | 0.75 |
| Preprint (bioRxiv, arXiv) | 0.55 |
| Official documentation | 0.50 |
| Technical book | 0.50 |
| Technical blog (credentialed) | 0.35 |
| Conference talk | 0.30 |
| Tutorial / course | 0.25 |
| Conversation / experience | 0.15 |

## Domain Specificity (0.25)

| Specificity | Weight |
|-------------|--------|
| Directly on-topic | 1.00 |
| Adjacent domain | 0.60 |
| General domain | 0.30 |

## Recency Weight (0.20)

recency_weight = max(0.30, 1.0 - 0.05 * (current_year - publication_year))

Floor at 0.30: foundational work stays relevant.

## Venue Quality (0.20)

| Venue | Weight |
|-------|--------|
| Top-tier journal | 1.00 |
| High-impact specialty | 0.80 |
| Major guideline body | 0.90 |
| Standard peer-reviewed | 0.60 |
| Preprint server | 0.45 |
| Official docs | 0.50 |
| Blog / Medium | 0.25 |
| Social media / forum | 0.15 |

## LLM Boundary

| Step | Who | What |
|------|-----|------|
| 1. Identify inputs | LLM | Propose source type, domain, year, venue |
| 2. Compute score | Formula | Apply weights deterministically |
| 3. Report score | LLM | Include in source reference |
| 4. Override | User only | Adjust with documented rationale |
```

### `vault-operations.md`

```markdown
# Vault Operations

## Orientation Protocol

Before any vault operation (except Capture Mode):

1. Read `index.md`
2. Identify relevant topic pages
3. Read those topic pages
4. Then act

Exception: Capture Mode bypasses orientation for speed.

## Note Creation

### Capture (00_inbox)
1. Create in `00_inbox/` using template
2. Fill title (claim form), date, raw content
3. Leave topics and links empty
4. Do NOT update index

### Synthesis (01_thinking)
1. Complete orientation protocol
2. Create in `01_thinking/notes/` using template
3. Fill all metadata: title, date, status, topics, links
4. Run connection search
5. Update topic pages and `index.md`

### Reference (02_reference)
1. Create in appropriate subfolder
2. Include authority score for external sources
3. Link to notes that reference this source
4. Update `index.md`

## Connection Search

After every new note (except Capture):
1. Extract key terms from title and content
2. Grep vault for those terms
3. Read candidates — are they genuinely related?
4. Add links in both directions (articulate the relationship)
5. Update topic pages

Quality gate: only link where you can articulate the relationship in a sentence.

## Breadcrumbs

After working in a topic area, update the topic page:

**YYYY-MM-DD:** What was done. What was connected. What's open.

## Index Maintenance

After create/move/archive: add or update the `index.md` table entry.

## Status Transitions

| Transition | Who confirms |
|-----------|--------------|
| inbox -> thinking | Claude may propose |
| thinking -> creating | User confirms |
| creating -> published | User confirms |
| any -> archive | User confirms |

## Conflict Resolution

If new note contradicts existing: create both, add `refutes` links, surface
the conflict to the user.
```

### `note-conventions.md`

```markdown
# Note Conventions

## File Naming

Lowercase, hyphen-separated, claim-form: `knowledge-bases-and-codebases-share-structure.md`

No date prefixes. No numbering. Date is in frontmatter.

## Frontmatter

---
title: Claim-form title here
date: YYYY-MM-DD
status: developing
topics:
  - "[Topic Name](../topic-page.md)"
sources:
  - "[Source](../../02_reference/sources/source-name.md)"
tags: [optional, freeform]
---

## Status Lifecycle

inbox -> developing -> mature -> published -> archived

| Status | Location |
|--------|----------|
| inbox | `00_inbox/` |
| developing | `01_thinking/notes/` |
| mature | `01_thinking/notes/` |
| published | `04_published/` |
| archived | `05_archive/` |

Developing -> Mature criteria: 2+ paragraphs, 3+ links, counterargument addressed.

## Topic Pages

Live in `01_thinking/`. Structure:

# Topic Name
Scope statement.
## Core Notes
## Open Questions
## Recent Activity

## Linking

- Relative paths from current file
- Link text = claim (natural language), not filename
- Bidirectional: if A links B, B acknowledges A
```

---

## 4) Note Template

Place at `06_system/templates/note-template.md`:

```markdown
---
title: Claim-form title here
date: YYYY-MM-DD
status: inbox
topics:
  - "[Topic Name](path/to/topic-page.md)"
sources:
  - "[Source Name](path/to/source.md)"
tags: []
---

# Claim-form title here

*Replace with developed thinking. A developing note should have 2-3 paragraphs
minimum. State the claim, provide evidence or reasoning, address alternatives.*

## What this connects to

*Woven links to related notes go here in prose form. Articulate WHY each
connection matters, not just that it exists.*
```

---

## 5) Index

Place at `index.md`:

```markdown
# Vault Index

One-line descriptions for quick scanning. Updated by Claude after note operations.

| Note | Location | Summary |
|------|----------|---------|
```

---

## 6) Starter Topic Pages

Create 2-3 topic pages in `01_thinking/` based on the vault's purpose. Example:

```markdown
# {TOPIC_NAME}

{Brief scope — what this topic covers and its boundaries.}

## Core Notes

*No notes yet. As notes are created, they'll be linked here with one-line
descriptions of how they connect.*

## Open Questions

- {Question that drives inquiry in this area}

## Recent Activity

- **{TODAY}:** Topic page created as part of vault scaffolding.
```

---

## 7) Supporting Files

### `.gitignore`

```
.DS_Store
Thumbs.db
.obsidian/
.trash/
*.swp
*.swo
*~
.vscode/
.claude/settings.local.json
```

### `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(tree:*)",
      "Bash(git status:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)"
    ]
  }
}
```

---

## 8) Scaffolding Checklist

After generating all files:

1. [ ] Initialize git: `git init && git branch -m main`
2. [ ] Verify CLAUDE.md loads: start Claude Code session in vault directory
3. [ ] Test capture: "capture a note about X" → appears in `00_inbox/`
4. [ ] Test synthesis: "find connections for note Y" → orientation → grep → links
5. [ ] Test index: after note creation, `index.md` should be updated
6. [ ] Add starter topic pages for your domain areas

---

## 9) Customization Points

| What | Where | How |
|------|-------|-----|
| Vault purpose | CLAUDE.md §1 | Replace `{VAULT_PURPOSE}` and `{DESCRIBE_WHAT_THIS_VAULT_STORES}` |
| Topic areas | `01_thinking/*.md` | Create topic pages for your domain |
| Authority weights | `rules/authority-scoring.md` | Adjust weights for your source types |
| Note quality bar | `rules/knowledge-constraints.md` | Tighten or relax developing/mature criteria |
| Additional node types | `rules/ontology-schema.md` | Add domain-specific node types |
| Folder structure | Directory tree | Add/rename folders for your workflow |

The rules files are the primary customization surface. The CLAUDE.md stays slim
and routes to rules. Customize rules freely — they're auto-loaded every session.
