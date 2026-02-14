# Ontology Scaffold Templates

Generic templates for bootstrapping a Claude Code project with the ontology architecture pattern described in `guides/claude-code-architecture-review.md`.

## What This Is

A set of template files that create the full ontology scaffold for any domain project. Copy the templates, replace `{PLACEHOLDERS}`, and you have a working Phase 1 scaffold without needing to reverse-engineer an existing implementation.

## Usage

```bash
# 1. Copy templates to your project
cp -r templates/ontology-scaffold/rules/ /path/to/project/.claude/rules/
cp templates/ontology-scaffold/CLAUDE.md.template /path/to/project/CLAUDE.md

# 2. Replace placeholders (all caps, curly braces)
#    {PROJECT_NAME}, {DOMAIN_DESCRIPTION}, {STAKEHOLDER}, etc.

# 3. Customize for your domain
#    - Add domain-specific node types to ontology-schema.md
#    - Fill constraint tables with real constraints
#    - Populate assumption registry with known assumptions
#    - Adjust authority scoring source types for your field
#    - Define method decision tree for your workflows
#    - Set validation gates appropriate to your domain
```

## Files

| Template | Target Location | Purpose |
|----------|----------------|---------|
| `CLAUDE.md.template` | `CLAUDE.md` | Decision rules: mode selection, LLM boundary, invariants (~150 lines) |
| `rules/ontology-schema.md` | `.claude/rules/ontology-schema.md` | Node types, edge types, validation states |
| `rules/domain-constraints.md` | `.claude/rules/domain-constraints.md` | Constraint library with durability ratings |
| `rules/assumption-registry.md` | `.claude/rules/assumption-registry.md` | Known assumptions with sensitivity and test methods |
| `rules/authority-scoring.md` | `.claude/rules/authority-scoring.md` | Deterministic source quality formula |
| `rules/method-decision-tree.md` | `.claude/rules/method-decision-tree.md` | Approach selection logic |
| `rules/validation-gates.md` | `.claude/rules/validation-gates.md` | Gate criteria with 6-state validation |
| `rules/output-conventions.md` | `.claude/rules/output-conventions.md` | Processing pipeline section template |

## Placeholder Convention

All placeholders use `{ALL_CAPS_WITH_UNDERSCORES}`. Required placeholders (must be replaced before use):

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{PROJECT_NAME}` | Short project name | "Azure DevOps Tooling" |
| `{DOMAIN_DESCRIPTION}` | One-line domain description | "Clinical research data analysis" |
| `{STAKEHOLDER}` | Primary stakeholder or team | "Dr. Smith" or "Platform Engineering" |
| `{TASK_SOURCE}` | Where tasks come from | "GitHub issues" or "Azure DevOps board" |

Optional placeholders (replace or delete the containing section):

| Placeholder | Description |
|-------------|-------------|
| `{SYNTHESIS_TRIGGER}` | What triggers lightweight reasoning mode |
| `{CREATION_TRIGGER}` | What triggers rigorous reasoning mode |
| `{DOMAIN_NODE_*}` | Domain-specific node types to add |
| `{CONSTRAINT_*}` | Domain constraints to populate |
| `{ASSUMPTION_*}` | Domain assumptions to populate |

## Relationship to Other Files

- **Architecture guide:** `guides/claude-code-architecture-review.md` explains WHY this pattern works
- **These templates:** provide WHAT to create (ready to customize)
- **Worked examples:** SCDCernerProject (clinical research), azure project (DevOps tooling)

## Customization Depth

| Level | Effort | Result |
|-------|--------|--------|
| **Minimal** | Replace required placeholders only | Working scaffold with generic structure |
| **Standard** | Replace all placeholders + add 5-10 domain constraints/assumptions | Useful scaffold that catches common reasoning errors |
| **Full** | Populate all tables, add domain-specific node types, define complete method tree | Production-quality reasoning architecture |
