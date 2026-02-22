# PHI Scanning Skill — Screen Before You Share

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer or skill trigger) or paste
> into an LLM session before publishing analysis outputs or exposing clinical repos to cloud
> services. Ensures PHI/PII is detected locally before data leaves the machine.

**Principle:** Clinical data environments contain PHI by default. Any output — rendered
reports, CSV exports, notebooks, scripts with hardcoded values — must be scanned before
publishing, sharing, or sending to cloud-based LLMs. The cost of a 30-second scan is always
less than a HIPAA incident.

---

## 1) When This Skill Activates

This skill should be invoked **before** any data crosses a trust boundary:

- Finished HTML reports or rendered notebooks (`.html`, `.pdf`)
- Pulling repos from organizational DevOps (Azure DevOps, GitHub Enterprise) that may
  contain clinical data — scan before pointing cloud tools at them
- Creating txtarchives or code bundles for LLM ingestion
- Committing CSV/data exports to version control
- Sharing analysis files with collaborators outside the secure environment

**Do NOT skip scanning because:**
- You "de-identified the data" (check — residual identifiers are common)
- The file is "just code" (scripts can contain hardcoded MRNs, names in comments, sample data)
- The output is aggregated (small cell counts, unique combinations can re-identify)

---

## 2) Tool: Microsoft Presidio + Custom Healthcare Recognizers

### What It Is

