# AskSage Multi-Model Review — Comprehensive Reference

**Skill location:** `~/.claude/skills/asksage-review/SKILL.md`
**Scripts:** `/home/harlan/projects/asksage/asksage_review.py` (code review),
`/home/harlan/projects/asksage/batch_review.py` (batch multi-model review)

---

## 1. Architecture Overview

The AskSage review system has two components:

1. **`asksage_review.py`** — Single-model code review. Takes a file or directory,
   builds a txtarchive, sends to one AskSage model, returns the review.

2. **`batch_review.py`** — Multi-model analysis review. Takes a directory of
   markdown/text files, sends each to multiple LLM models, saves per-model reviews.

Both use the `asksageclient` Python package and load credentials from
`~/.config/asksage/credentials.env`.

---

## 2. Authentication & Credentials

### Credential File

```
# ~/.config/asksage/credentials.env
ASKSAGE_EMAIL=user@example.com
ASKSAGE_API_KEY=your_api_key_here
```

### Loading Pattern

```python
from pathlib import Path
import os

cred_file = Path.home() / ".config" / "asksage" / "credentials.env"
for line in cred_file.read_text().splitlines():
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        key, _, value = line.partition("=")
        os.environ[key.strip()] = value.strip().strip('"')
```

### Client Initialization

```python
from asksageclient import AskSageClient

client = AskSageClient(
    email=os.environ["ASKSAGE_EMAIL"],
    api_key=os.environ["ASKSAGE_API_KEY"],
)
```

### Security Rules

- **NEVER** commit `credentials.env` to version control
- **NEVER** print or log API keys in script output
- Always load from environment variables or credential file
- `.gitignore` must cover `credentials.env` and `*.env`

---

## 3. API Reference

### `client.query()`

The primary method for sending prompts to models.

```python
response = client.query(
    message=full_prompt,      # str — the full prompt text
    model="claude-4-opus",    # str — model identifier
    temperature=0.0,          # float — 0.0 for deterministic reviews
    dataset="none",           # str — "none" for no RAG dataset
)

review_text = response.get("message", "No response received.")
```

### `client.get_models()`

List available models on the platform.

```python
response = client.get_models()
models = sorted(response.get("response", []))
```

### Available Models (as of 2026-02)

| Model ID | Short Name | Notes |
|----------|------------|-------|
| `claude-4-opus` | claude-opus | Anthropic's strongest model |
| `gpt-4o` | gpt4o | OpenAI's flagship multimodal |
| `xai-grok` | grok | xAI Grok, detailed analysis |
| `google-gemini-2.5-pro` | gemini | Google's latest, long context |

Use `--list-models` with `asksage_review.py` for the current full list.

---

## 4. Full Pipeline: HTML → Markdown → Multi-Model Reviews → Synthesis

### Step 1: Render Analysis to HTML

```bash
# Quarto notebook
quarto render analysis.qmd --to html

# Jupyter notebook (outputs preserved, no re-execution)
quarto render analysis.ipynb --to html
```

### Step 2: Convert HTML to Markdown

```bash
# Basic conversion
pandoc analysis.html -t markdown --wrap=none -o analysis.md

# With media extraction (preserves plot descriptions)
pandoc analysis.html -t markdown --wrap=none --extract-media=./media -o analysis.md
```

**Why markdown?** HTML is too token-heavy for LLM context windows. Pandoc
markdown preserves tables, headings, and alt-text from plots while reducing
size by ~80%.

### Step 3: Send to Multiple Models

```bash
# Using batch_review.py
python batch_review.py ./markdown_dir/ ./reviews/

# Or per-file with asksage_review.py
python asksage_review.py analysis.md --model claude-4-opus -o review-claude.md
python asksage_review.py analysis.md --model gpt-4o -o review-gpt4o.md
python asksage_review.py analysis.md --model xai-grok -o review-grok.md
python asksage_review.py analysis.md --model google-gemini-2.5-pro -o review-gemini.md
```

### Step 4: Synthesize Cross-Model Reviews

After collecting reviews, synthesize into a single document covering:

