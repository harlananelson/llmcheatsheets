# Rhino Shiny App Development Skill

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer) or paste into an LLM session for Rhino/Shiny app development. Covers `box` module pitfalls, Rhino project structure, pre-computed data dashboards, and debugging patterns.

Comprehensive reference for building Shiny apps with the Rhino framework and `box` modules.
Emphasizes practical lessons from real deployments — especially the `box` module isolation model
that breaks many common R patterns.

---

## 1) Rhino Project Structure

```
my-app/
├── app.R                 # Entry point: rhino::app()
├── rhino.yml             # Rhino config (sass, linter settings)
├── config.yml            # Required by config package (Rhino dependency)
├── dependencies.R        # Package declarations for renv/rhino
├── app/
│   ├── main.R            # Top-level UI + server (box modules)
│   ├── static/           # MUST exist (even if empty — add .gitkeep)
│   ├── styles/
│   │   └── main.scss     # SASS styles
│   ├── data/             # App data files (RDS, CSV, etc.)
│   ├── logic/            # Business logic modules
│   │   ├── data_loader.R
│   │   ├── config_manager.R
│   │   └── plot_helpers.R
│   └── view/             # UI + server module pairs
│       ├── overview.R
│       ├── feature_toggle.R
│       └── ...
└── tests/
    └── testthat/
```

### Required Files (Rhino will error without these)

| File | Why | Error if missing |
|------|-----|-----------------|
| `app/static/` | `addResourcePath("static", ...)` called on startup | `Couldn't normalize path in addResourcePath` |
| `config.yml` | `config::get()` called by Rhino | `Config file config.yml not found` |
| `rhino.yml` | Rhino configuration | Warning: `Neither 'rhino.yml' nor 'rhino.yaml' found` |

### Minimal config.yml

```yaml
default:
  rhino_log_level: !expr Sys.getenv("RHINO_LOG_LEVEL", "INFO")
```

### Minimal rhino.yml

```yaml
sass: r
```

**IMPORTANT:** Use `sass: r` (not `sass: node`) unless Node.js is installed. `sass: node` requires a Node.js runtime for SCSS compilation. `sass: r` uses the R `sass` package.

---

## 2) Box Module Isolation (CRITICAL — Most Common Error Source)

Rhino uses the `box` package for module imports. Box modules run in **isolated environments** — they do NOT have access to the global R namespace. This breaks many common R patterns.

### What IS Available in Box Modules

- `base` package functions: `paste`, `paste0`, `cat`, `sprintf`, `round`, `format`, `is.na`, `is.null`, `nrow`, `ncol`, `ifelse`, `c`, `list`, `data.frame`, `tryCatch`, `message`, `warning`, `stop`, `Sys.time`, etc.
- Functions explicitly imported via `box::use()`
- Functions called with `pkg::function()` syntax

### What is NOT Available (Common Traps)

| Function | Package | Fix |
|----------|---------|-----|
| `reorder()` | `stats` | Use `stats::reorder()` |
| `setNames()` | `stats` | Use `stats::setNames()` |
| `median()` | `stats` | Use `stats::median()` |
| `quantile()` | `stats` | Use `stats::quantile()` |
| `sd()` | `stats` | Use `stats::sd()` |
| `cor()` | `stats` | Use `stats::cor()` |
| `predict()` | `stats` | Use `stats::predict()` |
| `reshape()` | `stats` | Use `stats::reshape()` |

**Rule of thumb:** If a function is in `stats`, `utils`, `grDevices`, or `methods` — it needs explicit namespacing or `box::use()` import in Rhino modules.

### Import Patterns

```r
# CORRECT: Import specific functions
box::use(
  dplyr[filter, mutate, select, arrange],
  ggplot2[...],  # ... imports everything from ggplot2
  stats[reorder, setNames],  # Explicit stats imports
)

# CORRECT: Use inline namespacing (no import needed)
stats::reorder(x, y)
stats::setNames(vec, names)

# WRONG: Assuming stats functions are available
reorder(x, y)  # Error: could not find function "reorder"
setNames(vec, names)  # Error: could not find function "setNames"
```