[Microsoft Presidio](https://microsoft.github.io/presidio/) is an open-source PII detection
framework. It combines NLP (spaCy) with pattern matching and context-aware scoring. The
`phi_scanner.py` tool in the asksage project extends Presidio with custom recognizers for
healthcare-specific patterns that Presidio doesn't cover by default.

### Architecture

```
Input files → Text extraction → Presidio AnalyzerEngine → Findings with scores
                                       │
                                       ├── Built-in recognizers (PERSON, SSN, EMAIL, PHONE, ...)
                                       └── Custom recognizers (MRN, DOB, AGE, NPI)
```

All processing is **local** — no data leaves the machine. Uses spaCy `en_core_web_lg` model
on CPU (no GPU required).

### Built-in Entity Types (Presidio)

| Entity | Examples |
|--------|----------|
| `PERSON` | John Smith, Dr. Wilson |
| `US_SSN` | 234-56-7890 |
| `EMAIL_ADDRESS` | user@example.com |
| `PHONE_NUMBER` | 555-123-4567 |
| `LOCATION` | Springfield, IL |
| `CREDIT_CARD` | 4111-1111-1111-1111 |
| `DATE_TIME` | 01/15/2024, March 2023 |
| `URL` | example.com |
| `US_DRIVER_LICENSE` | State-specific patterns |
| `US_PASSPORT` | Passport numbers |
| `IBAN_CODE` | International bank accounts |
| `IP_ADDRESS` | 192.168.1.1 |

### Custom Healthcare Entity Types

| Entity | Pattern | Confidence |
|--------|---------|------------|
| `MEDICAL_RECORD_NUMBER` | 6-8 digits near MRN context words | 0.85-1.0 |
| `DATE_OF_BIRTH` | Dates near DOB/birthdate context | 0.90 |
| `AGE` | "XX year old", "age XX", "XX y/o" | 0.70-0.75 |
| `NPI` | 10-digit number near NPI context | 0.85 |

---

## 3) CLI Reference

### Installation (Nix + Python venv)

```bash
# In the asksage project with Nix dev shell
pip install presidio-analyzer presidio-anonymizer
python -m spacy download en_core_web_lg
```

The Nix `flake.nix` must include `LD_LIBRARY_PATH` for `stdenv.cc.cc.lib` so numpy/spaCy
can find `libstdc++.so.6`.

### Basic Usage

```bash
# Scan a single file
python phi_scanner.py report.md

# Scan a directory recursively
python phi_scanner.py ./my_analysis/

# Scan specific file types
python phi_scanner.py . --pattern "*.csv" "*.html" "*.md" "*.ipynb"

# Higher confidence threshold (fewer false positives)
python phi_scanner.py . --threshold 0.8

# JSON output for programmatic use
python phi_scanner.py . --format json

# CSV output saved to file
python phi_scanner.py . --format csv -o phi_report.csv
```

### Default File Patterns

```
*.md *.txt *.csv *.py *.R *.qmd *.ipynb *.html *.json *.yaml *.yml
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Clean — no PHI/PII detected |
| 1 | PHI/PII detected — review findings |
| 2 | Error (file not found, etc.) |

Exit code 1 enables use in CI pipelines and pre-commit hooks.

### Output Formats

**Table** (default) — human-readable terminal output with per-file findings and summary:

```
Presidio scanning /path/to/target for PHI before exposing it to cloud LLM.
Initializing analyzer...
  [1/3] ./report.md
  [2/3] ./data.csv
  [3/3] ./analysis.ipynb

========================================================================
  ./report.md
========================================================================
  Line   Type                         Score  Text
  ------ ---------------------------- ------ ----------------------------
  3      PERSON                       0.85   John Smith
  5      MEDICAL_RECORD_NUMBER        1.0    MRN: 12345678
```

**JSON** — structured output with findings array and summary object.

**CSV** — one row per finding with columns: file, line, entity_type, score, text, start, end.

---

## 4) Workflow Integration

### Before Publishing Reports

```bash
# After rendering a Quarto document
quarto render analysis.qmd
python phi_scanner.py analysis.html --threshold 0.7
```

### Before Exposing a Repo to Cloud LLMs

```bash
# After cloning from Azure DevOps or internal Git
git clone <internal-repo-url> ./project
python phi_scanner.py ./project/ --pattern "*.csv" "*.md" "*.ipynb" "*.R" "*.py"
# Only proceed with cloud tools if exit code is 0
```

### Before Creating txtarchives

```bash
# Scan source files, then archive
python phi_scanner.py ./my_analysis/
python -m txtarchive archive ./my_analysis/ output.txt --llm-friendly
```

### In a Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
python phi_scanner.py . --pattern "*.csv" "*.md" "*.ipynb" --threshold 0.7
if [ $? -eq 1 ]; then
    echo "PHI detected — commit blocked. Review findings above."
    exit 1
fi
```

---

## 5) Interpreting Results

### Confidence Scores

| Range | Interpretation | Action |
|-------|---------------|--------|
| 0.9-1.0 | High confidence — very likely real PII | Must review and remediate |
| 0.7-0.89 | Moderate confidence — probable PII | Review in context |
| 0.5-0.69 | Low confidence — possible false positive | Check if sensitive in context |

### Common False Positives

| Pattern | Why It Fires | Mitigation |
|---------|-------------|------------|
| Author names in headers | `PERSON` recognizer | Raise threshold to 0.7+ |
| URLs in code/config | `URL` recognizer | Expected — ignore or raise threshold |
| Dates in non-clinical context | `DATE_TIME` recognizer | Context-dependent — review |
| Package version numbers | Sometimes matches patterns | Usually low confidence — ignored |

### When Findings Require Action

1. **Real PHI found** — Remove or redact before proceeding. Do NOT commit, share, or send to cloud.
2. **False positive confirmed** — Safe to proceed. Consider raising `--threshold` for this scan.
3. **Uncertain** — Treat as real PHI. Err on the side of caution.

---

## 6) Extending the Scanner

### Adding Custom Recognizers

The scanner uses Presidio's `PatternRecognizer` class. To add a new entity type:

```python
from presidio_analyzer import Pattern, PatternRecognizer

def _build_my_recognizer() -> PatternRecognizer:
    patterns = [
        Pattern("MY_PATTERN", r"regex_here", 0.85),
    ]
    return PatternRecognizer(
        supported_entity="MY_ENTITY_TYPE",
        patterns=patterns,
        context=["context", "words", "that", "boost", "confidence"],
    )
```

Then add it to the registry in `build_analyzer()`:

```python
registry.add_recognizer(_build_my_recognizer())
```

### Context Words

Presidio boosts confidence scores when context words appear near a pattern match. For
healthcare scanning, relevant context includes: patient, chart, medical, clinical, hospital,
physician, diagnosis, treatment, admitted, discharged.

---

## 7) Dependencies and Environment

| Package | Purpose | Size |
|---------|---------|------|
| `presidio-analyzer` | Core PII detection engine | ~5 MB |
| `presidio-anonymizer` | Anonymization utilities | ~1 MB |
| `spacy` | NLP framework | ~15 MB |
| `en_core_web_lg` | English NLP model (NER, POS) | ~400 MB |

### Nix Environment Note

When running in a Nix dev shell, `LD_LIBRARY_PATH` must include `stdenv.cc.cc.lib` for
numpy's C extensions to find `libstdc++.so.6`. This is configured in `flake.nix`:

```nix
LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
  pkgs.stdenv.cc.cc.lib
];
```

---

## 8) Relationship to AskSage Data Labeling Plugin

AskSage offers a **Data Labeling** plugin that labels content as PII/PHI/CUI via cloud API.
The local Presidio scanner and the AskSage plugin serve complementary roles:

| Aspect | Local Presidio Scanner | AskSage Data Labeling |
|--------|----------------------|----------------------|
| **Where it runs** | Local machine | AskSage cloud |
| **Data leaves machine?** | No | Yes (sent to AskSage API) |
| **Use case** | Pre-screening before cloud exposure | Labeling data already in AskSage |
| **Cost** | Free (open source) | Free plugin (uses inference tokens) |
| **When to use** | BEFORE sending to any cloud service | AFTER data is already in AskSage |

**Workflow:** Always run the local scanner first. Only use the AskSage plugin for data
that has already passed local screening and been intentionally uploaded.
