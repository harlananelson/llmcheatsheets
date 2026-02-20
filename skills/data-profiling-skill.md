# Data Profiling Skill — Understand Before You Analyze

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer or skill trigger) or paste
> into an LLM session before any data analysis work. Ensures data schema, field types, value
> distributions, and structural assumptions are verified before writing analytical code.

**Principle:** A thorough understanding of the data is always the first step before writing
analysis. Every failed analysis can be traced back to an assumption about the data that was
never checked. The cost of 5 minutes of profiling is always less than hours debugging code
built on wrong assumptions.

---

## 1) When This Skill Activates

This skill should be invoked **before** writing any analytical code when:

- Loading a new dataset for the first time
- Starting a new analysis notebook (any NNN-series file)
- Encountering unexpected results (zeros, NAs, type errors)
- Joining two tables that haven't been joined before
- Using a column that hasn't been inspected in this session

**Do NOT skip profiling because:**
- You "already know" the schema (it may have changed)
- The column name seems self-explanatory (`deceased` could be logical, factor, or character)
- Previous code worked (the data may have been updated/re-extracted)

---

## 2) The Profiling Protocol

### Step 1: Schema Inventory

Before writing any analytical code, run the equivalent of:

```r
# R
str(data)                          # Structure: types, first values
glimpse(data)                      # Tidyverse alternative
names(data)                        # Column names exactly
sapply(data, class)                # Class of every column
dim(data)                          # Rows x columns
```

```python
# Python
data.info()                        # dtypes, non-null counts
data.dtypes                        # Column types
data.shape                         # Rows x columns
data.columns.tolist()              # Column names exactly
```

**What to verify:**
- Column names match what your code expects (case-sensitive, underscores vs dots)
- Types match your assumptions (logical vs factor vs character vs numeric)
- No unexpected columns or missing expected columns

### Step 2: Categorical Field Profiling

For every categorical/factor/character column you plan to use:

```r
# R — value counts with patient counts
data |> count(field_name, sort = TRUE)

# For logical fields — confirm TRUE/FALSE, not "yes"/"no" or 0/1
table(data$field_name, useNA = "ifany")
class(data$field_name)
```

```python
# Python
data['field_name'].value_counts(dropna=False)
data['field_name'].dtype
```

**What to verify:**
- Actual values match what your code checks for
  - `deceased == "died"` fails if deceased is logical (TRUE/FALSE)
  - `filter(scd == "Sickle Cell")` fails if scd is logical
- No unexpected NA/NULL patterns
- Factor levels are what you expect (not numeric codes)
- Character encoding is consistent (no mixed case, trailing spaces)

### Step 3: Numeric Field Profiling

For every numeric column you plan to use:

```r
# R
summary(data$numeric_col)          # Min, Q1, median, mean, Q3, max, NAs
data |> summarise(
  n = n(),
  n_na = sum(is.na(numeric_col)),
  n_zero = sum(numeric_col == 0, na.rm = TRUE),
  min = min(numeric_col, na.rm = TRUE),
  max = max(numeric_col, na.rm = TRUE)
)
```

```python
# Python
data['numeric_col'].describe()
data['numeric_col'].isna().sum()
```

**What to verify:**
- Range is plausible (age should be 0-120, not 1900-2025)
- Zeros mean "zero" not "missing" (common in EHR data)
- No sentinel values (-999, 9999, -1)
- Units are what you expect

### Step 4: Date Field Profiling

```r
# R
class(data$date_col)               # Date? POSIXct? character? IDate?
range(data$date_col, na.rm = TRUE) # Plausible range?
sum(is.na(data$date_col))          # Missing count
```

**What to verify:**
- Class is actually Date (not character string, not IDate, not numeric)
- Range is plausible (no dates in 1900 or 2099)
- Timezone handling if POSIXct

### Step 5: Join Compatibility

Before joining two tables:

```r
# R — check key types match
class(left_table$key_col)          # factor? character? integer?
class(right_table$key_col)         # Must match!

# Check for key completeness
anti_join(left_table, right_table, by = "key_col") |> nrow()  # Unmatched left
anti_join(right_table, left_table, by = "key_col") |> nrow()  # Unmatched right

# Check for duplicates in the key
right_table |> count(key_col) |> filter(n > 1)  # 1:many?
```

**What to verify:**
- Key types match exactly (factor vs integer vs character will silently fail or error)
- Understand the join cardinality (1:1, 1:many, many:many)
- Know how many rows you expect after the join

### Step 6: ICD/Code Field Profiling (Healthcare-Specific)

When working with ICD codes, medication codes, or procedure codes:

