# Ontology-Organized Personal Websites with Quarto

A pattern for building professional websites where every page declares what kind of content it is, and metadata encodes relationships between pages. The structure is a lightweight knowledge graph -- no database, no JavaScript, just typed YAML front matter and Quarto listings.

---

## Who This Is For

You want a personal or portfolio website that is:

- **Structured:** Every page has a consistent type (project, role, publication, writing)
- **Self-maintaining:** Add a new `.qmd` file and it appears in listings automatically
- **Explainable:** A "How This Site Works" page documents the type system itself
- **LLM-friendly:** An LLM can build or extend the site from the schema alone

And you want to build it with Quarto (static site generator, no backend needed).

---

## The Core Idea

Most personal sites are flat collections of pages with ad-hoc structure. This pattern adds a type layer:

1. Every page declares a `node-type` in its YAML front matter (`project`, `role`, `writing`, etc.)
2. Relationships between pages are encoded as metadata fields (`skills: [r, python]`, `role: iuhealth`)
3. Quarto listings auto-generate index pages from page metadata
4. A machine-readable schema (`_ontology-schema.yml`) documents the convention

The result is a website that is both human-readable and machine-parseable. The "graph" is the set of relationships in front matter -- the same approach as convention-based ontologies in research projects, applied to personal web presence.

---

## Where This Comes From

This pattern grew out of using Claude Code configuration files as Phase 1 scaffolding for typed knowledge systems -- constraints, assumptions, validation gates, evidence quality scores. The key insight was that `.claude/rules/` files naturally map to components of a domain ontology (see [claude-code-architecture-review.md](claude-code-architecture-review.md)).

The insight: **the same principle of typed, connected knowledge applies to organizing any body of work**, not just clinical research. A personal website is a knowledge graph where the nodes are projects, roles, publications, and skills, and the edges are "uses," "produced-during," "demonstrates."

For the full methodology on domain ontologies and Claude Code, see [`claude-code-architecture-review.md`](claude-code-architecture-review.md).

---

## Quick Start

### 1. Feed the skill to an LLM

Load [`skills/quarto-ontology-website-skill.md`](../skills/quarto-ontology-website-skill.md) into a Claude Code session or paste it into any LLM.

### 2. Provide your content

Tell the LLM:
- Your name, title, and professional summary
- 2-4 highlight areas for the landing page
- Your projects (name, status, skills used, brief description)
- Your roles (organization, dates, key contributions)
- Your publications (title, journal, year, URL)
- Your skills by category
- Any writings or essays to include

### 3. Customize the schema

The skill includes schema variants for:
- **Software developers** (projects, open-source, talks)
- **Researchers** (publications, grants, courses, students)
- **Consultants** (engagements, services, testimonials, case studies)
- **Artists** (works, exhibitions, collections)

Pick the one closest to your needs, or start with the default and adapt.

### 4. Build and deploy

```bash
quarto render        # Build the site
quarto preview       # Preview locally
quarto publish netlify   # Deploy to Netlify
```

---

## Adapting to Other Domains

The typed-page pattern works for any content that has:

- **Multiple types** of pages (not just "blog posts")
- **Relationships** between pages (projects use skills, roles produce projects)
- **Listing needs** (auto-generated index pages per type)

Examples beyond personal sites:

| Domain | Node Types | Key Edges |
|--------|-----------|-----------|
| **Documentation site** | concept, tutorial, reference, example | tutorial `requires` concept, example `demonstrates` concept |
| **Course site** | module, lesson, assignment, resource | lesson `belongs-to` module, assignment `uses` resource |
| **Product catalog** | product, category, feature, use-case | product `has-feature`, use-case `requires` product |
| **Research lab** | project, person, publication, dataset | publication `uses` dataset, person `works-on` project |

The skill file provides the Quarto-specific implementation. Swap the node types and front matter fields for your domain.

---

## Files

| File | Purpose |
|------|---------|
| [`skills/quarto-ontology-website-skill.md`](../skills/quarto-ontology-website-skill.md) | Self-contained LLM reference -- everything needed to build a site |
| [`guides/claude-code-architecture-review.md`](claude-code-architecture-review.md) | The broader methodology: domain ontologies via Claude Code config |

---

## Key Design Decisions

**Why YAML front matter, not a database?** Convention-based structure ships immediately, requires no infrastructure, and degrades gracefully. If you stop maintaining the convention, you still have a working website -- just a less structured one.

**Why a visible ontology page?** The "How This Site Works" page serves double duty: it's interesting content for visitors, and it forces you to keep the type system coherent (if you can't explain it, it's too complex).

**Why Quarto?** Static sites are fast, cheap to host, and version-controlled. Quarto's listing feature does the work of auto-generating index pages from metadata -- the key enabler that makes typed front matter useful rather than just decorative.

**Why not just use categories?** Categories are one dimension of the type system. Node types add a second dimension: *what kind of thing is this page?* A project tagged `healthcare-ai` and a writing tagged `healthcare-ai` are in the same category but are fundamentally different types of content, displayed differently, with different required fields.
