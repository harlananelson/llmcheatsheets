# Output Conventions — {DOMAIN_DESCRIPTION}

## Processing Pipeline

Every work product follows this pipeline structure. Each stage maps to a
required section in the output.

| Pipeline Stage | Output Section | What It Produces |
|----------------|---------------|------------------|
| **INGEST** | Task Reference + Data/Context | What was asked + what is available |
| **ROUTE** | Approach Documentation | Which reasoning mode was selected and why |
| **EXPAND** | Analysis / Investigation | Claims generated, evidence gathered |
| **GATE** | Validation | Which claims pass which gates |
| **DECIDE** | Recommendations | Method selection with risk assessment |
| **UPDATE** | Limitations & Degradation | What remains uncertain, what assumptions are unverified |
| **OUTPUT** | Summary | Audience-appropriate rendering of claims |

---

## Required Sections

### 1. Task Reference

```markdown
## Task Reference
- **Source:** {TASK_SOURCE} #{TASK_ID}
- **Title:** {TASK_TITLE}
- **Reasoning mode:** InformationSynthesis / Implementation
- **Routing rationale:** {WHY_THIS_MODE}
```

### 2. Constraints Applied

List constraints from `rules/domain-constraints.md` that apply to this task:

```markdown
## Constraints Applied
- C-001: {constraint description} — {how it affects this task}
- C-030: {constraint description} — {how it affects this task}
```

### 3. Assumptions

Enumerate assumptions for this specific task:

```markdown
## Assumptions
| ID | Assumption | Sensitivity | Status |
|----|-----------|-------------|--------|
| AS-001 | {from registry} | critical | confirmed |
| [new] | {task-specific assumption} | high | untested |
```

### 4. Analysis / Implementation

The main body of work. Structure depends on reasoning mode.

### 5. Validation Status

```markdown
## Validation
| Gate | Status | Notes |
|------|--------|-------|
| {Gate 1} | passed | {evidence} |
| {Gate 2} | failed | {reason} |
| **Composite** | **partially_validated** | |
```

### 6. Limitations & Degradation

```markdown
## Limitations
- {What gates are unsatisfied}
- {What assumptions are unverified}
- {What would change the conclusions}
```

### 7. Decision Provenance

```markdown
## Provenance
| Decision | Source |
|----------|--------|
| {approach choice} | user_directed |
| {method selection} | llm_proposed |
| {output format} | convention |
```

---

## Section Requirements by Mode

| Section | InformationSynthesis | Implementation |
|---------|---------------------|----------------|
| Task Reference | Required | Required |
| Constraints Applied | Optional | Required |
| Assumptions | Optional (list if known) | Required (enumerate all) |
| Analysis | Required | Required |
| Validation | Optional (note confidence) | Required (full gate check) |
| Limitations | Recommended | Required |
| Provenance | Optional | Required |
