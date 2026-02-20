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
│   ├── settings.local.json  # Project-specific permissions
│   └── rules/             # Ontology rules files (auto-loaded every session)
│       ├── ontology-schema.md
│       ├── domain-constraints.md
│       ├── assumption-registry.md
│       └── ...
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

## Project Ontology Architecture

**When setting up a new project**, use the ontology scaffold to organize Claude Code configuration as a typed knowledge system rather than a flat instruction file.

### Tiered Framework

The architecture supports three levels of depth. Choose based on project needs:

| Level | Purpose | When to Use |
|-------|---------|-------------|
| **Level 1** | Organizational reasoning | Project management, workflows, general analysis |
| **Level 2** | Domain-native ontology | Domain objects ARE the product (knowledge graphs, extraction) |
| **Level 3** | Multi-agent negotiation | Multiple agents/extractors need reconciliation |

See Section 10 of the architecture guide for the full framework, decision tree, and comparison tables.

### Bootstrapping a New Project

When asked to "set up the ontology" or "scaffold this project":

1. **Generic templates (Level 1 — start here):** `{PROJECTS_ROOT}/llmcheatsheets/templates/ontology-scaffold/`
   - Ready-to-customize templates with `{PLACEHOLDER}` syntax
   - `CLAUDE.md.template` + 7 rules files (ontology-schema, constraints, assumptions, authority-scoring, method-decision-tree, validation-gates, output-conventions)
   - See `README.md` in that directory for usage and placeholder reference
2. **Architecture guide (explains why + tiered framework):** `{PROJECTS_ROOT}/llmcheatsheets/guides/claude-code-architecture-review.md`
   - Maps Claude Code layers (CLAUDE.md, `.claude/rules/`, memory/) to ontology functions
   - Phase 1a-1c roadmap for extraction and scaffolding
   - Section 10: Tiered framework — Levels 1/2/3 with decision tree

### Quick Start Phrase

The user can say any of these to trigger scaffolding:
- "Set up the ontology for this project"
- "Scaffold this project"
- "Use the ontology templates to organize this project"

---

## Halt on Contradiction (Critical)

When a user's request implies something exists (file has content, column is present, service is running) and reality contradicts that (file is empty, column missing, service down): **stop all dependent work immediately**. Do not work around it, guess, or ask soft questions. State clearly what was expected vs. what was found, and wait for the user to resolve the discrepancy. The cost of one clarification round-trip is always less than an entire chain of work built on a false premise. This applies in interactive conversations; in batch workflows, log the contradiction and skip dependent work.

See: `{PROJECTS_ROOT}/llmcheatsheets/guides/claude-code-architecture-review.md` → "Halt on Contradiction" for the full protocol.

---

## Data Profiling Before Analysis (Critical)

**Principle:** Understanding the data is always the first step before writing analytical code.
Every failed analysis traces back to an unchecked assumption about data structure, types, or values.

**Before writing any analytical code**, verify:

1. **Schema:** Column names and types match expectations (`class()`, `glimpse()`, `data.info()`)
2. **Categorical values:** Inspect actual values with counts — never assume types
3. **Numeric ranges:** Check for plausibility, zeros-as-missing, sentinel values
4. **Date classes:** Confirm correct class (Date vs character vs IDate)
5. **Join keys:** Verify type compatibility across tables before joining
6. **Code fields:** Test regex patterns against actual data before building analysis around them

**When to re-profile:** After type-changing mutations, after joins, after filters, and
whenever encountering unexpected results.

**Full skill reference:** `{PROJECTS_ROOT}/llmcheatsheets/skills/data-profiling-skill.md`

---

## Notes

- This file is loaded automatically for all projects under `{PROJECTS_ROOT}`
- Project-specific CLAUDE.md files add context, they don't replace this
- When in doubt, check txtarchive README: `{PROJECTS_ROOT}/txtarchive/README.md`
- Full Quarto reference: `{PROJECTS_ROOT}/llmcheatsheets/skills/quarto-skill.md`
- Ontology templates: `{PROJECTS_ROOT}/llmcheatsheets/templates/ontology-scaffold/`
- Architecture guide: `{PROJECTS_ROOT}/llmcheatsheets/guides/claude-code-architecture-review.md`
- Data profiling skill: `{PROJECTS_ROOT}/llmcheatsheets/skills/data-profiling-skill.md`
