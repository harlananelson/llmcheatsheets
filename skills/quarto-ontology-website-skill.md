# Quarto Ontology Website Skill

> **Usage:** Load this file into Claude Code or paste into an LLM session. It contains everything needed to build a professional personal website with Quarto, organized by a typed ontology system where every page declares what kind of content it is and metadata encodes relationships between pages.

This skill produces a static Quarto website where content pages have typed front matter (`node-type: project`, `node-type: role`, etc.), relationships are encoded as YAML metadata, and Quarto listings auto-generate index pages per type. No JavaScript, no database -- just convention-based structure.

---

## 1) The Pattern

Every content page declares a `node-type` in its YAML front matter. Relationships between pages are encoded as metadata fields. Quarto's listing feature auto-generates index pages from page metadata.

```
Person (index, about)
  └── has Projects (projects/*.qmd)
        └── uses Skills (skills: [r, python])
        └── produced-during Role (role: iuhealth)
  └── held Roles (experience/*.qmd)
        └── requires Skills (skills: [sql, r])
  └── authored Publications (publications.qmd)
        └── demonstrates Skills (skills: [statistics])
  └── wrote Writings (writings/*.qmd)
        └── categorized-as Topics (categories: [teaching])
```

The "graph" is the set of relationships in front matter. Quarto reads these fields and generates the site. No runtime query engine required.

---

## 2) Node Types and Their Front Matter

### Person (landing page, about page)

```yaml
---
title: "Your Name"
node-type: person
toc: false
---
```

### Project

```yaml
---
title: "Project Title"
description: "One-sentence summary for listing cards."
node-type: project
status: active          # active | complete | archived
role: iuhealth          # edge: produced-during → role page
skills: [r, tidymodels, shap]   # edge: uses-skill
categories: [healthcare-ai]     # Quarto cross-reference
date: 2024-01-01        # for listing sort order
github: "https://github.com/user/repo"  # optional
---
```

### Role (professional experience)

```yaml
---
title: "Job Title"
description: "Organization -- brief summary for listing cards."
node-type: role
organization: "Company Name"
start-date: 2021-02-01
skills: [r, sql, azure]         # edge: requires-skill
categories: [healthcare-ai]
---
```

### Writing (essays, teaching materials, blog posts)

```yaml
---
title: "Essay Title"
description: "Brief summary for listing cards."
node-type: writing
topic: bible-study              # or: tutorial, essay, reflection
audience: small-group           # or: developers, general
date: 2025-01-01
categories: [teaching, bible-study]
---
```

### Publication (peer-reviewed papers)

Publications can be individual pages or entries on a single page. For a single-page approach, use `node-type: publication-index` on the listing page.

### Skill

Skills are typically listed on a single page (`skills.qmd`) rather than individual pages. Use `node-type: skill-index`.

### Meta (self-describing pages)

```yaml
---
title: "How This Site Works"
node-type: meta
---
```

---

## 3) Edge Types (Relationships via Metadata)

| Edge | Encoding | Example |
|------|----------|---------|
| `uses-skill` | `skills: [r, tidymodels]` in project front matter | Project uses these tools |
| `produced-during` | `role: iuhealth` in project front matter | Project done during this role |
| `demonstrates` | `skills: [statistics]` in publication metadata | Paper demonstrates this expertise |
| `requires` | `skills: [r, sql]` in role front matter | Role requires these skills |
| `categorized-as` | `categories: [healthcare-ai]` | Standard Quarto categories |

---

## 4) Directory Structure

```
site-root/
├── _quarto.yml              # Site config with nav and render rules
├── _ontology-schema.yml     # Machine-readable schema (not rendered)
├── styles.css               # Custom styling
├── index.qmd                # Landing page (node-type: person)
├── about.qmd                # Personal story (node-type: person)
├── publications.qmd         # All publications on one page
├── skills.qmd               # Skill inventory on one page
├── projects/
│   ├── index.qmd            # Auto-listing of project pages
│   ├── _metadata.yml         # Default front matter for projects
│   ├── project-one.qmd
│   └── project-two.qmd
├── experience/
│   ├── index.qmd            # Auto-listing of roles
│   ├── _metadata.yml         # Default front matter for roles
│   ├── role-one.qmd
│   └── role-two.qmd
├── writings/
│   ├── index.qmd            # Auto-listing of writings
│   ├── _metadata.yml         # Default front matter for writings
│   └── essay-one.qmd
├── ontology/
│   └── index.qmd            # "How This Site Works" page
├── _archive/                 # Old files (gitignored, not rendered)
└── _publish.yml              # Deployment config (Netlify, GitHub Pages, etc.)
```

---

## 5) Key Configuration Files

### `_quarto.yml`

