# {PROJECT_NAME}

{ONE_PARAGRAPH_DESCRIPTION}

---

## Data Sources

| Table | Description | Key Columns |
|-------|-------------|-------------|
| {TABLE_1} | {DESCRIPTION} | {COLUMNS} |
| {TABLE_2} | {DESCRIPTION} | {COLUMNS} |

---

## Key Outcome

{OUTCOME_DESCRIPTION}

Variable: `{OUTCOME_COLUMN}` ({ENCODING_DETAILS})

---

## Analysis Progression

| File | Description | Status |
|------|-------------|--------|
| 010-{NAME} | Data extraction and QC | {STATUS} |
| 110-{NAME} | Exploratory data analysis | {STATUS} |
| 210-{NAME} | Feature engineering | {STATUS} |
| 310-{NAME} | Baseline model | {STATUS} |
| 320-{NAME} | Tuned model | {STATUS} |

---

## Required Packages

```r
pacman::p_load(
  {R_PACKAGES}
)
```

```python
# {PYTHON_PACKAGES}
```

---

## Known Gotchas

- {GOTCHA_1}
- {GOTCHA_2}

---

## Review Checklist

Before committing:

- [ ] No PHI in code or outputs
- [ ] Analysis file numbered correctly (NNN-Description)
- [ ] Key metrics reported with confidence intervals
- [ ] Figures have `fig-cap` and `fig-alt`
- [ ] Tables have `tbl-cap`
- [ ] {PROJECT_SPECIFIC_CHECK}
