# Ontology Schema — {DOMAIN_DESCRIPTION}

## Node Types

These are the typed entities in your domain reasoning. Keep the generic types
and add domain-specific types below the table.

| Node Type | Description | Key Fields |
|-----------|-------------|------------|
| **Task** | A unit of work (issue, ticket, research question) | id, title, state, assigned_to |
| **Claim** | A technical or analytical assertion | statement, mode, validation_status, provenance |
| **Evidence** | Metrics, results, observations, API responses | source, timestamp, authority_score |
| **Constraint** | Domain limits, policies, invariants | id, description, durability, source |
| **Assumption** | Beliefs that reasoning depends on | id, description, sensitivity, testable, test_method |
| **Method** | An approach, tool, or procedure | name, prerequisites, assumptions_required, risks |
| **Validation** | Gate passage result | gate_name, status (6-state), evidence_refs |
| **Risk** | Potential negative outcome | description, likelihood, impact, mitigation |
| **Resource** | External knowledge source with quality metadata | url, authority_score, last_verified |

### Domain-Specific Node Types

Add node types specific to your domain:

| Node Type | Description | Key Fields |
|-----------|-------------|------------|
| **{DOMAIN_NODE_1}** | {DESCRIPTION} | {FIELDS} |
| **{DOMAIN_NODE_2}** | {DESCRIPTION} | {FIELDS} |

---

## Edge Types

| Edge | From → To | Semantics |
|------|-----------|-----------|
| `supports` | Evidence → Claim | Evidence increases confidence in claim |
| `refutes` | Evidence → Claim | Evidence contradicts claim |
| `requires` | Claim → Evidence | Claim depends on this evidence |
| `derives_from` | Claim → Constraint | Follows from domain invariant or policy |
| `gates` | Claim → Validation | Must pass gate before actionable |
| `assumes` | Claim → Assumption | Depends on this assumption holding |
| `has_risk` | Method → Risk | Approach carries this risk |
| `mitigates` | Method → Risk | Approach reduces this risk |
| `blocks` | Task → Task | This task must complete first |
| `implements` | Task → Claim | Work item implements this recommendation |

### Domain-Specific Edges

| Edge | From → To | Semantics |
|------|-----------|-----------|
| `{DOMAIN_EDGE_1}` | {FROM} → {TO} | {SEMANTICS} |

---

## Invariants

1. Every Claim has exactly one `provenance` tag: `llm_proposed | user_directed | convention | stakeholder_directed`
2. Every Claim in Implementation mode has at least one Assumption edge
3. Every Assumption with `sensitivity: critical` must be tested before dependent Claims are actionable
4. Constraints with `durability: established` are never overridden without user approval
5. Every Resource has a deterministic `authority_score` (see rules/authority-scoring.md)
6. {DOMAIN_INVARIANT_1}
7. {DOMAIN_INVARIANT_2}

---

## Validation Status (6-State)

| Status | Meaning | Actionability |
|--------|---------|---------------|
| `unvalidated` | No check attempted | informational only |
| `pending` | Check in progress | informational only |
| `partially_validated` | Some gates passed | provisional (dev/test OK) |
| `validated` | All gates passed | actionable |
| `contextually_validated` | Passed with documented conditions | actionable with caveats |
| `failed` | Gate failed | blocked — investigate |

---

## Decision Provenance Tags

| Tag | Meaning |
|-----|---------|
| `llm_proposed` | Claude suggested this based on analysis |
| `user_directed` | User explicitly requested this approach |
| `convention` | Follows from CLAUDE.md or rules/ convention |
| `stakeholder_directed` | Stakeholder/PI directed this decision |