```yaml
project:
  type: website
  render:
    - "*.qmd"
    - "projects/"
    - "experience/"
    - "writings/"
    - "ontology/"
    - "!_archive/"
    # Exclude any non-website directories with !dirname/

website:
  title: "{SITE_TITLE}"
  navbar:
    left:
      - href: index.qmd
        text: Home
      - href: about.qmd
        text: About
      - href: projects/index.qmd
        text: Projects
      - href: experience/index.qmd
        text: Experience
      - href: publications.qmd
        text: Publications
      - href: skills.qmd
        text: Skills
      - href: writings/index.qmd
        text: Writings
      - href: ontology/index.qmd
        text: Ontology
    right:
      - icon: linkedin
        href: https://www.linkedin.com/in/{LINKEDIN_HANDLE}/
      - icon: github
        href: https://github.com/{GITHUB_HANDLE}

format:
  html:
    theme: cosmo
    css: styles.css
    toc: true
```

**Key points:**
- `render:` explicitly lists what to render and excludes non-site dirs with `!`
- Theme `cosmo` is clean and professional. Other good options: `flatly`, `lux`, `minty`
- `toc: true` globally enables table of contents on all pages

### Listing Index Pages

Each section with multiple pages gets a listing index:

```yaml
---
title: "Projects"
listing:
  contents: "*.qmd"
  type: default
  sort: "date desc"
  fields: [title, description, categories]
  filter-ui: false
  sort-ui: false
---

Brief introduction text for the section.
```

The listing auto-discovers all `.qmd` files in the same directory (excluding `index.qmd` itself) and generates cards from their front matter. **No manual maintenance needed** -- add a new `.qmd` file with the right front matter and it appears automatically.

### `_metadata.yml` (Section Defaults)

Each section directory gets a `_metadata.yml` that sets defaults:

```yaml
# projects/_metadata.yml
node-type: project
```

This means individual project pages don't need to repeat `node-type: project` (though they can for clarity).

### `_ontology-schema.yml`

Machine-readable schema documenting the type system. Not rendered by Quarto -- serves as documentation for the convention.

```yaml
node_types:
  project:
    required: [title, status, skills, summary]
    optional: [role, github, dates, categories]
    statuses: [active, complete, archived]
  role:
    required: [title, organization, start-date]
    optional: [end-date, skills, highlights]
  publication:
    required: [title, year, url]
    optional: [journal, domain, skills]
  skill:
    required: [name, category]
    optional: [proficiency, evidence]
    categories: [languages, frameworks, domains, tools]
    proficiency_levels: [foundational, working, advanced, expert]
  writing:
    required: [title, date, topic]
    optional: [audience, language]

edge_types:
  uses-skill: { from: project, to: skill }
  produced-during: { from: project, to: role }
  demonstrates: { from: publication, to: skill }
  requires: { from: role, to: skill }
  categorized-as: { from: any, to: category }
```

---

## 6) Page Templates

### Landing Page (`index.qmd`)

```markdown
---
title: "{YOUR_NAME}"
node-type: person
toc: false
---

::: {.hero-section}

# {YOUR_NAME}

::: {.lead}
{TITLE} | {DOMAIN_1} | {DOMAIN_2}
:::

{2-3 sentence professional summary. What you do, for whom, and what
makes your approach distinctive.}

:::

::: {.highlight-cards}

::: {.highlight-card}
### [{HIGHLIGHT_1_TITLE}]({LINK})
{2-sentence description of this area of work.}
:::

::: {.highlight-card}
### [{HIGHLIGHT_2_TITLE}]({LINK})
{2-sentence description.}
:::

::: {.highlight-card}
### [{HIGHLIGHT_3_TITLE}]({LINK})
{2-sentence description.}
:::

::: {.highlight-card}
### [{HIGHLIGHT_4_TITLE}]({LINK})
{2-sentence description.}
:::

:::

## Explore

- [About Me](about.qmd) -- {brief}
- [Projects](projects/index.qmd) -- {brief}
- [Experience](experience/index.qmd) -- {brief}
- [Publications](publications.qmd) -- {brief}
- [Skills](skills.qmd) -- {brief}
- [Writings](writings/index.qmd) -- {brief}
- [How This Site Works](ontology/index.qmd) -- {brief}
```

### About Page (`about.qmd`)

```markdown
---
title: "About Me"
node-type: person
---

# About Me

{Personal introduction -- 1 paragraph in the person's own voice.}

## My Values and Approach

- **{Value 1}:** {Explanation}
- **{Value 2}:** {Explanation}
- **{Value 3}:** {Explanation}

## How I Work

{2-3 paragraphs about professional approach, current focus,
philosophy of work.}

---

## Let's Connect

{Call to action with LinkedIn and GitHub links.}
```

### Project Page (`projects/{project-name}.qmd`)