1. **Consensus findings** — points where 3+ models agree
2. **Unique insights** — points raised by only one model
3. **Disagreements** — where models contradict each other
4. **Priority recommendations** — ranked by frequency across models
5. **Model-specific strengths** — which model caught what others missed

---

## 5. Prompt Templates

### 5.1 Clinical/Epidemiological Analysis Review (7-Point)

```
You are a clinical epidemiologist specializing in {DOMAIN}. You are reviewing
the RESULTS of {ANALYSIS_DESCRIPTION}.

Please provide a detailed analysis addressing these 7 points:

1. **Model Performance**: Interpret the ROC AUC, sensitivity, specificity,
   Brier scores, and calibration results. Are these clinically meaningful?
   How does the model perform across train/test/external validation?

2. **Variable Importance & SHAP Analysis**: What are the most important
   predictors? Do the SHAP values make clinical sense? Any surprising findings?

3. **Clinical Implications**: What does this analysis mean for patients?
   How should clinicians use these predictions?

4. **Methodological Strengths & Weaknesses**: Evaluate the analytical approach.
   What was done well? What are the limitations?

5. **Data Quality Concerns**: Are there any red flags in the data that affect
   the conclusions?

6. **Single Most Important Clinical or Policy Takeaway**: What is the ONE
   finding that matters most?

7. **Recommended Next Steps**: What should the research team do next?

Here are the analysis results:

```

### 5.2 Code Review (Single File)

```
Review this code. Focus on:
1. Code quality and best practices
2. Security concerns
3. Error handling
4. Suggestions for improvement
```

### 5.3 Package/Project Review

```
You are reviewing a software project. Provide a thorough code review covering:
1. Package architecture and design patterns
2. Code quality, readability, and idiomatic usage
3. Error handling and edge cases
4. Test coverage assessment
5. Security concerns
6. Performance considerations
7. Documentation quality
8. Top 5 priority improvements
```

### 5.4 General Analysis Review

```
You are an expert data scientist reviewing the results of an analysis.

Please provide a detailed review covering:

1. **Results Interpretation**: Are the findings sound? Any statistical concerns?
2. **Methodology**: Evaluate the analytical approach, assumptions, and
   appropriateness of methods chosen.
3. **Visualizations**: Are the plots clear, appropriate, and correctly labeled?
4. **Limitations**: What caveats should accompany these results?
5. **Recommended Next Steps**: What should be done next?

Here are the analysis results:

```

---

## 6. CLI Reference

### asksage_review.py

```
usage: asksage_review.py [-h] [--model MODEL] [--prompt PROMPT]
                         [--list-models] [--temperature TEMP]
                         [--output OUTPUT] [path]

Send code to any AskSage model for review.

positional arguments:
  path                  File or directory to review

options:
  --model, -m MODEL     AskSage model (default: xai-grok)
  --prompt, -p PROMPT   Custom review prompt (replaces default)
  --list-models         List available models and exit
  --temperature, -t     Model temperature (default: 0.0)
  --output, -o OUTPUT   Save review to file instead of printing
```

### batch_review.py

```
usage: batch_review.py [-h] [--models MODELS] [--prompt PROMPT]
                       [--prompt-file FILE] [--config CONFIG]
                       [--temperature TEMP] [--pattern PATTERN]
                       input_dir output_dir

Batch send files to multiple AskSage models for review.

positional arguments:
  input_dir             Directory containing files to review
  output_dir            Directory for review output files

options:
  --models MODELS       Comma-separated model list
                        (default: claude-4-opus,gpt-4o,xai-grok,google-gemini-2.5-pro)
  --prompt PROMPT       Review prompt (prepended to file content)
  --prompt-file FILE    Read prompt from a file
  --config CONFIG       YAML config with per-file prompts
  --temperature TEMP    Model temperature (default: 0.0)
  --pattern PATTERN     Glob pattern for input files (default: *.md)
```

---

## 7. YAML Configuration Format

For per-analysis custom prompts, create a YAML config:

