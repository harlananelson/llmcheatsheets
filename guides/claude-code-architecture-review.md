# Claude Code as Phase 1 Scaffold for Domain Ontologies

A methodology for using Claude Code configuration files as the first
implementation layer of a typed reasoning architecture.

---

## Who This Is For

You have (or want to build) a **domain ontology** — a typed knowledge
representation with nodes, edges, and invariants — for a complex domain
(clinical medicine, legal reasoning, engineering design, scientific research).
You also use Claude Code as your development environment.

This guide shows how to map your ontology onto Claude Code's configuration
layers so that every session operates within your architectural constraints,
and your configuration files serve as the scaffolding for a future typed
system rather than just a project helper.

---

## 1. The Core Insight

Claude Code has four configuration layers that naturally map to components
of a reasoning architecture:

| Claude Code Layer | Architecture Function | Loaded When |
|-------------------|-----------------------|-------------|
| **CLAUDE.md** | Mode selection rules, invariant enforcement policies | Every interaction |
| **`.claude/context/`** | Constraint library, ontology schema, method decision trees | Every interaction (lower priority) |
| **memory/** | Evidence catalog, assumption registry, learned benchmarks | MEMORY.md every session; topic files on demand |
| **Notebook/output convention** | Processing pipeline template | When producing work products |

Most projects dump everything into CLAUDE.md. This guide shows how to
distribute content across layers so that each layer serves a specific
architectural function.

### Why This Matters

If you plan to eventually build a typed reasoning system, the work you do
now in Claude Code configuration is not throwaway scaffolding — it becomes
the knowledge base, constraint library, and validation logic that the typed
system operationalizes. Architectural shortcuts in configuration become
technical debt in the final system.

---

## 2. Defining Your Ontology for Claude Code

### 2.1 Identify Your Node Types

Every domain ontology has typed entities. Common patterns:

| Generic Node | Description | Examples |
|-------------|-------------|----------|
| **Task** | The user's goal or query | GitHub issues, tickets, research questions |
| **Claim** | An asserted statement requiring evidence | Hypotheses, conclusions, recommendations |
| **Evidence** | Measurements, observations, results | Metrics, study results, test outputs |
| **Constraint** | Invariants that bound the reasoning space | Domain laws, regulations, best practices |
| **Method** | Procedures, tests, analytical approaches | Algorithms, protocols, experiments |
| **Assumption** | Implicit beliefs that reasoning depends on | Data quality assumptions, scope limitations |
| **Validation** | Pass/fail criteria for claims | Acceptance tests, review criteria, thresholds |
| **Risk** | Safety, cost, and reversibility concerns | Side effects, failure modes, costs |
| **Resource** | External knowledge sources with quality metadata | Papers, guidelines, manuals, datasets |

**Exercise:** List the node types relevant to your domain. For each,
identify where they currently live in your Claude Code configuration
(CLAUDE.md? memory? nowhere?).

### 2.2 Identify Your Edge Types

Edges define relationships between nodes. Common patterns:

| Edge | From → To | Semantics |
|------|-----------|-----------|
| `supports` | Evidence → Claim | Evidence increases confidence in claim |
| `refutes` | Evidence → Claim | Evidence decreases confidence in claim |
| `requires` | Claim → Evidence | Claim depends on this evidence |
| `derives_from` | Claim → Constraint | First-principles derivation |
| `gates` | Claim → Validation | Claim must pass validation before becoming actionable |
| `assumes` | Claim → Assumption | Claim depends on this assumption holding |
| `has_risk` | Method → Risk | Method carries this risk |

### 2.3 Identify Your Reasoning Modes

Most domains have at least two reasoning modes with different rigor
requirements:

| Mode | Trigger | Invariants | Output Ceiling |
|------|---------|-----------|----------------|
| **Synthesis** | "What does the evidence say?" | Cite sources, note quality | Claims are provisional |
| **Creation** | "What should we do?" | Full validation, risk assessment, assumptions enumerated | Claims can be actionable after gate passage |

**Critical design decision:** When uncertain which mode applies, default
to the more rigorous one. The cost of under-reasoning exceeds the cost
of over-reasoning in any domain where decisions have consequences.

---

## 3. Mapping Ontology to Claude Code Layers

### 3.1 CLAUDE.md — The Deterministic Classifier (~200-300 lines)

CLAUDE.md is loaded on every interaction. It should contain only
**decision-making rules** — things that apply to every task. Think of it
as your system's routing logic and invariant declarations.

**What belongs here:**

```markdown
# Project — Claude Code Directives

## 1. Work Prioritization
[Who is the stakeholder? What is the source of truth for tasks?
What are the escalation rules?]

## 2. Mode Selection
### Task Classification
- [Task type A] → Synthesis mode
  - Ceiling: claims are provisional
- [Task type B] → Creation mode
  - Required: validation gates, assumption enumeration
- Ambiguous → Creation mode (fail-safe)

### Escalation Triggers
- [Condition] → promote from Synthesis to Creation

## 3. LLM Boundary
### The LLM MAY
- Propose analysis approaches, generate code, interpret results
- Suggest next steps, generate formatted outputs

### The LLM SHOULD NOT
- Claim any output is "validated" without human review
- Skip validation checks
- Assign quality scores to sources (use deterministic formula)

### The LLM MUST
- Report deterministic metrics without editorializing sufficiency
- Enumerate assumptions for every analytical claim
- Document decision provenance (llm_proposed / user_directed / convention)

## 4. Workflow Convention
[Mandatory steps: issue reference, approach documentation, etc.]

## 5. Output Convention
[Required sections, templates, quality standards]
[Pointers to .claude/context/ for detailed reference material]
```

**What does NOT belong here:**
- Data dictionaries (move to `context/`)
- Code recipes and patterns (move to `context/`)
- Checklists and reference tables (move to `context/`)
- Learned lessons (move to `memory/`)

**Rule of thumb:** If you'd Ctrl-F for it occasionally rather than
reading it every time, it belongs in `context/`, not CLAUDE.md.

### 3.2 `.claude/context/` — The Knowledge Base

Context files are loaded after CLAUDE.md. They hold reference material
that the LLM needs for specific tasks but not every interaction.

**Map each context file to an ontology function:**

| File | Ontology Function | Contains |
|------|------------------|----------|
| `ontology-schema.md` | Type definitions | Node types, edge types, field specifications |
| `domain-constraints.md` | Constraint library | Domain invariants with durability ratings |
| `assumption-registry.md` | Assumption catalog | Known assumptions, sensitivity ratings, test methods |
| `authority-scoring.md` | Evidence quality formula | Deterministic scoring: how to rate sources |
| `method-decision-tree.md` | Method selection logic | When to use which approach, prerequisites |
| `validation-gates.md` | Validation criteria | Structured review checklist with pass/fail states |
| `data-dictionary.md` | Evidence structure | Dataset schemas, field definitions |
| `code-patterns.md` | Method implementation | Reusable code recipes, package conventions |

**Creating the ontology schema file:**

```markdown
# Ontology Schema

## Node Types

### Claim
- statement: string (the asserted claim)
- confidence: { epistemic, contextual, temporal } — each [0,1]
- provenance: weighted vector over {first_principles, empirical, consensus, heuristic, anecdotal}
- actionability: enum(informational | provisional | validated | actionable)
- explainability: string (plain-language version for non-specialists)

### Assumption
- statement: string
- type: enum(behavioral | access | state | preference | methodological)
- sensitivity: enum(low | moderate | high | critical)
- testable: bool
- test_method: optional reference to Method

[... additional node types ...]

## Edge Types
[Table of edges with From → To → Semantics]

## Invariants
- Every Claim in Creation mode with actionability >= provisional
  MUST enumerate critical assumptions
- Every Method MUST document risks
- Every Resource MUST have a deterministic authority score
```

**Creating the constraint library:**

```markdown
# Domain Constraints

## Established Constraints (will not change)
| ID | Constraint | Source | Last Reviewed |
|----|-----------|--------|---------------|
| C-001 | [Fundamental domain law] | [Authoritative source] | [Date] |

## Stable Constraints (change on multi-year timescale)
| ID | Constraint | Version | Source | Next Review |
|----|-----------|---------|--------|-------------|
| C-010 | [Current best practice] | v2.3 | [Guideline body] | [Date] |

## Emerging Constraints (has an expiration date)
| ID | Constraint | Source | Confidence | Expiration |
|----|-----------|--------|-----------|-----------|
| C-020 | [Recent finding] | [Preprint/trial] | [Rating] | [Date] |
```

**Creating the assumption registry:**

```markdown
# Assumption Registry

## Domain-Specific Assumptions
| ID | Assumption | Type | Default | Sensitivity | Testable | Test Method |
|----|-----------|------|---------|-------------|----------|-------------|
| AS-001 | [Assumption statement] | [Category] | [true/false/unknown] | [critical/high/moderate/low] | [yes/no] | [How to verify] |

## Analytical Assumption Template
For every analysis, enumerate assumptions in this format:
| ID | Assumption | Type | Sensitivity | Status |
|----|-----------|------|-------------|--------|
| [auto] | [Statement] | methodological | [Rating] | [untested/confirmed/violated] |
```

### 3.3 memory/ — Persistent State

Memory files persist across sessions. They accumulate evidence about what
works, what fails, and what the system has learned.

| File | Ontology Function | Content |
|------|------------------|---------|
| `MEMORY.md` | Index + high-priority state | Links to topic files, key learnings (<200 lines) |
| `model-benchmarks.md` | Evidence catalog | Known performance baselines for comparison |
| `error-patterns.md` | Violated assumptions | Bugs mapped to the assumptions they violated |
| `domain-topic.md` | Specialized knowledge | Deep dives on specific domain areas |

**Key principle:** MEMORY.md is loaded every session, so keep it concise.
Detailed content goes in topic files referenced from MEMORY.md.

### 3.4 Output Convention — The Processing Pipeline

Map your work products to a processing pipeline. Every output should
follow a consistent section structure that mirrors the reasoning stages:

| Pipeline Stage | Output Section | What It Produces |
|----------------|---------------|------------------|
| **INGEST** | Task Reference + Data Loading | What was asked + what data is available |
| **ROUTE** | Approach Documentation | Which reasoning mode was selected and why |
| **EXPAND** | Analysis / Investigation | Claims generated, evidence gathered |
| **GATE** | Validation | Which claims pass which gates, which don't |
| **DECIDE** | Recommendations | Method selection with risk assessment |
| **UPDATE** | Limitations & Degradation | What remains uncertain, what assumptions are unverified |
| **OUTPUT** | Summary | Audience-appropriate rendering of claims with explainability |

---

## 4. The LLM/Deterministic Boundary

This is the most important architectural decision for LLM-assisted
reasoning systems.

### 4.1 The Problem

LLMs produce plausible-sounding reasoning traces that are not structurally
verifiable. In any high-stakes domain, a plausible but incorrect claim
can lead to harmful decisions. The solution is to separate what the LLM
does from what deterministic logic does.

### 4.2 The Boundary

**The LLM MAY:**
- Propose new nodes (Claims, Evidence, Assumptions)
- Identify relationships between Evidence and Claims
- Suggest evidence quality inputs (study design, population, recency)
- Generate natural-language explanations
- Propose method ordering rationale

**The LLM MAY NOT:**
- Directly assign confidence values
- Bypass validation gates
- Mark claims as actionable without gate passage
- Override deterministic routing decisions
- Assign authority scores to resources

**The DETERMINISTIC SYSTEM:**
- Computes confidence from evidence quality inputs using defined formulas
- Evaluates validation gate passage
- Computes method priority ordering
- Enforces all invariants

### 4.3 Phase 1 Implementation (Convention-Based)

In Phase 1, you enforce this boundary through CLAUDE.md conventions:

```markdown
## LLM Boundary
Claude SHOULD NOT claim any analysis is "validated" or "actionable"
without human review. All claims remain `provisional` until a human
reviewer confirms gate passage.

Claude MUST report deterministic metrics (computed values, test results)
without editorializing on their sufficiency. Let the validation gates
determine pass/fail.
```

### 4.4 Phase 2 Implementation (Code-Based)

In Phase 2, enforce programmatically:
- Validation scripts check that outputs meet gate criteria
- Authority scores computed by deterministic functions, not LLM judgment
- Audit trail records `mutation_source: enum(llm_proposed | deterministic | user_input)`

---

## 5. Gap Analysis Template

When evaluating your current configuration against your target ontology,
use this template for each component:

```markdown
## Gap: [Component Name]

**Current State:** [What exists now — be specific about files and locations]
**Required State:** [What the ontology specifies]
**Gap Severity:** Critical | High | Medium | Low
**Migration Path:**
1. [Specific step]
2. [Specific step]
**Dependencies:** [What else must change first]
```

### 5.1 Common Gaps

These gaps appear in almost every project that hasn't done this mapping:

| Gap | Typical Severity | Symptom |
|-----|-----------------|---------|
| **No assumption tracking** | Critical | Errors are misdiagnosed as "the model is wrong" when the data doesn't match what was assumed |
| **No mode selection** | High | Simple lookups get the same heavyweight process as complex reasoning tasks |
| **No LLM boundary** | Critical | LLM assigns confidence, evaluates its own output, and claims are "validated" without human review |
| **CLAUDE.md too large** | Medium | Context window consumed by reference material irrelevant to current task |
| **No validation structure** | High | Review is voluntary and binary (done/not done) rather than typed criteria with states |
| **No evidence quality scoring** | High | A case report and a meta-analysis have equal visual weight in citations |
| **No risk tracking** | Medium | Risks of recommended approaches are implicit, not explicitly documented |
| **Assumptions invisible** | Critical | The most dangerous gap — implicit assumptions are the primary source of silent reasoning errors |

---

## 6. Implementation Roadmap

### Phase 1a: Extract and Organize (2-3 hours)

The quickest improvement: separate rules from reference material.

1. Create `.claude/context/` directory
2. Move data dictionaries, code recipes, and checklists from CLAUDE.md
   to appropriately named context files
3. Slim CLAUDE.md to ~200-300 lines of decisions and conventions
4. Add pointers from CLAUDE.md to context files
5. Clean stale entries from settings files

**Success criterion:** CLAUDE.md contains only rules that apply to every
interaction. Reference material is in context files.

### Phase 1b: Ontology Scaffolding (4-8 hours)

Create the architectural context files:

6. `context/ontology-schema.md` — node/edge type definitions
7. `context/domain-constraints.md` — constraint library with durability tags
8. `context/assumption-registry.md` — known assumptions + template
9. `context/authority-scoring.md` — deterministic source quality formula
10. `context/method-decision-tree.md` — approach selection logic
11. `context/validation-gates.md` — structured review criteria
12. Add mode selection and LLM boundary sections to CLAUDE.md

**Success criterion:** Every context file maps to a specific ontology
function. A new contributor can understand the reasoning architecture
from the context files alone.

### Phase 1c: Convention Updates (1-2 hours)

Update work product templates:

13. Add mandatory Assumptions section to output convention
14. Add Limitations & Degradation section
15. Add authority_score to bibliography convention
16. Add decision provenance metadata (llm_proposed / user_directed / convention)

**Success criterion:** Every work product follows the processing pipeline
structure and documents its assumptions.

### Phase 2: Enforcement (future)

17. Build validation scripts that check gate passage programmatically
18. Implement authority score computation as deterministic code
19. Create domain-specific Claude Code skill with full pipeline template
20. Add audit trail to every graph mutation

### Phase 3+: Graph Runtime (future)

21. Define graph database or in-memory representation
22. Implement typed graph mutation API
23. Build deterministic mode classifier as code
24. Implement audience-switching output renderer

---

## 7. Architectural Validation Test

Choose the hardest decision your domain needs to support. This decision
should integrate every capability: risk assessment, evidence synthesis,
constraint application, assumption tracking, multi-stakeholder output,
and time-sensitivity.

Walk through how your proposed scaffold would represent this decision:

1. **Task:** What is the question? What mode does it route to?
2. **Constraints activated:** Which domain constraints apply?
3. **Assumptions required:** What must be true for the reasoning to hold?
4. **Validation gates:** What must be verified before a claim becomes actionable?
5. **Risk assessment:** What are the risks, in both technical and lay terms?
6. **What works:** What can the scaffold handle today?
7. **What doesn't:** What requires Phase 2+ infrastructure?

If the scaffold cannot represent the decision at all, your ontology is
missing node types or edges. If it can represent it but not enforce it,
that's expected for Phase 1 — convention-based enforcement is the goal.

---

## 8. Principles

### Progressive Disclosure

```
CLAUDE.md (always loaded)
  → Decisions, conventions, priorities
  → Short (200-300 lines)

.claude/context/ (loaded after CLAUDE.md)
  → Reference material, schemas, constraint libraries
  → Loaded automatically but lower priority

memory/ (persistent across sessions)
  → Evidence, benchmarks, learned patterns
  → MEMORY.md always loaded; topic files on demand
```

### Separation of Concerns

| Layer | Contains | Does NOT Contain |
|-------|----------|------------------|
| **CLAUDE.md** | Rules, mode selection, invariants | Code blocks, data schemas, checklists |
| **context/** | Reference material, type definitions | Decision-making rules |
| **memory/** | Learnings, benchmarks, evidence | Instructions (those go in CLAUDE.md) |
| **settings** | Permissions (allow/deny) | Instructions |

### Fail-Safe Toward Rigor

When the mode classifier is uncertain, route to the more rigorous mode.
The cost of over-reasoning is wasted compute. The cost of under-reasoning
in a consequential domain is a reasoning failure with real consequences.

### Convention Before Code

Phase 1 enforces invariants through CLAUDE.md conventions (natural-language
rules). Phase 2 enforces through code (validation scripts, structured
output constraints). Convention-based enforcement is imperfect but ships
immediately. Code-based enforcement is reliable but requires implementation.

Start with conventions. Upgrade to code when the conventions are stable
and proven.

---

## 9. Checklist: Is Your Configuration Architecture-Ready?

| Question | If No |
|----------|-------|
| Is CLAUDE.md under 300 lines? | Extract reference material to `.claude/context/` |
| Does CLAUDE.md define reasoning modes? | Add mode selection section |
| Is there an explicit LLM boundary? | Add LLM MAY / MAY NOT section |
| Do you have a constraint library? | Create `context/domain-constraints.md` |
| Are assumptions tracked? | Create `context/assumption-registry.md` |
| Is evidence quality scored? | Create `context/authority-scoring.md` |
| Do outputs follow a pipeline structure? | Define section convention mapping to INGEST→OUTPUT |
| Are validation criteria typed? | Restructure checklist in `context/validation-gates.md` |
| Is memory structured? | Organize into MEMORY.md + topic files |
| Can you walk through your hardest decision? | Your ontology is missing components — add them |

---

*This guide is domain-agnostic. For a worked example applying this
methodology to a clinical SCD research project, see the companion
gap analysis in the SCDCernerProject repository.*
