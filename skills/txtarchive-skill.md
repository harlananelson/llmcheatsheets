# TxtArchive Skill

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer) or paste into an LLM session for assistance with creating, unpacking, and working with txtarchive code archives.

TxtArchive creates text-based archives of codebases optimized for LLM analysis. Its key value: it flattens Jupyter notebooks into simple text so LLMs can read, modify, and create notebooks without dealing with `.ipynb` JSON markup.

---

## 1) Why TxtArchive Exists

### The Problem

- Jupyter notebooks are JSON files with deeply nested structure. LLMs struggle to produce valid `.ipynb` JSON reliably.
- Sharing a directory of analysis files with an LLM requires flattening multiple files into a single context.
- Transferring notebooks between environments (local, remote servers, HealtheDataLabs) is friction-heavy.

### The Solution

TxtArchive converts notebooks and code files into a simple text format that LLMs can easily read and write. The round-trip works:

```
.ipynb / .py / .qmd  -->  txtarchive archive  -->  plain text (paste to LLM)
                                                          |
LLM creates/modifies plain text  -->  txtarchive extract-notebooks  -->  .ipynb
```

**Key insight:** An LLM can produce a txtarchive-formatted text file containing notebook cells, and `extract-notebooks` reconstructs valid `.ipynb` files from it -- no JSON authoring required.

---

## 2) Two Archive Formats

| Format | Flag | Header Pattern | Best For |
|--------|------|---------------|----------|
| **Standard** | (default) | `---\nFilename: path/file\n---` | Exact file reconstruction |
| **LLM-Friendly** | `--llm-friendly` | `# FILE N: path/file\n###...###` | AI analysis, notebook round-trips |

**Always use `--llm-friendly` when working with LLMs.** The standard format is for backup/transfer only.

---

## 3) LLM-Friendly Format Structure

```
# Archive created on: 2026-02-06 10:30:00
# LLM-FRIENDLY CODE ARCHIVE
# Generated from: /path/to/project
# Date: 2026-02-06 10:30:00

# TABLE OF CONTENTS
1. 010-Data-Prep.py
2. 310-Baseline-Model.ipynb
3. utils.R

################################################################################
# FILE 1: 010-Data-Prep.py
################################################################################

import pandas as pd
df = pd.read_csv("data.csv")

################################################################################
# FILE 2: 310-Baseline-Model.ipynb
################################################################################

# Markdown Cell 1
"""
# Baseline Random Forest Model

This notebook builds the initial RF classifier.
"""

# Cell 2
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# Markdown Cell 3
"""
## Load Data
"""

# Cell 4
df = pd.read_parquet("cohort.parquet")
print(f"Shape: {df.shape}")

################################################################################
# FILE 3: utils.R
################################################################################

library(tidymodels)
# ... R code ...
```

### Notebook Cell Conventions

| Marker | Meaning |
|--------|---------|
| `# Cell N` | Code cell (Python/R) |
| `# Markdown Cell N` | Markdown cell (wrapped in triple quotes `"""..."""`) |

- Cell numbers are sequential within each notebook file.
- Outputs are stripped -- only source code and markdown are preserved.
- On extraction, cells are reconstructed into valid `.ipynb` JSON with proper metadata.

---

## 4) Core Commands

### Archive: Create an Archive

```bash
# Archive a project directory (LLM-friendly, code only)
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb .qmd .R \
    --llm-friendly \
    --extract-code-only

# Archive specific files only (faster, precise)
python -m txtarchive archive myproject/ output.txt \
    --explicit-files 310-Baseline.ipynb 320-Tuned.ipynb utils.py \
    --llm-friendly

# Archive with exclusions
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb .qmd \
    --exclude-dirs .venv __pycache__ .git _targets \
    --llm-friendly --extract-code-only

# Include root-level files regardless of type
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb \
    --root-files README.md pyproject.toml \
    --llm-friendly

# Split large archives by token count
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb \
    --llm-friendly --extract-code-only \
    --split-output --max-tokens 75000
```

**Key flags:**

| Flag | Purpose |
|------|---------|
| `--llm-friendly` | Use LLM-friendly format (always use for AI work) |
| `--extract-code-only` | Strip notebook outputs (smaller, cleaner) |
| `--explicit-files` | Archive only these specific files |
| `--file_types` | Filter by extension (default: `.yaml .py .r .ipynb .qmd`) |
| `--exclude-dirs` | Skip these directories |
| `--root-files` | Include these root files regardless of `--file_types` |
| `--include-subdirs` | Only include these subdirectories |
| `--no-subdirectories` | Don't recurse into subdirectories |
| `--split-output` | Split into chunks by token count |
| `--max-tokens N` | Max tokens per chunk (default: 100000) |

