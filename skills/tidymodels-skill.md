# Tidymodels Skill Reference

**Last updated:** 2026-03-10
**Scope:** All R projects using tidymodels for modeling, resampling, and uncertainty quantification

---

## Package Ecosystem

### Core (installed with `library(tidymodels)`)

| Package | Purpose | Key Functions |
|---------|---------|---------------|
| **rsample** | Data splitting and resampling | `initial_split()`, `vfold_cv()`, `bootstraps()`, `sliding_index()` |
| **parsnip** | Unified model interface | `linear_reg()`, `rand_forest()`, `boost_tree()`, `set_engine()` |
| **recipes** | Feature engineering pipeline | `recipe()`, `step_*()`, `prep()`, `bake()` |
| **workflows** | Bundle preprocessing + model | `workflow()`, `add_recipe()`, `add_model()` |
| **tune** | Hyperparameter optimization | `tune_grid()`, `tune_bayes()`, `select_best()` |
| **yardstick** | Performance metrics | `rmse()`, `mae()`, `mape()`, `roc_auc()`, `brier_class()` |
| **broom** | Tidy model outputs | `tidy()`, `glance()`, `augment()` |
| **dials** | Tuning parameter definitions | `mtry()`, `trees()`, `min_n()`, `grid_regular()` |

### Extended Ecosystem

| Package | Purpose |
|---------|---------|
| **workflowsets** | Compare many model/recipe combinations |
| **stacks** | Stacked ensemble modeling |
| **finetune** | Racing methods, simulated annealing |
| **probably** | Calibration + conformal prediction intervals |
| **applicable** | Model applicability domain / extrapolation detection |
| **tidyposterior** | Bayesian comparison of resampled models |
| **embed** | Embedding/projection steps (entity embeddings, UMAP) |
| **textrecipes** | Text preprocessing (tokenization, TF-IDF) |
| **themis** | Class imbalance (SMOTE, upsampling) |
| **censored** | Survival models in parsnip |
| **tidyclust** | Clustering models |
| **spatialsample** | Spatial resampling / spatial CV |
| **butcher** | Reduce model object size |
| **hardhat** | Developer toolkit for modeling packages |

---

## Time Series Resampling (rsample)

### Sliding Window Functions (replace `rolling_origin()`)

| Function | Best For | Window Spec |
|----------|----------|-------------|
| `sliding_window()` | Regular series | Row-based: `lookback = 365` |
| `sliding_index()` | Date-indexed series | Duration: `lookback = lubridate::years(2)` |
| `sliding_period()` | Period-grouped | `period = "month"`, `"quarter"`, `"year"` |

### sliding_index() — Primary for time series

```r
library(rsample)
library(lubridate)

splits <- sliding_index(
  daily_data,
  index = date,
  lookback = years(2),      # 2-year training window
  assess_stop = 28,          # 28-day forecast horizon
  step = 7                   # slide by 1 week
)

# Each split has analysis (train) and assessment (test) sets
analysis(splits$splits[[1]])    # training data
assessment(splits$splits[[1]])  # test data
```

### Bootstrap Confidence Intervals

| Function | Method | When to Use |
|----------|--------|-------------|
| `int_pctl()` | Percentile | Simple, needs 1000+ resamples |
| `int_t()` | Student-t | Per-resample variance, fewer resamples |
| `int_bca()` | Bias-corrected accelerated | Most robust, computationally expensive |
| `reg_intervals()` | Convenience wrapper | For lm/glm/survreg |

```r
boot <- bootstraps(data, times = 2000, apparent = TRUE)
# fit model on each resample, extract statistic, then:
int_pctl(boot_results, statistic)
```

### Other Resampling

| Function | Purpose |
|----------|---------|
| `vfold_cv()` | V-fold cross-validation |
| `group_vfold_cv()` | CV respecting group structure |
| `mc_cv()` | Monte Carlo (random splits) |
| `nested_cv()` | Double/nested resampling |
| `loo_cv()` | Leave-one-out |
| `apparent()` | Full training set (for stacking) |