```r
# What code systems are present?
data |> count(str_sub(code_col, 1, 1), sort = TRUE)  # First character distribution

# Do your regex patterns match anything?
test_pattern <- "^F3[0-9]"  # Example: mood disorder codes
data |> filter(str_detect(code_col, test_pattern)) |> nrow()

# What does the code column actually contain?
data |> distinct(code_col) |> slice_sample(n = 20)  # Random sample
```

**What to verify:**
- The column contains actual codes (not display names, not mixed)
- Your regex patterns match real data (test before building analysis around them)
- The code system you expect (ICD-10) is what's actually present (might be ICD-9 or SNOMED)

---

## 3) The Profiling Cell Template

For Jupyter/Quarto notebooks, add this as Cell 2 (right after setup/loading):

```r
# ============================================================================
# DATA PROFILING — Verify structure before analysis
# ============================================================================

cat("=== Dataset Structure ===\n")
cat("Rows:", nrow(data), "| Columns:", ncol(data), "\n\n")

cat("=== Column Classes ===\n")
col_classes <- tibble(
  column = names(data),
  class = sapply(data, \(x) paste(class(x), collapse = ", ")),
  n_unique = sapply(data, n_distinct),
  n_na = sapply(data, \(x) sum(is.na(x))),
  pct_na = round(sapply(data, \(x) mean(is.na(x))) * 100, 1)
)
print(col_classes, n = Inf)

cat("\n=== Key Categorical Fields ===\n")
# Profile every categorical field your analysis will use
key_cats <- c("deceased", "gender", "scd", "shah_class")  # Customize
for (col in intersect(key_cats, names(data))) {
  cat("\n", col, " (class:", paste(class(data[[col]]), collapse = ","), "):\n")
  print(table(data[[col]], useNA = "ifany"))
}

cat("\n=== Key Numeric Summaries ===\n")
key_nums <- c("age", "time_from_first_touch_to_death_event")  # Customize
data |>
  select(any_of(key_nums)) |>
  summary() |>
  print()
```

---

## 4) Common Traps This Prevents

| Trap | What Happens | Profiling Catches It |
|------|-------------|---------------------|
| Logical vs factor | `deceased == "died"` → always FALSE | Step 2: `class()` + `table()` |
| Factor vs integer keys | `left_join()` silently drops rows or errors | Step 5: `class()` comparison |
| IDate corruption | data.table IDate stored as double → vctrs error | Step 4: `class()` check |
| No codes in table | Regex matches 0 rows → analysis produces all zeros | Step 6: test regex first |
| Character "None" vs NA | `sum(col)` fails; need `sum(col != "None")` | Step 2: `table()` shows values |
| Column name mismatch | `year_of_birth` doesn't exist, `yearofbirth` does | Step 1: `names()` |
| Lookback from first touch | Filtering events before first encounter → 0 results | Step 3: date range check |

---

## 5) Integration with Analysis Workflow

### Where Profiling Fits

```
1. Load data                    ← Cell 1: packages + data loading
2. PROFILE DATA                 ← Cell 2: this skill's template
3. Fix data issues              ← Cell 3: type conversions, cleaning
4. Begin analysis               ← Cell 4+: actual analytical work
```

### When to Re-Profile

- After any `mutate()` that changes types
- After joining tables (check result dimensions)
- After filtering (verify non-zero result)
- When encountering unexpected results (go back to profiling)

### Relationship to Validation Gates

Data profiling is **Gate 0** — it must pass before any other validation gate
(rendering, content completeness, statistical validity) is meaningful. An analysis
built on misunderstood data cannot be validated, only rebuilt.

---

## 6) Language-Specific Quick Reference

### R (tidyverse)

```r
# One-liner comprehensive profile
skimr::skim(data)                  # If skimr is available

# Without skimr
glimpse(data)
map(data, \(x) list(class = class(x), n_unique = n_distinct(x), n_na = sum(is.na(x))))
```

### Python (pandas)

```python
# One-liner comprehensive profile
data.describe(include='all')

# Detailed
data.info()
data.nunique()
data.isnull().sum()

# For ydata-profiling (if installed)
from ydata_profiling import ProfileReport
ProfileReport(data, minimal=True).to_notebook_iframe()
```

### SQL

```sql
-- Column types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'my_table';

-- Value distribution
SELECT field_name, COUNT(*) as n
FROM my_table
GROUP BY field_name
ORDER BY n DESC;
```

---

## 7) Checklist (Copy into Notebooks)

```markdown
## Data Profiling Checklist

- [ ] Column names verified against code expectations
- [ ] Column types verified (logical/factor/character/numeric/date)
- [ ] Categorical field values inspected with counts
- [ ] Numeric field ranges checked for plausibility
- [ ] Date fields have correct class and plausible range
- [ ] Join keys have matching types across tables
- [ ] ICD/code regex patterns tested against actual data
- [ ] Missing data patterns documented
- [ ] Result dimensions verified after joins and filters
```