```yaml
# review_config.yaml

# Default prompt used when an analysis has no custom prompt
default_prompt: |
  You are an expert reviewing analysis results.
  Please provide a detailed review covering methodology,
  results interpretation, limitations, and next steps.

# Per-analysis overrides
analyses:
  340-analysis.md:
    title: "Adolescent SCD Organ Damage"
    prompt: |
      You are a clinical epidemiologist specializing in sickle cell disease.
      Review this analysis of adolescent organ damage patterns...

  345-analysis.md:
    title: "ML Mortality Pipeline"
    prompt: |
      You are a biostatistician reviewing a machine learning mortality
      prediction pipeline...

  360-analysis.md:
    title: "CKD Nephropathy Analysis"
    # No custom prompt — uses default_prompt
```

---

## 8. Output Organization

```
reviews/
├── {filename}-review-claude-opus.md
├── {filename}-review-gpt4o.md
├── {filename}-review-grok.md
├── {filename}-review-gemini.md
└── {filename}-synthesis.md          # Cross-model synthesis (manual)
```

The filename stem (without extension) is used as the analysis identifier.
Review files are named `{stem}-review-{model_short}.md`.

---

## 9. Troubleshooting

### Authentication Failures (401)

```
Check:
1. credentials.env has correct email and API key
2. API key has not expired
3. Account is active: log in at asksage.ai web UI
```

### Rate Limits (429)

```
AskSage rate limits vary by account tier.
- Wait and retry (batch_review.py does not auto-retry)
- Reduce parallelism
- Contact AskSage support for limit increases
```

### Token Limits

```
If prompt + content exceeds model context window:
- Use pandoc to convert HTML (smaller than raw HTML)
- Truncate or summarize long analyses
- Split into sections and review separately
```

### Empty or Short Reviews

```
If response.get("message") is very short:
- Check that the prompt + content was not truncated
- Try a different model (some handle long context better)
- Verify the model ID is correct (use --list-models)
```

### Model Not Found

```
- Run: python asksage_review.py --list-models
- Model IDs change as AskSage updates their platform
- Common current IDs: claude-4-opus, gpt-4o, xai-grok, google-gemini-2.5-pro
```

---

## 10. Example: Batch Review Script Template

```python
"""Batch review template — customize for your project."""

import os
import sys
from pathlib import Path

# Load credentials
cred_file = Path.home() / ".config" / "asksage" / "credentials.env"
for line in cred_file.read_text().splitlines():
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        key, _, value = line.partition("=")
        os.environ[key.strip()] = value.strip().strip('"')

from asksageclient import AskSageClient

client = AskSageClient(
    email=os.environ["ASKSAGE_EMAIL"],
    api_key=os.environ["ASKSAGE_API_KEY"],
)

MODELS = [
    ("claude-4-opus", "claude-opus"),
    ("xai-grok", "grok"),
    ("gpt-4o", "gpt4o"),
    ("google-gemini-2.5-pro", "gemini"),
]

PROMPT = """Your review prompt here.

Here are the analysis results:

"""

input_dir = Path("./markdown_files")
output_dir = Path("./reviews")
output_dir.mkdir(exist_ok=True)

for md_file in sorted(input_dir.glob("*.md")):
    content = md_file.read_text()
    full_prompt = PROMPT + content
    stem = md_file.stem

    print(f"\n{'='*60}")
    print(f"Reviewing: {md_file.name} ({len(full_prompt):,} chars)")
    print(f"{'='*60}")

    for model_id, model_short in MODELS:
        output_file = output_dir / f"{stem}-review-{model_short}.md"
        if output_file.exists() and output_file.stat().st_size > 100:
            print(f"  SKIP {model_short}: already exists")
            continue

        print(f"  Sending to {model_id}...", end=" ", flush=True)
        try:
            response = client.query(
                message=full_prompt,
                model=model_id,
                temperature=0.0,
                dataset="none",
            )
            review = response.get("message", "No response received.")
            output_file.write_text(review)
            print(f"OK ({len(review):,} chars)")
        except Exception as e:
            print(f"FAILED: {e}")

print(f"\nReviews saved to {output_dir}/")
```
