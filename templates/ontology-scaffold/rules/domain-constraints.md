# Domain Constraint Library — {DOMAIN_DESCRIPTION}

## Durability Scale

| Level | Meaning | Example |
|-------|---------|---------|
| **established** | Fundamental laws/limits — will not change | Physical constants, mathematical axioms, hard platform limits |
| **stable** | Current standards — changes on multi-year timescale | Best practices, API versions, regulatory requirements |
| **emerging** | Recent findings — may change or be superseded | Preprint results, preview features, draft guidelines |
| **contextual** | Organization-specific — varies by team/project | Internal policies, local conventions, team preferences |

---

## Established Constraints

| ID | Constraint | Source | Last Reviewed |
|----|-----------|--------|---------------|
| C-001 | {CONSTRAINT_DESCRIPTION} | {SOURCE} | {DATE} |
| C-002 | {CONSTRAINT_DESCRIPTION} | {SOURCE} | {DATE} |

---

## Stable Constraints

| ID | Constraint | Version | Source | Next Review |
|----|-----------|---------|--------|-------------|
| C-010 | {CONSTRAINT_DESCRIPTION} | {VERSION} | {SOURCE} | {DATE} |
| C-011 | {CONSTRAINT_DESCRIPTION} | {VERSION} | {SOURCE} | {DATE} |

---

## Emerging Constraints

| ID | Constraint | Source | Confidence | Expiration |
|----|-----------|--------|-----------|-----------|
| C-020 | {CONSTRAINT_DESCRIPTION} | {SOURCE} | {high/moderate/low} | {DATE} |

---

## Contextual Constraints (Organization-Specific)

| ID | Constraint | Source | Last Verified |
|----|-----------|--------|---------------|
| C-030 | {ORG_SPECIFIC_CONSTRAINT} | {SOURCE} | {DATE} |
| C-031 | {ORG_SPECIFIC_CONSTRAINT} | {SOURCE} | {DATE} |

---

## Usage

When producing work products:
1. List which constraints from this library apply to the current task
2. Use constraint IDs for traceability (e.g., "Per C-001, we cannot...")
3. If a new constraint is discovered, add it here with the appropriate durability tag
4. Review emerging constraints on their expiration dates