### Unpack: Extract Files from an Archive

```bash
# Auto-detects format (standard or LLM-friendly)
python -m txtarchive unpack archive.txt output_dir/

# Overwrite existing files
python -m txtarchive unpack archive.txt output_dir/ --replace_existing
```

### Extract Notebooks: Reconstruct `.ipynb` Files

```bash
# Extract only Jupyter notebooks from an LLM-friendly archive
python -m txtarchive extract-notebooks archive.txt output_dir/

# Extract notebooks AND generate Quarto (.qmd) files
python -m txtarchive extract-notebooks-and-quarto archive.txt output_dir/

# Overwrite existing
python -m txtarchive extract-notebooks archive.txt output_dir/ --replace_existing
```

**This is the key command for the LLM-creates-notebooks workflow.** The LLM writes cell markers in plain text, and `extract-notebooks` produces valid `.ipynb` files.

---

## 5) Workflow: LLM Creates a Jupyter Notebook

This is the primary use case. An LLM produces analysis code in txtarchive format, and you convert it to a runnable notebook.

### Step 1: Ask the LLM to Write in TxtArchive Format

Prompt the LLM with something like:

```
Create a Jupyter notebook for EDA of the cohort data. Write it in txtarchive
LLM-friendly format. Use "# Cell N" for code cells and "# Markdown Cell N"
(with triple-quoted content) for markdown cells. Number cells sequentially.
The file should be named 110-EDA.ipynb.
```

### Step 2: LLM Produces Plain Text

```
################################################################################
# FILE 1: 110-EDA.ipynb
################################################################################

# Markdown Cell 1
"""
# Exploratory Data Analysis

Initial look at the cohort demographics and outcome distribution.
"""

# Cell 2
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_parquet("cohort.parquet")
print(f"Cohort size: {len(df)}")

# Markdown Cell 3
"""
## Demographics
"""

# Cell 4
df[["age", "gender", "race"]].describe()

# Cell 5
df["death_flag"].value_counts().plot(kind="bar", title="Outcome Distribution")
plt.tight_layout()
plt.show()
```

### Step 3: Save and Extract

```bash
# Save the LLM output to a .txt file
# (copy-paste or redirect)

# Extract to a Jupyter notebook
python -m txtarchive extract-notebooks llm-output.txt ./

# Result: 110-EDA.ipynb is created as a valid Jupyter notebook
```

### Step 4: Run the Notebook

Open `110-EDA.ipynb` in Jupyter, run cells, iterate.

---

## 6) Workflow: Transfer Notebooks to a Remote Environment

For copying notebooks to HealtheDataLabs or other remote Jupyter servers where you can't easily `git clone`.

### Outbound (Local to Remote)

```bash
# Archive notebooks you want to transfer
python -m txtarchive archive paper/mortality/ transfer.txt \
    --file_types .ipynb .py \
    --llm-friendly --extract-code-only

# Copy transfer.txt to the remote environment (paste, upload, scp, etc.)
```

### On the Remote Machine

```bash
# If txtarchive is installed:
python -m txtarchive extract-notebooks transfer.txt ./

# If txtarchive is NOT installed, paste the archive into an LLM and ask:
# "Extract the notebook files from this archive and give me the .ipynb JSON"
```

### Inbound (Remote to Local)

On the remote machine, archive the work:

```bash
python -m txtarchive archive . results.txt \
    --explicit-files 310-Model.ipynb 320-Tuned.ipynb \
    --llm-friendly --extract-code-only
```

Copy `results.txt` back locally and unpack.

---

## 7) Workflow: Archive for LLM Code Review

Send an existing codebase to an LLM for review, refactoring, or extension.

```bash
# Archive the analysis directory
python -m txtarchive archive paper/mortality/ review.txt \
    --file_types .py .ipynb .qmd .R \
    --llm-friendly --extract-code-only

# Paste review.txt into the LLM session (or attach it)
# Ask: "Review this analysis. Suggest improvements to the feature engineering
#        in 210-Features.ipynb and the model tuning in 320-Tuned.ipynb."
```

The LLM can respond with modified files in txtarchive format. Save and extract.

---