---

## 3) Tidy Eval (`!!`) Does Not Work Reliably in Box Modules

The `!!` (bang-bang) operator from `rlang` may not work inside `box` module environments, even when `dplyr` is imported. This causes **silent failures** in `filter()` calls where column names match local variable names.

### The Problem

```r
# This FAILS silently in box modules:
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    observe({
      run <- input$run  # local variable "run"

      # BUG: !!run may not work — filter returns 0 rows silently
      result <- data |> filter(run == !!run)
    })
  })
}
```

When `!!` doesn't work, `run == !!run` becomes `run == !(!run)`, which evaluates to nonsense and the filter returns no rows. The UI shows empty dropdowns/tables with no error message.

### The Fix: Rename Local Variables to Avoid Column Name Conflicts

```r
# CORRECT: Use a different variable name than the column
observe({
  run_selected <- input$run  # different name than column "run"
  ds_val <- input$dataset    # different name than column "dataset"

  result <- data |> filter(run == run_selected, dataset == ds_val)
})
```

**Convention:** Use `_selected`, `_val`, or `_input` suffixes for local variables that correspond to column names:
- `run` column → `run_selected` or `run_val` local var
- `dataset` column → `ds_val` local var
- `config_id` column → `config_selected` local var

### Also Applies to Non-Shiny Functions

```r
# In logic modules:
get_ablation_impact <- function(ablation_results, run = "A", dataset = "test") {
  run_val <- run        # Rename to avoid column name conflict
  ds_val <- dataset

  ablation_results |>
    filter(run == run_val, dataset == ds_val)
}
```

---

## 4) Box + gt Package: Import Conflict

When importing `gt` functions via `box::use()`, the function `gt()` can shadow the module namespace, making `gt$gt_output()` and `gt$render_gt()` fail.

### The Problem

```r
box::use(
  gt[gt, tab_header, fmt_number],  # "gt" now refers to the gt() function
)

# BUG: "gt" is the gt() function (a closure), not the module
# gt$gt_output() tries to subset a function → error
ui <- function(id) {
  gt$gt_output(ns("table"))  # Error: object of type 'closure' is not subsettable
}
```

### The Fix: Import All Needed Functions Directly

```r
box::use(
  gt[gt, gt_output, render_gt, tab_header, fmt_number, fmt_percent, cols_label, cols_align],
)

# Use directly — no module prefix
ui <- function(id) {
  gt_output(ns("table"))  # Works
}

server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$table <- render_gt({  # Works
      data |> gt() |> tab_header(title = "My Table")
    })
  })
}
```

---

## 5) Pre-Computed Data Dashboard Pattern

For dashboards that display results from expensive computations (ML models, SHAP, etc.), pre-compute everything in a notebook and save as RDS files. The Shiny app only reads and displays — no computation at runtime.

### Notebook → RDS → Shiny Pipeline

```
[Notebook: 400-Pre-Compute.ipynb]
  ├── Train models (62 configs)
  ├── Extract metrics, ROC coords, importance
  ├── Privacy verification (no patient IDs)
  └── Save 13 RDS files → app/data/

[Shiny: 400-Model-Explorer/]
  ├── Load RDS at startup (data_loader.R)
  ├── Filter by config_id (feature_filter.R)
  └── Display plots/tables (view modules)
```

### Data Loader Pattern

```r
#' @export
load_all <- function(data_dir = "app/data") {
  files <- c("ablation_results", "roc_curves", "variable_importance", ...)
  data <- list()
  for (f in files) {
    path <- file.path(data_dir, paste0(f, ".rds"))
    if (file.exists(path)) {
      data[[f]] <- readRDS(path)
    } else {
      warning(paste("Missing:", path))
      data[[f]] <- NULL
    }
  }
  data
}
```

### Module Wiring Pattern

