# Quarto Document Skill

> **Usage:** Load this file into Claude Code (via CLAUDE.md pointer) or paste into an LLM session for comprehensive Quarto assistance. Covers execution control, journal formatting, cross-references, citations, PDF/HTML configuration, and CLI commands.

Comprehensive reference for creating, rendering, and formatting Quarto documents.
Emphasizes practical workflows: Jupyter-first rendering, journal formatting, and execution control.

---

## 1) Document Types and When to Use Each

| Source Format | Best For | Execution Default on `quarto render` |
|---------------|----------|--------------------------------------|
| `.qmd` | Text-heavy docs, articles, websites, books | **Executes code** |
| `.ipynb` | Data analysis, exploration, Jupyter-first workflows | **Does NOT execute** (uses saved outputs) |

**Key insight:** `.ipynb` files rendered with `quarto render notebook.ipynb` preserve pre-computed outputs by default. No special configuration needed for the "run in Jupyter, render on command line" workflow.

---

## 2) Execution Control (Critical for Jupyter Workflows)

### The Problem

You run code interactively in Jupyter, then want to render to HTML/PDF without re-executing. The solution depends on your source format.

### For `.ipynb` Files (Simplest Path)

```bash
# This preserves all outputs already in the notebook -- no re-execution
quarto render notebook.ipynb
quarto render notebook.ipynb --to html
quarto render notebook.ipynb --to pdf
```

To force re-execution (when you DO want it):

```bash
quarto render notebook.ipynb --execute
```

Or in the notebook's Raw cell YAML:

```yaml
---
execute:
  enabled: true
---
```

### For `.qmd` Files (Must Opt Out of Execution)

`.qmd` files execute by default. Three ways to prevent it:

#### Option A: `execute: enabled: false` (Document-Level)

```yaml
---
title: "My Analysis"
execute:
  enabled: false
---
```

All code is echoed but not run. Use when code is illustrative or outputs are not needed.

#### Option B: `freeze` (Project-Level, Recommended for Multi-Doc Projects)

Set in `_quarto.yml`:

```yaml
# _quarto.yml
execute:
  freeze: auto    # re-render only when source file changes
```

Or:

```yaml
execute:
  freeze: true    # NEVER re-render during project render
```

**How it works:**
1. First render executes code and stores results in `_freeze/` directory
2. Subsequent `quarto render` (project-level) uses frozen results
3. To update: render the specific file directly (`quarto render file.qmd`)

**Important constraints:**
- `freeze` only applies during **project-level** renders (`quarto render` from project root)
- Rendering a **single file** (`quarto render myfile.qmd`) always executes regardless of freeze
- Commit `_freeze/` to version control so collaborators can render without the compute environment

| Setting | Re-executes when source changes? | Re-executes on single-file render? |
|---------|----------------------------------|------------------------------------|
| `freeze: true` | No | Yes |
| `freeze: auto` | Yes (project render) | Yes |

#### Option C: `cache` (Cell-Level Caching)

```yaml
---
execute:
  cache: true
---
```

Requires: `pip install jupyter-cache`

- Jupyter: caches at **whole-notebook level** -- any code cell change re-executes ALL cells
- Knitr (R): caches at **individual cell level**
- Markdown-only changes do NOT invalidate cache

CLI overrides:

```bash
quarto render doc.qmd --cache           # force caching on
quarto render doc.qmd --no-cache        # force caching off
quarto render doc.qmd --cache-refresh   # invalidate and re-execute all
```

### Recommended Workflow: Jupyter-First Analysis

```
1. Work in Jupyter (.ipynb) -- run cells, iterate, explore
2. Save notebook (outputs embedded in .ipynb)
3. Render:  quarto render notebook.ipynb --to html
4. Outputs preserved, no re-execution, fast render
```

If using `.qmd` in a project:

```
1. Set freeze: auto in _quarto.yml
2. Render once: quarto render analysis.qmd  (executes code)
3. Results stored in _freeze/
4. Project renders skip re-execution unless source changes
5. Commit _freeze/ to git
```