## 8) Workflow: Ask Sage Integration

```bash
# Archive and ingest in one step
python -m txtarchive archive-and-ingest myproject/ archive.txt \
    --file_types .py .ipynb \
    --llm-friendly --extract-code-only \
    --ingestion-method auto

# Ingest an existing file
python -m txtarchive ingest --file archive.txt

# Test which endpoints work
python -m txtarchive ingest --file archive.txt --test-endpoints
```

Requires `ACCESS_TOKEN` environment variable for Ask Sage API authentication.

---

## 9) Word Document Conversion

```bash
# Convert a Word doc to Markdown
python -m txtarchive convert-word --input_path paper.docx --output_path paper.md

# Methods (in order of quality): mammoth, pandoc, python-docx, basic
python -m txtarchive convert-word --input_path paper.docx --output_path paper.md \
    --method mammoth
```

---

## 10) Format Reference for LLM Authors

When asking an LLM to produce txtarchive-formatted output, give it these rules:

### File Separator

```
################################################################################
# FILE N: filename.ext
################################################################################
```

- 80 `#` characters on the separator lines.
- `N` is the sequential file number (1, 2, 3...).
- `filename.ext` is the relative path.

### Code Cells (Notebooks)

```
# Cell N
<python or R code>
```

### Markdown Cells (Notebooks)

```
# Markdown Cell N
"""
<markdown content>
"""
```

### Non-Notebook Files

Plain file content between separators. No cell markers needed for `.py`, `.R`, `.qmd`, etc.

### Rules

- Cell numbers are sequential within each file, starting at 1.
- Markdown content MUST be wrapped in triple quotes (`"""`).
- No output cells -- only source code and markdown.
- One blank line between the separator and the first cell.
- File paths in the header should use forward slashes.

---

## 11) Programmatic API

```python
from txtarchive import (
    archive_files,
    unpack_files,
    extract_notebooks_to_ipynb,
    run_extract_notebooks,
)

# Create an archive
archive_files(
    directory="myproject/",
    output_file="archive.txt",
    file_types=[".py", ".ipynb"],
    llm_friendly=True,
    extract_code_only=True,
)

# Unpack (auto-detects format)
from txtarchive.packunpack import unpack_files_auto
unpack_files_auto("archive.txt", "output_dir/")

# Extract notebooks only
extract_notebooks_to_ipynb("archive.txt", "output_dir/")
```

---

## 12) Installation

```bash
pip install txtarchive

# Or from source
pip install -e /path/to/txtarchive
```

Requires Python >= 3.7.6. Optional dependencies: `mammoth`, `python-docx`, `pypandoc` (for Word conversion).

---

## 13) Common Patterns

### Archive a Single Notebook for LLM Editing

```bash
python -m txtarchive archive . edit.txt \
    --explicit-files 310-Baseline.ipynb \
    --llm-friendly --extract-code-only
```

Paste `edit.txt` into the LLM. Get modified text back. Save and extract.

### Archive an Entire Analysis Pipeline

```bash
python -m txtarchive archive paper/mortality/ pipeline.txt \
    --file_types .py .ipynb .qmd .R \
    --exclude-dirs __pycache__ .ipynb_checkpoints _targets \
    --llm-friendly --extract-code-only
```

### Create a Notebook from Scratch via LLM

1. Describe the analysis you want.
2. Tell the LLM to use txtarchive format.
3. Save the output to a `.txt` file.
4. Run `python -m txtarchive extract-notebooks output.txt ./`
5. Open the resulting `.ipynb` in Jupyter.

### Split a Large Codebase for Context-Limited LLMs

```bash
python -m txtarchive archive . archive.txt \
    --file_types .py .ipynb \
    --llm-friendly --extract-code-only \
    --split-output --max-tokens 75000
# Creates: archive_part1.txt, archive_part2.txt, ...
```

---

## 14) Troubleshooting

| Problem | Solution |
|---------|----------|
| Notebook won't open after extraction | Check cell markers: `# Cell N` (not `# cell N`). Case matters. |
| Archive too large for LLM | Use `--split-output --max-tokens 75000` |
| Missing files in archive | Check `--file_types` includes the extension |
| Encoding errors | txtarchive uses `errors="replace"` -- check for binary files in the archive |
| `extract-notebooks` finds no notebooks | Ensure archive uses LLM-friendly format (`--llm-friendly`) |
| Outputs cluttering the archive | Add `--extract-code-only` to strip outputs |