```r
# main.R
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- data_loader$load_all()  # Load once at startup

    # Producer module: returns reactive of selected config_ids
    selected_configs <- feature_toggle$server("feature_toggle", data = data)

    # Consumer modules: receive data + selected configs
    overview$server("overview", data = data, selected_configs = selected_configs)
    roc_comparison$server("roc", data = data, selected_configs = selected_configs)
  })
}
```

### Config-Based Filtering

Tag every row in every RDS file with `config_id` and `dataset`. This enables a single, universal filter:

```r
# feature_filter.R
#' @export
by_config_dataset <- function(data, config_ids, datasets = c("test", "external")) {
  data |> filter(config_id %in% config_ids, dataset %in% datasets)
}
```

---

## 6) Running Rhino Apps

### Local Development

```r
setwd("path/to/my-app")  # Must be the app root (where app.R lives)
rhino::app()
```

### Working Directory Matters

Rhino resolves all paths relative to the working directory. If you get path errors:
- `getwd()` must return the directory containing `app.R`
- Do NOT `setwd("app/")` — stay in the project root

### Common Startup Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Couldn't normalize path... 'static'` | `app/static/` doesn't exist | `mkdir -p app/static && touch app/static/.gitkeep` |
| `Config file config.yml not found` | Missing `config.yml` | Create minimal config.yml (see §1) |
| `Neither 'rhino.yml' nor 'rhino.yaml' found` | Missing or wrong directory | Create `rhino.yml` in project root |
| `object of type 'closure' is not subsettable` | Box import conflict (see §4) | Import functions directly, don't use `module$function` when function name conflicts |
| `could not find function "X"` | Function from `stats`/`utils` not available in box module | Use `stats::X()` or `utils::X()` |
| Dropdown/table silently empty | `!!` tidy eval failing in box module (see §3) | Rename local variables to avoid column name conflicts |

---

## 7) Debugging Rhino Apps

### Silent Failures Are the Biggest Risk

Box module isolation means errors often manifest as **empty outputs** rather than error messages. If a dropdown is empty or a plot shows "No data":

1. Check the R console for warnings (not errors — warnings are the signal)
2. Add `cat()` or `message()` statements inside `observe()` and `reactive()` to trace data flow
3. Test the data loading independently: `d <- readRDS("app/data/file.rds"); str(d)`
4. Test filters independently: `d |> dplyr::filter(run == "A") |> nrow()`

### Module Cache

Box caches modules aggressively. After editing a module file:
- Restart R (`Ctrl+Shift+F10` in RStudio) to clear the cache
- Or use `box::reload()` if available

---

## 8) Dependencies

### dependencies.R

This file declares packages for `renv` and `rhino::pkg_install()`:

```r
library(rhino)
library(shiny)
library(bslib)
library(ggplot2)
library(scales)
library(gt)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(glue)
library(htmltools)
```

### bslib Components (Modern Shiny UI)

Rhino apps typically use `bslib` for layout:

```r
box::use(
  bslib[page_navbar, nav_panel, nav_spacer, layout_sidebar, sidebar,
        card, card_header, card_body, value_box, layout_column_wrap, bs_theme],
)
```

Key components:
- `page_navbar()` — top-level navigation with tabs
- `layout_sidebar()` — sidebar + main content
- `card()` — container for plots/tables
- `value_box()` — KPI display (AUC, N, etc.)
- `layout_column_wrap()` — responsive grid layout

---

## 9) Checklist: New Rhino App

1. [ ] Create project structure (see §1)
2. [ ] Create `app/static/.gitkeep` (empty dir causes errors)
3. [ ] Create `config.yml` with minimal config
4. [ ] Set `rhino.yml` to `sass: r` (unless Node.js is installed)
5. [ ] In all `box::use()` imports:
   - Import `gt_output` and `render_gt` directly (not via `gt$`)
   - Use `stats::reorder()`, `stats::setNames()` inline
   - Never use `!!` for column name disambiguation — rename local variables instead
6. [ ] Test data loading independently before building UI
7. [ ] Add `req()` guards in all reactive/render functions
8. [ ] Test each tab individually during development