### Cell-Level Execution Options

Control individual code cells with `#|` comments:

```python
#| eval: false       # Don't run this cell
#| echo: false       # Hide source code
#| output: false     # Hide results
#| warning: false    # Suppress warnings
#| error: true       # Show errors without halting render
#| include: false    # Suppress ALL output (code + results)
```

Document-level defaults:

```yaml
---
execute:
  eval: true
  echo: false
  warning: false
  error: false
---
```

### Intermediate File Preservation (Debugging)

```yaml
---
execute:
  keep-md: true       # Keep intermediate .md
  keep-ipynb: true    # Keep intermediate .ipynb
---
```

---

## 3) Minimal Document Templates

### Basic HTML Document

```yaml
---
title: "My Document"
format: html
---
```

### Analysis Notebook (Jupyter-first, no re-execution)

Save as a Raw cell in your `.ipynb`:

```yaml
---
title: "Analysis 310: Baseline Model"
author: "Harlan Nelson"
date: today
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
execute:
  echo: true
---
```

Render: `quarto render notebook.ipynb`

### Multi-Format Document

```yaml
---
title: "My Document"
toc: true
format:
  html:
    code-fold: true
    theme: cosmo
  pdf:
    documentclass: scrartcl
    papersize: letter
  docx: default
---
```

Render all: `quarto render doc.qmd`
Render one: `quarto render doc.qmd --to pdf`

---

## 4) Journal and Academic Paper Formatting

### Available Journal Templates

| Template | Command | Publisher |
|----------|---------|-----------|
| ACM | `quarto use template quarto-journals/acm` | Association for Computing Machinery |
| PLOS | `quarto use template quarto-journals/plos` | Public Library of Science |
| ASA/JASA | `quarto use template quarto-journals/asa` | American Statistical Association |
| Elsevier | `quarto use template quarto-journals/elsevier` | Elsevier journals |
| ACS | `quarto use template quarto-journals/acs` | American Chemical Society |
| JSS | `quarto use template quarto-journals/jss` | Journal of Statistical Software |
| Biophysical | `quarto use template quarto-journals/biophysical` | Biophysical Journal |

### Using a Journal Template

```bash
# Create new project from template (creates directory with starter files)
quarto use template quarto-journals/elsevier

# Add template to existing project (extension only, no starter files)
quarto add quarto-journals/elsevier
```

In your document:

```yaml
---
title: "My Paper"
format:
  elsevier-pdf:
    toc: true
    keep-tex: true
  elsevier-html: default
---
```

Render:

```bash
quarto render paper.qmd --to elsevier-pdf
```

### When No Official Template Exists

#### Word/Docx Route (most journals accept Word)

```yaml
---
title: "My Paper"
format:
  docx:
    reference-doc: templates/journal-reference.docx
bibliography: refs/library.bib
csl: csl/target-journal.csl
link-citations: true
---
```

1. Create a **reference Word document** with journal-required styles
2. Download the journal's **CSL** from the [Zotero Style Repository](https://www.zotero.org/styles)
3. Render: `quarto render paper.qmd --to docx`

#### Custom Typst/PDF Route (Recommended for New Templates)

Typst is a modern typesetting system bundled with Quarto (no separate install). Faster compilation, better error messages, and simpler template syntax than LaTeX. Preferred when building a custom template from scratch.

```yaml
---
format:
  typst:
    papersize: us-letter
    margin:
      x: 1in
      y: 1in
    mainfont: "Linux Libertine"
    fontsize: 11pt
    columns: 1
    keep-typ: true               # Retain .typ for debugging
bibliography: refs/library.bib
csl: csl/target-journal.csl
citeproc: true                   # Use Pandoc/CSL for citations (not Typst's built-in)
---
```

Create a custom Typst format extension:

```bash
quarto create extension format    # select "typst", provide a name
```

This generates:

```
_extensions/myjournal/
├── _extension.yml          # Format metadata and defaults
├── typst-template.typ      # Core template function (layout, styles)
├── typst-show.typ          # Maps Pandoc metadata to template arguments
├── template.qmd            # Starter document
└── README.md
```

Render: `quarto render paper.qmd --to myjournal-typst`

**When to choose Typst over LaTeX:**
- Building a new custom template (simpler syntax, faster iteration)
- No existing LaTeX class to reuse
- Want faster compile times
- Don't need niche LaTeX packages

**When to stick with LaTeX:**
- Journal provides a `.cls` or `.sty` file
- Heavy use of specialized LaTeX packages (e.g., `tikz`, `mhchem`)
- Existing LaTeX template you want to reuse

#### Custom LaTeX/PDF Route

```yaml
---
format:
  pdf:
    template: templates/journal.latex
    documentclass: article
    papersize: letter
    include-in-header:
      - text: |
          \usepackage{amsmath}
          \usepackage{booktabs}
    keep-tex: true
bibliography: refs/library.bib
csl: csl/target-journal.csl
---
```

### Author and Affiliation Metadata

```yaml
---
title: "A Novel Approach to the Problem"
subtitle: "With Applications"
date: 2026-02-06

abstract: |
  Background: Description of the problem.
  Methods: What we did.
  Results: What we found.
  Conclusions: What it means.

keywords:
  - keyword1
  - keyword2
  - keyword3

author:
  - name: Harlan Nelson
    email: harlan@example.org
    orcid: 0000-0000-0000-0000
    corresponding: true
    roles:
      - conceptualization
      - methodology
      - writing
    affiliation:
      - ref: inst1
      - ref: inst2

  - name: Jane Doe
    equal-contributor: true
    affiliation:
      - ref: inst1

affiliations:
  - id: inst1
    name: Indiana University Health
    department: Department of Research
    city: Indianapolis
    state: IN
    country: US

  - id: inst2
    name: Indiana University
    city: Indianapolis
    state: IN
    country: US

copyright:
  holder: Harlan Nelson
  year: 2026
license: "CC BY"

funding:
  statement: "This work was supported by..."

citation:
  container-title: Journal Name
  volume: 1
  issue: 1
  doi: 10.5555/example
---
```

### Manuscript Project Type

For complex papers with multiple notebooks/documents:

```bash
quarto create project manuscript
```

```yaml
# _quarto.yml
project:
  type: manuscript

manuscript:
  meca-bundle: true    # MECA submission package (if journal supports it)

format:
  docx:
    reference-doc: templates/journal-reference.docx
  pdf:
    documentclass: scrartcl
    keep-tex: true

bibliography: refs/library.bib
csl: csl/journal.csl
link-citations: true
```

---

## 5) Citations and Bibliography

### Setup

```yaml
---
bibliography: references.bib       # or multiple: [refs1.bib, refs2.bib]
csl: style.csl                     # optional, defaults to Chicago author-date
link-citations: true
---
```

### Citation Syntax

| Syntax | Result |
|--------|--------|
| `[@knuth1984]` | Parenthetical: (Knuth, 1984) |
| `@knuth1984` | Narrative: Knuth (1984) |
| `[-@knuth1984]` | Year only: (1984) |
| `[see @knuth1984, pp. 33-35]` | With prefix and locator |
| `[@knuth1984; @wickham2015]` | Multiple citations |

### Include uncited items in bibliography

```yaml
nocite: |
  @item1, @item2
```

Include everything: `nocite: |  @*`

### Control bibliography placement

```markdown
## References

::: {#refs}
:::

## Appendix
Content after references...
```

### PDF Citation Methods

```yaml
format:
  pdf:
    cite-method: citeproc    # default, portable
    # cite-method: natbib    # LaTeX natbib
    # cite-method: biblatex  # LaTeX biblatex
```

---

## 6) Cross-References

### Label Prefixes

