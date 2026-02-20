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

## Data Profiling Protocol

**Before writing any analytical code**, profile every dataset:

1. **Schema:** `glimpse(data)` / `data.info()` — verify column names and types
2. **Categoricals:** `count(field)` — inspect actual values (never assume types)
3. **Numerics:** `summary()` — check ranges, zeros, NAs
4. **Dates:** `class()` + `range()` — confirm correct class
5. **Join keys:** Verify type compatibility across tables
6. **Code fields:** Test regex patterns against real data before building analysis

Add a profiling cell as Cell 2 in every notebook (after setup, before analysis).

**Full reference:** See `data-profiling` skill in llmcheatsheets/skills/.

---

## Review Checklist

Before committing:

- [ ] No PHI in code or outputs
- [ ] Analysis file numbered correctly (NNN-Description)
- [ ] Key metrics reported with confidence intervals
- [ ] Figures have `fig-cap` and `fig-alt`
- [ ] Tables have `tbl-cap`
- [ ] {PROJECT_SPECIFIC_CHECK}