```markdown
---
title: "{Project Title}"
description: "{One sentence for listing card.}"
node-type: project
status: active
role: {role-slug}
skills: [{skill1}, {skill2}, {skill3}]
categories: [{category1}, {category2}]
date: {YYYY-MM-DD}
github: "{REPO_URL}"
---

# {Project Title}

## Summary

{2-3 paragraphs: what it is, why it matters, what makes it interesting.}

## Key Methods

- **{Method 1}:** {Description}
- **{Method 2}:** {Description}

## Status

{Current state of the project and what's next.}
```

### Role Page (`experience/{role-slug}.qmd`)

```markdown
---
title: "{Job Title}"
description: "{Organization} -- {brief summary.}"
node-type: role
organization: "{Organization}"
start-date: {YYYY-MM-DD}
skills: [{skill1}, {skill2}]
categories: [{category}]
---

# {Job Title}

**{Organization}** | {Date Range}

::: {.timeline-entry}

### What I Do

{1-2 paragraphs about the role.}

### Key Contributions

- **{Contribution 1}:** {Description}
- **{Contribution 2}:** {Description}

### Tools & Methods

{Comma-separated list of tools and technologies.}

:::
```

### Publications Page (`publications.qmd`)

```markdown
---
title: "Publications"
node-type: publication-index
---

# Publications

{One-sentence intro.}

---

::: {.pub-entry}

### {Paper Title} {.pub-title}

::: {.pub-meta}
**Year:** {YYYY} | **Journal:** *{Journal Name}* | **Domain:** {Domain}
**Skills:** [{skill1}]{.badge}, [{skill2}]{.badge}
:::

{1-2 sentence summary of the paper.}

[PubMed]({URL}){.btn .btn-sm .btn-outline-primary}

:::
```

Repeat the `:::{.pub-entry}` block for each publication.

### Skills Page (`skills.qmd`)

```markdown
---
title: "Skills"
node-type: skill-index
---

# Skills

{Brief intro.}

---

## {Category Name}

::: {.skill-category}
::: {.skill-list}
- [{Skill}]{.expert} -- {context}
- [{Skill}]{.advanced}
- [{Skill}]{.working}
:::
:::

---

*Proficiency levels:*
[expert]{.expert} = daily use, deep knowledge |
[advanced]{.advanced} = regular use, strong proficiency |
[working]{.working} = functional, growing
```

### Ontology Page (`ontology/index.qmd`)

This is the "How This Site Works" page. It should explain:

1. **What node types exist** and what they represent (with links to example pages)
2. **How relationships are encoded** as YAML metadata (with a concrete example)
3. **Why this approach is useful** (consistency, discoverability, the idea itself)
4. **What it is not** (not a graph database, not JavaScript -- convention-based)
5. **Where the schema lives** (link to `_ontology-schema.yml`)

---

## 7) Styles (`styles.css`)

```css
/* Hero section on landing page */
.hero-section {
  padding: 2rem 0 3rem 0;
  margin-bottom: 2rem;
  border-bottom: 2px solid #e9ecef;
}

.hero-section h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.hero-section .lead {
  font-size: 1.25rem;
  color: #6c757d;
  margin-bottom: 1.5rem;
}

/* Highlight cards on landing page */
.highlight-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.highlight-card {
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 1.5rem;
  transition: box-shadow 0.2s;
}

.highlight-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.highlight-card h3 {
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.highlight-card p {
  font-size: 0.95rem;
  color: #555;
  margin-bottom: 0;
}

/* Timeline styling for experience */
.timeline-entry {
  border-left: 3px solid #2c3e50;
  padding-left: 1.5rem;
  margin-bottom: 2rem;
  position: relative;
}

.timeline-entry::before {
  content: '';
  position: absolute;
  left: -7px;
  top: 0;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #2c3e50;
}

.timeline-entry h3 {
  margin-top: 0;
}

/* Skill badges */
.skill-category {
  margin-bottom: 2rem;
}

.skill-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  list-style: none;
  padding: 0;
}

.skill-list li {
  background: #f1f3f5;
  padding: 0.35rem 0.75rem;
  border-radius: 4px;
  font-size: 0.9rem;
}

.skill-list li.expert {
  background: #2c3e50;
  color: white;
}

.skill-list li.advanced {
  background: #34495e;
  color: white;
}

.skill-list li.working {
  background: #d5e8d4;
}

/* Ontology diagram styling */
.ontology-diagram {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 1.5rem;
  margin: 1.5rem 0;
}

/* Publication entries */
.pub-entry {
  padding: 1rem 0;
  border-bottom: 1px solid #eee;
}

.pub-entry:last-child {
  border-bottom: none;
}

.pub-entry .pub-title {
  font-weight: 600;
}

.pub-entry .pub-meta {
  font-size: 0.9rem;
  color: #6c757d;
}
```

---

## 8) Build and Deploy