| Element | Label Prefix | Reference | Output |
|---------|-------------|-----------|--------|
| Figure | `#fig-` | `@fig-name` | Figure 1 |
| Table | `#tbl-` | `@tbl-name` | Table 1 |
| Equation | `#eq-` | `@eq-name` | Equation 1 |
| Section | `#sec-` | `@sec-name` | Section 1 |
| Code Listing | `#lst-` | `@lst-name` | Listing 1 |
| Theorem | `#thm-` | `@thm-name` | Theorem 1 |

**Labels must be lowercase. Use hyphens, not underscores** (underscores break LaTeX/PDF).

### Figures

Static image:

```markdown
![An Elephant](elephant.png){#fig-elephant}

As shown in @fig-elephant, elephants are large.
```

Computed figure:

```python
#| label: fig-scatter
#| fig-cap: "Scatter plot of X vs Y"
#| fig-alt: "Dots showing positive correlation"

import matplotlib.pyplot as plt
plt.scatter(x, y)
plt.show()
```

Subfigures:

```markdown
::: {#fig-panels layout-ncol=2}
![Panel A](panelA.png){#fig-panelA}
![Panel B](panelB.png){#fig-panelB}

Main caption for both panels
:::
```

Computed subfigures:

```python
#| label: fig-plots
#| fig-cap: "Analysis Results"
#| fig-subcap:
#|   - "Distribution"
#|   - "Trend"
#| layout-ncol: 2
```

### Tables

```markdown
| Col A | Col B | Col C |
|:------|:-----:|------:|
| left  | center| right |

: Summary Statistics {#tbl-summary}

See @tbl-summary for details.
```

Computed table:

```python
#| label: tbl-results
#| tbl-cap: "Model Results"

from IPython.display import Markdown
Markdown(df.to_markdown(index=False))
```

### Equations

```markdown
$$
y = \beta_0 + \beta_1 x + \epsilon
$$ {#eq-model}

The linear model (@eq-model) is fundamental.
```

### Sections (requires `number-sections: true`)

```markdown
## Introduction {#sec-intro}

As discussed in @sec-intro...
```

---

## 7) Figure and Table Options

### Figure Sizing and Layout

```python
#| fig-width: 8              # Width in inches
#| fig-height: 6             # Height in inches
#| fig-asp: 0.618            # Aspect ratio (golden ratio)
#| fig-dpi: 300              # Resolution
#| fig-align: center         # left, center, right
#| fig-format: png           # png, pdf, svg, retina
#| fig-pos: "H"              # LaTeX placement: h, t, b, H, p
#| fig-cap-location: bottom  # top, bottom, margin
```

Document-level defaults:

```yaml
---
fig-width: 8
fig-height: 6
fig-cap-location: bottom
---
```

### Layout for Multiple Items

```markdown
::: {layout-ncol=2}
![](image1.png)
![](image2.png)
:::
```

Custom layout with relative widths (negative = spacing):

```markdown
::: {layout="[[40,-20,40], [100]]"}
![](img1.png)
![](img2.png)
![](img3.png)
:::
```

### Table Options

```python
#| tbl-colwidths: [60, 40]       # Column width percentages
#| tbl-cap-location: top         # top, bottom, margin
#| classes: plain                # Disable default styling
```

Grid tables (for complex content like lists, code blocks):

```markdown
+---------------+---------------+
| Column 1      | Column 2      |
+===============+===============+
| - Item 1      | Some text     |
| - Item 2      | More text     |
+---------------+---------------+

: Complex Table {#tbl-complex}
```

### DataFrame Print Style

```yaml
df-print: kable    # default, kable, tibble, paged
```

---

## 8) Code Display Options

### Per-Cell

```python
#| code-fold: true           # Collapsible code (HTML only)
#| code-summary: "Show code" # Label for collapsed code
#| code-overflow: wrap       # wrap or scroll
#| code-line-numbers: true   # Show line numbers
```

### Document-Level

