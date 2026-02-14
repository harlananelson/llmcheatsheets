# Assumption Registry — {DOMAIN_DESCRIPTION}

## Domain Assumptions

Known assumptions that reasoning in this domain depends on. Every assumption
has a sensitivity rating and, where possible, a concrete test method.

| ID | Assumption | Type | Sensitivity | Testable | Test Method |
|----|-----------|------|-------------|----------|-------------|
| AS-001 | {ASSUMPTION_STATEMENT} | {TYPE} | {critical/high/moderate/low} | {yes/no} | {HOW_TO_VERIFY} |
| AS-002 | {ASSUMPTION_STATEMENT} | {TYPE} | {critical/high/moderate/low} | {yes/no} | {HOW_TO_VERIFY} |
| AS-003 | {ASSUMPTION_STATEMENT} | {TYPE} | {critical/high/moderate/low} | {yes/no} | {HOW_TO_VERIFY} |

### Assumption Types

| Type | Description | Examples |
|------|-------------|---------|
| `access` | Permissions, credentials, reachability | "Service has read access to database" |
| `state` | Current condition of systems or data | "Table contains records from last 30 days" |
| `behavioral` | Expected behavior of systems or people | "API returns JSON, not XML" |
| `methodological` | Analytical or procedural choices | "Linear relationship between X and Y" |
| `preference` | Stakeholder preferences not yet confirmed | "Client prefers dashboard over PDF report" |

### Sensitivity Ratings

| Rating | Meaning | Required Action |
|--------|---------|-----------------|
| `critical` | If violated, ALL dependent work is invalid | MUST test before proceeding |
| `high` | If violated, THIS TASK fails | Should test before proceeding |
| `moderate` | If violated, results may be degraded | Test when convenient |
| `low` | If violated, minor impact | Document but no blocking test needed |

---

## Analytical Assumptions (Per-Task)

For every analysis or implementation task, enumerate assumptions in this format:

| ID | Assumption | Type | Sensitivity | Status |
|----|-----------|------|-------------|--------|
| [auto] | [Statement] | [Type from above] | [Rating] | untested / confirmed / violated |

---

## Adding New Assumptions

When a new assumption is discovered during work:

1. Assign next available ID in the appropriate category
2. Rate sensitivity using the scale above
3. Determine testability and write a concrete test method if possible
4. If `sensitivity: critical`, test BEFORE proceeding with dependent work
5. If assumption is violated, update status and halt dependent work (see Halt on Contradiction protocol)