### Render

```bash
quarto render
```

All pages should render with no errors. Verify:
- Listing pages populate (projects, experience, writings show entries)
- Navigation works across all sections
- No blank pages

### Preview

```bash
quarto preview
```

### Deploy (Netlify)

```bash
# First time: creates _publish.yml with site ID
quarto publish netlify

# Subsequent deploys
quarto publish netlify
```

### Deploy (GitHub Pages)

```bash
quarto publish gh-pages
```

---

## 9) Adding New Content

### Add a New Project

1. Create `projects/new-project.qmd` with the project front matter template
2. Ensure `status`, `skills`, `categories`, and `date` are filled in
3. Run `quarto render` -- the listing page auto-discovers it

### Add a New Role

1. Create `experience/new-role.qmd` with the role front matter template
2. Ensure `organization`, `start-date`, and `skills` are filled in
3. Run `quarto render`

### Add a New Writing

1. Create `writings/new-essay.qmd` with the writing front matter template
2. Ensure `topic`, `date`, and `categories` are filled in
3. Run `quarto render`

### Add a New Publication

Add a new `:::{.pub-entry}` block to `publications.qmd`.

### Add a New Node Type

1. Define the type in `_ontology-schema.yml`
2. Create a directory with `index.qmd` (listing) and `_metadata.yml`
3. Add the section to `_quarto.yml` navbar and render list
4. Update `ontology/index.qmd` to document the new type

---

## 10) Adapting the Schema

### For a Software Developer Portfolio

```yaml
node_types:
  project:
    required: [title, status, skills, summary]
    optional: [role, github, demo-url, dates]
    statuses: [active, complete, archived, maintained]
  role:
    required: [title, organization, start-date]
    optional: [end-date, skills, team-size]
  open-source:
    required: [title, github, skills]
    optional: [stars, contributors, language]
  talk:
    required: [title, date, venue]
    optional: [slides-url, video-url, topic]
```

### For a Researcher / Academic

```yaml
node_types:
  project:
    required: [title, status, skills, summary]
    optional: [funding, collaborators, dates]
    statuses: [active, complete, archived, submitted]
  publication:
    required: [title, year, journal]
    optional: [doi, impact-factor, citations, preprint-url]
  grant:
    required: [title, funder, amount, dates]
    optional: [role, status, collaborators]
  course:
    required: [title, institution, semester]
    optional: [enrollment, level, materials-url]
  student:
    required: [name, degree, year]
    optional: [thesis-title, current-position]
```

### For a Consultant / Freelancer

```yaml
node_types:
  engagement:
    required: [title, client-type, skills, summary]
    optional: [duration, industry, outcome]
  service:
    required: [title, description]
    optional: [pricing-model, typical-duration]
  testimonial:
    required: [quote, client-type]
    optional: [client-name, date, engagement]
  case-study:
    required: [title, challenge, solution, outcome]
    optional: [skills, industry, duration]
```

### For an Artist / Creative

```yaml
node_types:
  work:
    required: [title, medium, date]
    optional: [series, dimensions, price, status]
    statuses: [available, sold, exhibited, private]
  exhibition:
    required: [title, venue, date]
    optional: [type, curator, works-shown]
  collection:
    required: [title, theme]
    optional: [works, date-range]
```

---

## 11) What Not to Do

- **Don't build a graph database.** The value is in consistent structure, not in query infrastructure. YAML front matter is the graph.
- **Don't add JavaScript.** Static Quarto is fast, accessible, and deployable anywhere. If you need interactivity, use Quarto's built-in features (tabsets, collapsibles) not custom JS.
- **Don't over-type.** Start with 4-6 node types. Add more only when you have content that doesn't fit existing types. A type with one instance is premature.
- **Don't make the ontology page optional.** The "How This Site Works" page is part of what makes this approach interesting. It shows you think about structure, not just content.
- **Don't skip the schema file.** `_ontology-schema.yml` is cheap to create and documents the convention for future you (or a future LLM session).

---

## 12) Quarto Prerequisites

- Quarto >= 1.3 (for listing features)
- No R or Python needed for the site itself (it's pure markdown + YAML)
- Deployment: Netlify, GitHub Pages, or any static host

Install: https://quarto.org/docs/get-started/

---

## 13) Worked Example: Complete Minimal Site

For a developer named "Alex Chen" with 2 projects and 1 role:

**File count:** 11 files total

```
_quarto.yml, styles.css, _ontology-schema.yml,
index.qmd, about.qmd, skills.qmd,
projects/index.qmd, projects/_metadata.yml, projects/my-tool.qmd,
experience/index.qmd, experience/current-job.qmd
```

This renders to 7 pages. Add writings/, publications.qmd, and ontology/ as content warrants. The structure scales from 7 pages to 70 without changing the architecture.