```yaml
---
format:
  html:
    code-fold: true
    code-tools: true         # Global show/hide + source download
    code-line-numbers: true
    code-overflow: scroll
    highlight-style: github  # tango, pygments, kate, monokai, etc.
---
```

---

## 9) PDF Output Configuration

### Basic PDF

```yaml
---
format:
  pdf:
    documentclass: scrartcl       # scrartcl, article, report, book
    papersize: letter             # letter, a4
    fontsize: 11pt
    number-sections: true
    colorlinks: true
    toc: true
    toc-depth: 3
    lof: true                    # List of Figures
    lot: true                    # List of Tables
    keep-tex: true               # Retain .tex for debugging
---
```

### Fonts

```yaml
format:
  pdf:
    mainfont: "Times New Roman"
    sansfont: "Open Sans"
    monofont: "Roboto Mono"
    mathfont: "TeX Gyre Termes Math"
    fontsize: 12pt
    linestretch: 1.5
```

### Page Geometry

```yaml
format:
  pdf:
    geometry:
      - top=30mm
      - bottom=30mm
      - left=25mm
      - right=25mm
      - heightrounded
```

### PDF Engine

```yaml
format:
  pdf:
    pdf-engine: lualatex    # lualatex (default), pdflatex, xelatex, tectonic
```

### LaTeX Includes

```yaml
format:
  pdf:
    include-in-header:
      - text: |
          \usepackage{amsmath}
          \usepackage{booktabs}
          \usepackage{longtable}
      - file: custom-preamble.tex
    include-before-body:
      - file: before-body.tex
    include-after-body:
      - file: appendix.tex
```

### Raw LaTeX in Document Body

````markdown
```{=latex}
\begin{tabular}{|l|l|}\hline
Age & Frequency \\ \hline
18--25 & 15 \\
26--35 & 33 \\ \hline
\end{tabular}
```
````

### Typst PDF Output (Alternative to LaTeX)

Typst is a modern typesetting system bundled with Quarto -- no separate TeX installation needed. It produces PDF output with faster compilation, clearer error messages, and a simpler template language than LaTeX.

#### Basic Typst

```yaml
---
format:
  typst:
    papersize: us-letter
    margin:
      x: 1in
      y: 1in
    mainfont: "Linux Libertine"
    fontsize: 11pt
    number-sections: true
    toc: true
    columns: 1
    keep-typ: true         # Retain intermediate .typ file for debugging
---
```

Render: `quarto render doc.qmd --to typst`

#### Typst Fonts

```yaml
format:
  typst:
    mainfont: "Times New Roman"
    fontsize: 12pt
    font-paths:
      - fonts/              # Local directory with .ttf/.otf files
```

Typst searches system fonts by default. Use `font-paths` for bundled fonts.

#### Typst Page Layout

```yaml
format:
  typst:
    papersize: a4
    margin:
      top: 2.5cm
      bottom: 2.5cm
      left: 2cm
      right: 2cm
    columns: 2             # Two-column layout
```

#### Citations in Typst

Two citation processing options:

```yaml
# Option A: Pandoc/CSL (recommended -- use your journal's CSL file)
format:
  typst: default
bibliography: refs/library.bib
csl: csl/target-journal.csl
citeproc: true

# Option B: Typst's built-in citation system
format:
  typst:
    bibliographystyle: apa
bibliography: refs.bib
```

Use Option A (Pandoc/CSL) when you need a specific journal citation style.

#### Raw Typst in Document Body

````markdown
```{=typst}
#table(
  columns: 2,
  [*Age*], [*Frequency*],
  [18--25], [15],
  [26--35], [33],
)
```
````

#### Custom Typst Format (Extension)

```bash
quarto create extension format    # select "typst"
```

Generates `_extensions/name/` with `typst-template.typ` (layout) and `typst-show.typ` (metadata mapping). Package as a Quarto extension for reuse across papers.

#### LaTeX vs Typst Decision Guide

