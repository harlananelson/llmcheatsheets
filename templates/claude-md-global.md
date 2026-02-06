# Global Project Context

This is the authority for all projects under `{PROJECTS_ROOT}`. Project-specific CLAUDE.md files extend this.

---

## TxtArchive - Code Archiving Tool

**Location:** `{PROJECTS_ROOT}/txtarchive/`
**Repo:** {TXTARCHIVE_REPO_URL}

### Purpose
Creates text-based archives of codebases for LLM analysis and file transfer.

### Two Archive Formats

| Format | Header Pattern | Use Case |
|--------|---------------|----------|
| **Standard** | `---\nFilename: path/file\n---` | Exact reconstruction |
| **LLM-Friendly** | `# FILE N: path/file\n###...###` | AI analysis (preferred) |

### Common Commands

```bash
# Create LLM-friendly archive (for AI analysis)
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb .qmd .R \
    --llm-friendly \
    --extract-code-only

# Create archive of specific files
python -m txtarchive archive myproject/ output.txt \
    --explicit-files file1.ipynb file2.py \
    --llm-friendly

# Unpack archive (auto-detects format)
python -m txtarchive unpack archive.txt output_dir/ --replace_existing

# Extract notebooks from LLM-friendly archive
python -m txtarchive extract-notebooks archive.txt output_dir/
```

### When to Create Archives

- Before sharing code with LLMs for review/modification
- To document analysis state at a point in time
- To transfer code between environments

---

## Analysis Versioning Convention

Analysis files follow a numbered progression to document evolution:

```
NNN-Description.ipynb    # Jupyter notebook
NNN-Description.qmd      # Quarto document
NNN-Description.txt      # LLM-friendly archive of the notebook
NNN-Description.html     # Rendered output
```

### Numbering Scheme

| Range | Purpose |
|-------|---------|
| 000-099 | Configuration, setup, data preparation |
| 100-199 | Exploratory data analysis |
| 200-299 | Feature engineering, cohort building |
| 300-399 | Modeling, machine learning |
| 400-499 | Validation, sensitivity analysis |
| 500+ | Final outputs, reports |

### Incrementing Versions

When extending an analysis:
- **310** = baseline model
- **320** = next iteration (adds features, fixes issues)
- **330** = further iteration

Always keep previous versions -- they document the analytical journey.

---

## GitHub Integration

### Accessing Private Repos

```bash
# Check auth status
gh auth status

# View issues
gh issue view <number> --repo owner/repo

# List issues
gh issue list --repo owner/repo
```

### Issue-Driven Development

When working on GitHub issues:
1. Read the full issue with `gh issue view`
2. Create analysis file numbered appropriately
3. Reference issue number in commits
4. Create txtarchive of completed work

---

## Project Structure Conventions

```
project/
├── CLAUDE.md              # Project-specific context (extends this global)
├── .claude/
│   └── settings.local.json  # Project-specific permissions
├── paper/                 # Publication-ready analyses
│   └── {STUDY_NAME}/
│       ├── 310-Analysis.ipynb
│       ├── 310-Analysis.txt   # LLM archive
│       └── 310-Analysis.html  # Rendered output
├── examples/              # Working/development versions
├── R/                     # R functions
└── _targets/              # targets pipeline cache
```

---

## R/tidymodels Context

Many analyses use R with tidymodels ecosystem:

### Key Packages
- **tidymodels**: ML framework (recipes, workflows, tune)
- **ranger**: Random forest implementation
- **yardstick**: Model metrics (roc_auc, brier_class)
- **probably**: Calibration, thresholds
- **vip**: Variable importance
- **gtsummary**: Summary tables (tbl_summary)
- **gt**: Table formatting
- **targets**: Pipeline orchestration

### Common Patterns

```r
# Recipe for preprocessing
recipe(outcome ~ ., data = train) %>%
  update_role(id_cols, new_role = "id") %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_impute_median(all_numeric_predictors())

# Workflow
workflow() %>%
  add_recipe(my_recipe) %>%
  add_model(rand_forest(mode = "classification", mtry = tune(), min_n = tune()))

# Cross-validation
vfold_cv(data, v = 5, strata = outcome)
```

---

## Quarto Document Authoring

**Full reference:** `{PROJECTS_ROOT}/llmcheatsheets/skills/quarto-skill.md`

### Key Workflow: Jupyter-First (No Re-Execution)

`.ipynb` files rendered with `quarto render` preserve pre-computed outputs by default.

```bash
quarto render notebook.ipynb
quarto render notebook.ipynb --to html
quarto render notebook.ipynb --to pdf
```

### Cross-Reference Prefixes

`#fig-` (Figure), `#tbl-` (Table), `#eq-` (Equation), `#sec-` (Section). Reference with `@fig-name`, etc. Labels must be lowercase with hyphens (not underscores).

### Citation Syntax

```yaml
bibliography: references.bib
csl: style.csl
```

`[@key]` parenthetical, `@key` narrative, `[-@key]` year only, `[@a; @b]` multiple.

---

## Notes

- This file is loaded automatically for all projects under `{PROJECTS_ROOT}`
- Project-specific CLAUDE.md files add context, they don't replace this
- When in doubt, check txtarchive README: `{PROJECTS_ROOT}/txtarchive/README.md`
- Full Quarto reference: `{PROJECTS_ROOT}/llmcheatsheets/skills/quarto-skill.md`