---

## Conformal Inference (probably package)

Distribution-free prediction intervals with finite-sample coverage guarantees.

| Function | Method | Properties |
|----------|--------|------------|
| `int_conformal_split()` | Split conformal | Fast, needs calibration set |
| `int_conformal_full()` | Full conformal | Exact, computationally expensive |
| `int_conformal_cv()` | CV+ | Tighter intervals, uses CV residuals |
| `int_conformal_quantile()` | Conformalized quantile | Heteroscedastic (adaptive width) |

```r
library(probably)

# Split conformal
conformal <- int_conformal_split(fitted_workflow, cal_data)
predict(conformal, new_data, level = 0.90)
# Returns: .pred, .pred_lower, .pred_upper

# CV+ (best for most cases)
cv_results <- fit_resamples(
  workflow, resamples,
  control = control_resamples(save_pred = TRUE, extract = I)
)
conformal_cv <- int_conformal_cv(fitted_workflow, cv_results)
predict(conformal_cv, new_data, level = 0.95)
```

---

## XGBoost via parsnip

### Model Specification

```r
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  min_n = tune(),
  loss_reduction = tune(),     # gamma
  sample_size = tune(),         # subsample
  mtry = tune(),                # colsample_bytree (as proportion with mtry(range = c(0.5, 1)))
  learn_rate = tune()
) |>
  set_engine("xgboost") |>
  set_mode("regression")
```

### With recipes for feature engineering

```r
rec <- recipe(count ~ ., data = train) |>
  update_role(date, new_role = "date") |>
  step_date(date, features = c("dow", "month", "year")) |>
  step_holiday(date, holidays = timeDate::listHolidays("US")) |>
  step_rm(date) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors())
```

### Multi-step forecasting