| Factor | LaTeX (`pdf`) | Typst (`typst`) |
|--------|---------------|-----------------|
| Install | Requires TeX distribution | Bundled with Quarto |
| Compile speed | Slower (multiple passes) | Fast (single pass, Rust) |
| Error messages | Cryptic | Clear, with line numbers |
| Template syntax | Complex (`.cls`/`.sty`) | Simple (`.typ` functions) |
| Package ecosystem | Massive (CTAN) | Growing, smaller |
| Math typesetting | Excellent | Good, improving |
| Journal `.cls` files | Use LaTeX | Use Typst |
| New custom templates | Consider Typst | Preferred |

---

## 10) HTML Output Configuration

### Feature-Rich HTML

```yaml
---
format:
  html:
    toc: true
    toc-depth: 3
    toc-location: left          # left, body, right
    toc-expand: 2
    number-sections: true
    code-fold: true
    code-tools: true
    anchor-sections: true
    smooth-scroll: true
    theme: cosmo                # Bootswatch theme
    css: styles.css
    embed-resources: true       # Self-contained single file
    link-external-icon: true
    link-external-newwindow: true
---
```

### Tabsets

```markdown
::: {.panel-tabset}
## Python
```python
print("Hello")
```

## R
```r
cat("Hello")
```
:::
```

### Callout Blocks

```markdown
:::{.callout-note}
Important information here.
:::

:::{.callout-warning}
## Custom Title
Watch out for this.
:::
```

Types: `note`, `tip`, `warning`, `caution`, `important`

---

## 11) Projects (`_quarto.yml`)

### Creating a Project

```bash
quarto create project default myproject
quarto create project website mysite
quarto create project book mybook
quarto create project manuscript mypaper
```

### Project Configuration

```yaml
# _quarto.yml
project:
  type: website
  output-dir: _site
  render:
    - "*.qmd"
    - "!drafts/"          # exclude drafts directory

# Shared settings (all documents inherit)
toc: true
number-sections: true
bibliography: references.bib

# Execution control
execute:
  freeze: auto

# Format defaults
format:
  html:
    theme: cosmo
    css: styles.css
  pdf:
    documentclass: scrartcl
```

### Metadata Hierarchy (highest priority wins)

1. Document YAML front matter
2. Directory `_metadata.yml`
3. Project `_quarto.yml`

### Working Directory

```yaml
project:
  execute-dir: project    # Execute from project root (default: file's directory)
```

Access project root in code: `os.environ["QUARTO_PROJECT_DIR"]`

---

## 12) All Output Formats

### Documents

`html`, `pdf`, `typst`, `docx`, `odt`, `epub`

### Presentations

`revealjs` (HTML slides), `pptx` (PowerPoint), `beamer` (LaTeX PDF slides)

### Markdown Variants

`gfm` (GitHub), `commonmark`, `hugo`, `docusaurus`, `markua`

### Scholarly

`jats` (Journal Article Tag Suite), `latex` (LaTeX source instead of PDF)

---

## 13) Markdown Essentials

### Text Formatting

| Effect | Syntax |
|--------|--------|
| *Italics* | `*italics*` |
| **Bold** | `**bold**` |
| ***Bold italics*** | `***bold italics***` |
| Superscript | `text^2^` |
| Subscript | `text~2~` |
| ~~Strikethrough~~ | `~~text~~` |
| `Code` | `` `code` `` |

### Links and Images

```markdown
[Link text](https://url)
![Caption](image.png)
![](image.png){fig-alt="Alt text" width=80%}
[![Clickable image](image.png)](https://url)
```

### Footnotes

```markdown
Text with a footnote.[^1]

[^1]: Footnote content.

Text with inline footnote.^[Inline footnote content.]
```

### Equations

```markdown
Inline: $E = mc^{2}$

Display:
$$
\hat{\beta} = (X'X)^{-1}X'y
$$
```

### Diagrams (Mermaid)

