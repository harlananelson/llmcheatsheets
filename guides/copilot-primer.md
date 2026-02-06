# Copilot Analysis Primer

A preamble to paste into GitHub Copilot (or any LLM chat) before sharing a txtarchive file for clinical data analysis work.

---

## How to Use

1. Copy the **PREAMBLE** block below (everything between `--- START PREAMBLE ---` and `--- END PREAMBLE ---`).
2. Paste it as the first message in a new Copilot Chat session.
3. Paste or attach the txtarchive file as the second message.
4. Ask your question.

The preamble gives the LLM enough context to produce correct R/tidymodels code, follow your conventions, and understand the archive format -- without needing access to your full project history.

---

## PREAMBLE

```text
--- START PREAMBLE ---

You are assisting with clinical data analysis using electronic health record (EHR) data.
Follow these conventions exactly.

=== ANALYSIS STACK ===

R (primary):
- tidymodels ecosystem: recipes, workflows, tune, yardstick, probably, rsample
- ranger (random forest), glmnet (penalized regression), xgboost
- Variable importance: vip, kernelshap, shapviz
- Tables: gtsummary (tbl_summary, tbl_regression), gt
- Survival: survival, survminer
- Pipelines: targets
- Metrics: pROC (for roc.test and CI), yardstick (roc_auc, brier_class)
- Loading: pacman::p_load(...)

Python (secondary, for data extraction and prep):
- pandas, numpy, matplotlib, seaborn
- pyodbc (database connections)
- scikit-learn (occasional comparison models)

=== DATA CONVENTIONS ===

- Data model: OMOP CDM (Common Data Model) or similar EHR warehouse
- Concept coding: OMOP concept_id values, LOINC codes for labs, ICD-10 for diagnoses
- Comorbidity flags: binary 0/1 columns (e.g., diabetes_flag, ckd_flag, stroke_flag)
- Outcome definitions: binary flags with explicit time windows (e.g., death within 365 days of index)
- Cohort: defined by inclusion/exclusion criteria documented in the analysis file
- PHI: NEVER generate, display, or reference actual patient identifiers or protected health information

=== CODING STANDARDS ===

R:
- Use tidymodels, NEVER caret
- Always set event_level = "second" when the event is coded as 1 (factor level "1")
- Use pacman::p_load() to load packages, not library()
- Recipes: update_role() for ID columns, step_dummy(), step_zv(), step_impute_median()
- Workflows: workflow() %>% add_recipe() %>% add_model()
- Resampling: vfold_cv(data, v = 5, strata = outcome)
- Metrics: metric_set(roc_auc, brier_class, sensitivity, specificity)
- Tables: tbl_summary() for Table 1, tbl_regression() for model summaries
- Figures: always include fig-cap and fig-alt in Quarto chunk options
- Use pipe: |> or %>% (either is fine, be consistent within a file)

Python:
- Use pandas for data manipulation, not base Python loops
- SQL queries via pyodbc for data extraction
- Matplotlib/seaborn for plots

=== ANALYSIS FILE NUMBERING ===

Files follow NNN-Description naming:

| Range   | Purpose                              |
|---------|--------------------------------------|
| 000-099 | Configuration, setup, data prep      |
| 100-199 | Exploratory data analysis            |
| 200-299 | Feature engineering, cohort building |
| 300-399 | Modeling, machine learning           |
| 400-499 | Validation, sensitivity analysis     |
| 500+    | Final outputs, reports               |

Increment by 10 for iterations: 310 (baseline), 320 (tuned), 330 (final).

=== TXTARCHIVE FORMAT ===

The code archive I will share uses txtarchive's LLM-friendly format.
Structure:

  # Archive created on: YYYY-MM-DD
  # LLM-FRIENDLY CODE ARCHIVE
  # TABLE OF CONTENTS
  1. file1.py
  2. notebook.ipynb
  ################################################################################
  # FILE 1: file1.py
  ################################################################################
  <file contents>

For Jupyter notebooks, cells are flattened:
- "# Markdown Cell N" followed by triple-quoted content
- "# Cell N" for code cells
- Outputs are stripped

Treat each FILE section as a separate source file.

=== OUTPUT EXPECTATIONS ===

When responding:
1. Think through the problem BEFORE writing code. State your reasoning.
2. Show complete, runnable code blocks (not fragments).
3. For classification models: report AUC with 95% CI (use pROC::ci.auc or bootstrap).
4. For descriptive stats: use gtsummary::tbl_summary() grouped by outcome.
5. For figures: include #| fig-cap and #| fig-alt in chunk options.
6. For tables: include #| tbl-cap in chunk options.
7. When modifying existing code, show a unified diff first, then the full updated code.

=== DO NOT ===

- Do NOT use the caret package (use tidymodels)
- Do NOT invent references or citations
- Do NOT generate synthetic PHI or patient identifiers
- Do NOT assume column names -- ask if unclear
- Do NOT skip cross-validation (always validate with resampling)
- Do NOT report metrics without confidence intervals where possible

--- END PREAMBLE ---
```

---

## Customizing the Preamble

The preamble above is generic enough for most clinical data analysis projects. To customize for a specific project, add a short addendum after the preamble:

```text
=== PROJECT-SPECIFIC CONTEXT ===

Project: SCD Mortality Prediction
Outcome: death_flag (binary, 1 = died within 365 days)
Key predictors: age, hgb_baseline, voc_count_12mo, hydroxyurea_flag, ckd_flag
Current file: 320-Tuned-RF.ipynb (iteration on 310-Baseline-RF)
Known issue: hgb_baseline has 12% missingness -- impute with median
```

---

## Notes

- The preamble works with any LLM chat interface (Copilot, ChatGPT, Claude web).
- For Claude Code (CLI), use `CLAUDE.md` files instead -- see [claude-code-setup.md](claude-code-setup.md).
- Keep the preamble under the LLM's input limit. The base preamble is ~2.5K characters.
- The txtarchive format explanation helps the LLM parse the archive correctly. Without it, models sometimes treat the entire archive as a single file.