For multi-step ahead forecasting (like Xin's 14-day output), two strategies:

**Strategy 1: Recursive (one-step model, iterate)**
```r
# Fit one-step-ahead model, feed predictions back as features
# More complex but uses full tidymodels workflow
```

**Strategy 2: Direct (one model per horizon)**
```r
# Fit separate models for h=1, h=7, h=14
# Each model predicts a specific horizon directly
# Simpler, matches Xin's Approach 3 variant
```

**Strategy 3: Multi-output via modeltime**
```r
# modeltime wraps multiple outputs
# Less native to tidymodels but matches Xin's MultiOutputRegressor
```

### Complete XGBoost Workflow

```r
library(tidymodels)

# 1. Split
split <- initial_time_split(data, prop = 0.8)
train <- training(split)
test <- testing(split)

# 2. Recipe
rec <- recipe(count ~ ., data = train) |>
  step_date(date, features = c("dow", "month", "year", "quarter")) |>
  step_holiday(date) |>
  step_rm(date) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors())

# 3. Model spec
xgb_spec <- boost_tree(
  trees = 200, learn_rate = 0.02, tree_depth = 3,
  min_n = 4, sample_size = 0.7, mtry = 0.7,
  loss_reduction = 2.5
) |>
  set_engine("xgboost") |>
  set_mode("regression")

# 4. Workflow
wf <- workflow() |>
  add_recipe(rec) |>
  add_model(xgb_spec)

# 5. Fit
fit <- wf |> fit(data = train)

# 6. Predict
predictions <- predict(fit, new_data = test)

# 7. Evaluate
bind_cols(test, predictions) |>
  metrics(truth = count, estimate = .pred)
```

### Tuning XGBoost

```r
# Grid
xgb_grid <- grid_latin_hypercube(
  trees(range = c(100, 500)),
  tree_depth(range = c(3, 8)),
  min_n(range = c(2, 10)),
  learn_rate(range = c(-3, -1)),  # log scale
  sample_size = sample_prop(range = c(0.5, 1.0)),
  loss_reduction(range = c(-3, 1)),  # log scale: gamma
  size = 30
)

# Time series CV
ts_folds <- sliding_index(
  train, index = date,
  lookback = lubridate::years(2),
  assess_stop = 14, step = 7
)

# Tune
tuned <- tune_grid(
  wf, resamples = ts_folds, grid = xgb_grid,
  metrics = metric_set(rmse, mae, mape),
  control = control_grid(save_pred = TRUE)
)

# Select best and finalize
best <- select_best(tuned, metric = "rmse")
final_wf <- finalize_workflow(wf, best)
final_fit <- fit(final_wf, data = train)
```

---

## Model Comparison with workflowsets

```r
library(workflowsets)

# Define multiple model specs
models <- list(
  ets = ... ,
  arima = ... ,
  xgboost = xgb_spec,
  prophet = ...
)

# Create workflow set
wf_set <- workflow_set(
  preproc = list(base = rec),
  models = models,
  cross = TRUE
)

# Fit all on resamples
results <- wf_set |>
  workflow_map("tune_grid", resamples = ts_folds, grid = 10)

# Compare
autoplot(results)
rank_results(results, rank_metric = "rmse")
```

---

## Calibration (probably)

```r
library(probably)

# For classification
cal <- cal_estimate_logistic(predictions, truth = outcome)
cal_plot_windowed(cal)

# For regression — calibration of prediction intervals
cal_reg <- cal_estimate_linear(predictions, truth = count)
```

---

## Applicability Domain (applicable)

```r
library(applicable)

# PCA-based extrapolation detection
apd <- apd_pca(~ ., data = training_predictors)
scored <- score(apd, new_data = test_predictors)
# High distance = model may not be reliable
```

---

## Key People and Repos

| Person | GitHub | Focus |
|--------|--------|-------|
| Max Kuhn | [@topepo](https://github.com/topepo) | Creator, author of TMwR |
| Hannah Frick | [@hfrick](https://github.com/hfrick) | rsample, workflows, dials |
| Emil Hvitfeldt | [@EmilHvitfeldt](https://github.com/EmilHvitfeldt) | recipes extensions, textrecipes |
| Simon Couch | [@simonpcouch](https://github.com/simonpcouch) | probably (conformal), stacks |
| Julia Silge | [@juliasilge](https://github.com/juliasilge) | Education, TMwR co-author |
| Davis Vaughan | [@DavisVaughan](https://github.com/DavisVaughan) | slider, vctrs, hardhat |

**GitHub org:** [github.com/tidymodels](https://github.com/tidymodels) (62 repos)
**Book:** [Tidy Modeling with R](https://www.tmwr.org/) (free online)

---

## Decision Tree: When to Use What

| Task | Package | Approach |
|------|---------|----------|
| Quick baseline | parsnip | `linear_reg()`, `rand_forest()` with defaults |
| Feature engineering | recipes | `step_*()` pipeline |
| Hyperparameter tuning | tune + dials | `tune_grid()` or `tune_bayes()` |
| Time series CV | rsample | `sliding_index()` |
| Compare many models | workflowsets | `workflow_set()` + `workflow_map()` |
| Ensemble | stacks | `stacks()` + `add_candidates()` |
| Prediction intervals | probably | `int_conformal_cv()` |
| Model deployment | vetiver | `vetiver_model()` + `vetiver_pin_write()` |
| Extrapolation check | applicable | `apd_pca()` + `score()` |

---

## Common Pitfalls

1. **Don't use `initial_split()` for time series** — use `initial_time_split()` or `sliding_index()`
2. **`mtry` in XGBoost** — parsnip maps it to `colsample_bytree`; use `mtry(range = c(0.5, 1.0))` with `finalize()` or pass proportions
3. **`step_normalize()` before `step_dummy()`** — dummies should not be normalized
4. **Forgetting `set_mode()`** — parsnip won't infer regression vs classification
5. **`tune()` placeholders** — must be filled before fitting (via `finalize_workflow()`)