````markdown
```{mermaid}
flowchart LR
  A[Data] --> B[Clean]
  B --> C[Model]
  C --> D[Report]
```
````

### Divs and Spans

```markdown
::: {.classname}
Block content
:::

[Inline content]{.classname}
```

### Special Characters

- En-dash: `--`
- Em-dash: `---`
- Page break: `{{< pagebreak >}}`

---

## 14) CLI Commands Reference

```bash
# Render
quarto render doc.qmd                    # all formats defined in YAML
quarto render doc.qmd --to pdf           # specific format
quarto render doc.qmd --to html          # specific format
quarto render                            # entire project

# Preview (live reload)
quarto preview doc.qmd
quarto preview                           # entire project

# Execution control
quarto render doc.ipynb                  # .ipynb: NO re-execution (default)
quarto render doc.ipynb --execute        # .ipynb: FORCE re-execution
quarto render doc.qmd                    # .qmd: DOES execute (default)
quarto render doc.qmd --cache            # enable caching
quarto render doc.qmd --no-cache         # disable caching
quarto render doc.qmd --cache-refresh    # invalidate and re-execute cached

# Projects
quarto create project website mysite
quarto create project manuscript mypaper

# Templates
quarto use template quarto-journals/acm  # new project from template
quarto add quarto-journals/acm           # add extension to existing project

# Publishing
quarto publish quarto-pub                # Quarto Pub
quarto publish gh-pages                  # GitHub Pages
quarto publish netlify                   # Netlify
quarto publish connect                   # Posit Connect

# Extensions
quarto create extension journal          # create your own journal extension
```

---

## 15) Common Patterns and Recipes

### Self-Contained HTML Report (Email/Share)

```yaml
---
title: "Analysis Report"
date: today
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
    theme: cosmo
---
```

### Jupyter Notebook Rendered Without Re-Execution

Raw cell in `.ipynb`:

```yaml
---
title: "310 - Baseline Model"
author: "Harlan Nelson"
date: today
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
---
```

```bash
quarto render 310-Baseline-Model.ipynb
```

### Academic Paper (Quick Start)

```yaml
---
title: "Paper Title"
author:
  - name: Harlan Nelson
    corresponding: true
    affiliation:
      - name: Institution Name
abstract: |
  Abstract text here.
bibliography: references.bib
csl: journal-style.csl
format:
  pdf:
    documentclass: scrartcl
    number-sections: true
    keep-tex: true
  docx:
    reference-doc: templates/reference.docx
---
```

### Presentation (Reveal.js)

```yaml
---
title: "My Presentation"
format:
  revealjs:
    theme: dark
    slide-number: true
    transition: slide
---

## Slide 1

Content here.

## Slide 2

More content.
```

### Project with Frozen Execution

```yaml
# _quarto.yml
project:
  type: website

execute:
  freeze: auto

format:
  html:
    toc: true
    theme: cosmo
```

---

## 16) Inline Code

Embed computed values in narrative text:

**Python (Jupyter):**

```markdown
The mean age was `{python} mean_age` years.
```

**R (Knitr):**

```markdown
The mean age was `{r} mean(data$age)` years.
```

**Limitations:**
- Keep expressions simple (pre-computed values)
- Not supported inside YAML strings (titles, captions)
- In `.ipynb` files, inline expressions only evaluate during `quarto render` with `execute: enabled: true`

---

## 17) Summary: Execution Decision Tree

```
Want to render without re-executing code?
│
├── Using .ipynb?
│   └── Just run: quarto render notebook.ipynb
│       (Default behavior: outputs preserved)
│
├── Using .qmd in a project?
│   └── Set freeze: auto in _quarto.yml
│       Run once, then project renders skip re-execution
│
├── Using .qmd standalone?
│   ├── execute: enabled: false  (never run)
│   ├── execute: cache: true     (re-run only on code changes)
│   └── eval: false per-cell     (skip specific cells)
│
└── Want to FORCE execution?
    └── quarto render file.ipynb --execute
```
