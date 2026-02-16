# Claude Code Setup Guide

How to configure Claude Code for reproducible, project-aware AI assistance.
This guide covers the configuration hierarchy, file formats, and a new-machine setup checklist.

---

## 1) Configuration Hierarchy

Claude Code reads context from multiple layers. Higher layers override lower ones:

```
Highest priority
  │
  ├── 1. ~/.claude/settings.local.json     (user-global permissions)
  ├── 2. ~/projects/CLAUDE.md              (global project context -- parent of all repos)
  ├── 3. project/CLAUDE.md                 (repo-level context)
  ├── 4. project/.claude/settings.local.json (project-scoped permissions)
  │
Lowest priority
```

**Key distinction:**
- `CLAUDE.md` files provide **instructions and context** (free-form Markdown).
- `settings.local.json` files provide **permissions** (structured JSON).

---

## 2) Global CLAUDE.md

### What It Is

A Markdown file placed at the parent directory of all your projects (e.g., `~/projects/CLAUDE.md`).
Claude Code loads it automatically for any session started under that directory tree.

**This file is NOT inside any git repo** -- it spans all repos. That's why this guide exists: to document and template its contents so they can be reproduced on a new machine.

### Where It Lives

```
~/projects/
├── CLAUDE.md              <-- global context (not in any repo)
├── llmcheatsheets/        <-- repo
├── txtarchive/            <-- repo
├── myanalysis/            <-- repo
└── ...
```

### What to Put in It

The global CLAUDE.md should contain cross-cutting context that applies to ALL your projects:

1. **Tool references** -- txtarchive commands, Quarto patterns, GitHub CLI usage
2. **Versioning conventions** -- analysis file numbering (NNN-Description)
3. **Project structure conventions** -- where analyses, data, and outputs live
4. **Language ecosystem context** -- R/tidymodels patterns, Python stack
5. **Notes** -- pointers to detailed references (e.g., skill files)

See [`templates/claude-md-global.md`](../templates/claude-md-global.md) for a fill-in-the-blanks template.

### Example (Abbreviated)

```markdown
# Global Project Context

This is the authority for all projects under `/projects/`.

---

## TxtArchive - Code Archiving Tool

**Location:** `/projects/txtarchive/`

### Common Commands
\`\`\`bash
python -m txtarchive archive myproject/ output.txt \
    --file_types .py .ipynb .qmd .R \
    --llm-friendly --extract-code-only
\`\`\`

---

## Analysis Versioning Convention

| Range   | Purpose                              |
|---------|--------------------------------------|
| 000-099 | Configuration, setup, data prep      |
| 100-199 | Exploratory data analysis            |
| 200-299 | Feature engineering, cohort building |
| 300-399 | Modeling, machine learning           |
| 400-499 | Validation, sensitivity analysis     |
| 500+    | Final outputs, reports               |

---

## R/tidymodels Context

### Key Packages
- tidymodels, ranger, yardstick, probably, vip, gtsummary, gt, targets

---

## Quarto Document Authoring

**Full reference:** `/projects/llmcheatsheets/skills/quarto-skill.md`

---

## Notes

- This file is loaded automatically for all projects under `/projects/`
- Project-specific CLAUDE.md files add context, they don't replace this
```

---

## 3) Project CLAUDE.md

### What It Is

A Markdown file at the root of a specific repo. It provides project-specific context that extends (not replaces) the global CLAUDE.md.

### Placement Options

```
project/
├── CLAUDE.md                 # Option A: repo root (recommended)
└── .claude/
    └── CLAUDE.md             # Option B: hidden directory
```

Option A is preferred -- it's visible and easy to edit.

### Recommended Sections for Data Analysis Projects

1. **Project overview** -- one paragraph describing the analysis goal
2. **Data sources** -- table of datasets, schemas, key columns
3. **Key outcome** -- what's being predicted/measured
4. **Analysis progression** -- table mapping file numbers to descriptions
5. **Required packages** -- R and/or Python dependencies
6. **Known gotchas** -- data quirks, encoding issues, join pitfalls
7. **Review checklist** -- what to verify before committing

See [`templates/claude-md-project.md`](../templates/claude-md-project.md) for a fill-in-the-blanks template.

### Example

```markdown
# Customer Churn Prediction

Retrospective cohort study of churn predictors for a SaaS product
using warehouse data from the analytics database.

## Data Sources

| Table             | Description               | Key Columns              |
|-------------------|---------------------------|--------------------------|
| users             | Account demographics      | user_id, signup_date     |
| events            | Product usage events      | event_type, timestamp    |
| subscriptions     | Billing and plan info     | plan_tier, renewal_date  |

## Key Outcome

Binary 90-day churn: `churned` (1 = no active subscription 90 days after renewal date).

## Analysis Progression

| File | Description                  |
|------|------------------------------|
| 010  | Data extraction and QC       |
| 110  | EDA: usage patterns, segments|
| 210  | Feature engineering          |
| 310  | Baseline logistic regression |
| 320  | Tuned model + SHAP           |

## Required Packages

pacman::p_load(tidymodels, ranger, vip, gtsummary, gt, survival, pROC)
```

---

## 4) Permissions (`settings.local.json`)

### Format

```json
{
  "permissions": {
    "allow": [
      "ToolName(pattern:*)"
    ]
  }
}
```

### Locations

| File | Scope |
|------|-------|
| `~/.claude/settings.local.json` | All projects (user-global) |
| `project/.claude/settings.local.json` | One project only |

### Common Permission Patterns

**R/data analysis project:**

```json
{
  "permissions": {
    "allow": [
      "Bash(Rscript:*)",
      "Bash(quarto:*)",
      "Bash(python3:*)",
      "Bash(python -m txtarchive:*)",
      "Bash(pip install:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh:*)",
      "WebSearch"
    ]
  }
}
```

**Python ML project:**

```json
{
  "permissions": {
    "allow": [
      "Bash(python3:*)",
      "Bash(pip install:*)",
      "Bash(pip show:*)",
      "Bash(pytest:*)",
      "Bash(python -m txtarchive:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "WebSearch"
    ]
  }
}
```

**Minimal (read-only exploration):**

```json
{
  "permissions": {
    "allow": [
      "Bash(tree:*)",
      "Bash(wc:*)",
      "Bash(ls:*)",
      "WebSearch"
    ]
  }
}
```

See [`templates/settings-local-project.json`](../templates/settings-local-project.json) for a starter file.

---

## 5) The `.claude/` Directory

Beyond `settings.local.json`, the `.claude/` directory can hold additional context files:

```
project/.claude/
├── settings.local.json       # permissions
├── CLAUDE.md                 # alternative location for project context
└── rules/                    # additional context files (auto-discovered)
    ├── data-dictionary.md
    └── coding-standards.md
```

All `.md` files in `.claude/rules/` (including subdirectories) are **auto-discovered and auto-loaded** every session. No import directives needed -- just drop a markdown file in the directory and it loads.

**Note:** `.claude/context/` is NOT a Claude Code feature. Files placed there will not be auto-loaded. Use `.claude/rules/` as the extraction target.

### Private Content Warning

Some rules files contain content that should NOT be committed to version control:

- **Career/workplace context** (manager names, org dynamics, personal goals)
- **Proprietary data dictionaries** (internal table names, column schemas, system details)
- **Domain constraints with trade secrets** (internal thresholds, business logic)

Add private rules files to `.gitignore`:

```gitignore
# Private Claude Code context
.claude/rules/career.md
.claude/rules/proprietary-*.md
.claude/settings.local.json
```

The `settings.local.json` file is local by convention (the `local` in the name means "don't commit") and should always be in `.gitignore`.

**Rule of thumb:** If the content would be inappropriate in a public README, it shouldn't be committed as a rules file either. Claude loads it the same way regardless of whether it's tracked by git.

### When to Use It

- **Small projects:** A root `CLAUDE.md` is sufficient.
- **Large projects with extensive context:** Use `.claude/rules/` to split context into focused files (data dictionary, domain glossary, review checklist) so the main CLAUDE.md stays concise.

---

## 6) Memory System

Claude Code maintains a persistent memory across sessions:

```
~/.claude/projects/<encoded-path>/memory/MEMORY.md
```

The `<encoded-path>` is derived from your working directory. For example, working from `/home/user/projects` produces:

```
~/.claude/projects/-home-user-projects/memory/MEMORY.md
```

### How It Works

- Contents of `MEMORY.md` are injected into the system prompt at the start of every session.
- Claude Code writes to it automatically when it learns something useful.
- You can also edit it manually.
- Keep it concise (under 200 lines) -- lines beyond that are truncated.

### What to Store in Memory

- Patterns that worked or failed
- Project-specific gotchas discovered during sessions
- Preferred approaches (e.g., "always use pacman::p_load, not library()")
- Links to important files or docs

---

## 7) Custom Skills (`SKILL.md`)

Skills teach Claude how to do something specific to your work. When you ask Claude something that matches a skill's purpose, it automatically applies the skill's instructions.

### How Skills Work

- Claude pre-loads only the **name and description** of every installed skill at startup (~100 tokens each)
- Full instructions load only when Claude determines the skill is relevant (**progressive disclosure**)
- You can have dozens of skills without bloating context

### Skill Locations

| Location | Scope | Shared? |
|----------|-------|---------|
| `~/.claude/skills/skill-name/SKILL.md` | User-level (all projects) | No (personal) |
| `.claude/skills/skill-name/SKILL.md` | Project-level | Yes (committed to repo) |

### SKILL.md Format

Every skill file starts with YAML frontmatter:

```yaml
---
name: commit-messages
description: Generate commit messages following our team's conventions. Use when creating commits or when the user asks for help with commit messages.
---
```

The **description is critical** -- Claude uses it to decide when to auto-apply the skill. Be specific about trigger conditions.

Below the frontmatter, write the actual instructions in Markdown.

### Example: Code Review Skill

```markdown
---
name: code-review-standards
description: Apply our team's code review standards when reviewing PRs or suggesting improvements. Use when reviewing code, discussing best practices, or when the user asks for feedback on implementation.
---

# Code Review Standards

All reviews should check:
1. Error handling covers edge cases
2. Functions have clear single responsibilities
3. No hardcoded credentials or secrets
4. Tests cover the happy path and at least one error path

Format: `type(scope): description` (under 50 characters)
```

### Supporting Files

If you have extensive reference material, put it in a separate file in the skill folder and reference it from SKILL.md. Claude reads supporting files only when needed:

```
~/.claude/skills/quarto/
├── SKILL.md              # Quick reference + pointer to full docs
└── references/
    └── full-reference.md  # Comprehensive guide (read on demand)
```

### Skills Beyond Code

Skills aren't limited to code patterns. Use them for anything you repeatedly explain:
- Database query patterns specific to your schema
- API documentation formats your organization uses
- Meeting notes templates
- Clinical data conventions
- Analysis review checklists

### Managing Skills

```bash
# See what skills Claude has loaded
# Ask Claude: "What skills do you have available?"

# Or check settings → capabilities → skills
```

---

## 8) Custom Subagents (`agents/`)

Subagents are separate Claude instances with their own context window, system prompt, and tool permissions. They operate independently and return a summary to the main conversation.

### Why Subagents Matter

- Context degradation happens around 45% of your context window
- Subagents get a **fresh** context for their specific task
- Main agent only holds the summary, keeping the main conversation clean
- Prevents the context pollution that kills long coding sessions

### Built-In Subagents

| Agent | Purpose | Tools |
|-------|---------|-------|
| **Explore** | Fast, read-only codebase search and analysis | Read, Grep, Glob |
| **Plan** | Research agent for gathering context before architectural decisions | Read, Grep, Glob |
| **General-purpose** | Complex, multi-step tasks requiring exploration and action | All tools |

### Creating Custom Subagents

Add a Markdown file to `~/.claude/agents/` (user-level) or `.claude/agents/` (project-level, shared with team).

#### Agent File Format

```yaml
---
name: security-reviewer
description: Reviews code for security vulnerabilities. Invoke when checking for auth issues, injection risks, or data exposure.
tools: Read, Grep, Glob
---
```

The `tools` field controls what the subagent can do:
- **Read-only reviewer**: `Read, Grep, Glob`
- **Implementation agent**: `Read, Grep, Glob, Write, Edit, Bash`

Below the frontmatter, write the system prompt:

```markdown
You are a security-focused code reviewer. When analyzing code:
1. Check for authentication and authorization gaps
2. Look for injection vulnerabilities (SQL, command, XSS)
3. Identify sensitive data exposure risks
4. Flag insecure dependencies

Provide specific file and line references for each finding.
Categorize by severity: critical, high, medium, low.
```

### How Subagents Communicate

1. Main agent identifies a task suitable for delegation
2. Main agent invokes subagent with a specific prompt
3. Subagent executes in its own context window
4. Subagent returns a summary of findings/actions
5. Main agent incorporates the summary and continues

**The summary is the key.** A well-designed subagent returns a concise, structured summary -- not its entire context. This is why the system prompt should be explicit about output format.

### Practical Subagent Patterns

**Large refactoring:** Main agent identifies files, spins up a subagent per logical group. Each handles its scope and returns a summary.

**Code review pipeline:** Run three subagents in parallel (style-checker, security-scanner, test-coverage). Each returns findings in a consistent format; main agent synthesizes into a single review.

**Research tasks:** Delegate to Explore with specific questions. Returns a distilled map of relevant files and patterns, keeping main context clean.

### Constraints

- Subagents **cannot spawn other subagents** (prevents infinite nesting)
- Each subagent gets its own fresh context window
- Communication is through the delegation-and-return pattern only

### Example Custom Agents

```
~/.claude/agents/
├── phi-reviewer.md       # Scans for PHI exposure (clinical research)
└── quarto-checker.md     # Validates QMD conventions
```

---

## 9) MCP Connectors

MCP (Model Context Protocol) is a standardized way for Claude to call external tools and data sources through a unified interface. Instead of switching between GitHub, Slack, databases, and issue trackers, Claude can access all of them directly.

### Adding MCP Connections

```bash
# HTTP transport (recommended for remote servers)
claude mcp add --transport http <name> <url>

# With authentication
claude mcp add --transport http github https://api.github.com/mcp \
  --header "Authorization: Bearer your-token"
```

### Via Plugin System

Claude Code plugins bundle MCP servers with skills:

```bash
# Install a plugin that includes MCP servers
claude plugin install bio-research@knowledge-work-plugins

# List installed plugins and their MCP connections
claude plugin list
```

### Recommended MCP Connections

| Service | Purpose |
|---------|---------|
| **GitHub** | Repository management, issues, PRs, code search |
| **Slack** | Channel history, thread summaries, message search |
| **Google Drive** | Document access for reference during implementation |
| **PostgreSQL/databases** | Direct queries without leaving Claude |
| **Linear/Jira** | Issue tracking integration |

### The Compound Effect

The real power is the combination:
- **Skill** encodes your conventions (how to do something)
- **Subagent** handles complex subtasks (isolated context for each)
- **MCP** connects external services (no context switching)

A workflow that used to require five context switches (check issue tracker, review Slack discussion, look at the design, implement the code, update the ticket) now happens in one continuous session.

### Managing MCP

```bash
# View current MCP connections
# Run /mcp in Claude Code

# Check what MCP tools are available
# Ask Claude: "What MCP tools do you have?"
```

### Security Note

Third-party MCP servers are not verified by Anthropic. For sensitive integrations:
- Review the server's source code
- Use official connectors from service providers when available
- Be cautious with servers that have write access to production systems

---

## 10) New Machine Setup Checklist

### Step 1: Install Claude Code

```bash
# Install via npm
npm install -g @anthropic-ai/claude-code

# Or via Homebrew (macOS)
brew install claude-code
```

### Step 2: Authenticate

```bash
claude
# Follow the authentication prompts
```

### Step 3: Create the Global CLAUDE.md

```bash
# Copy the template to your projects root
cp llmcheatsheets/templates/claude-md-global.md ~/projects/CLAUDE.md

# Edit to fill in your specific paths, packages, conventions
```

### Step 4: Set Up User-Global Permissions

```bash
mkdir -p ~/.claude
cat > ~/.claude/settings.local.json << 'EOF'
{
  "permissions": {
    "allow": [
      "WebSearch",
      "Bash(pip install:*)",
      "Bash(python3:*)",
      "Bash(python -m txtarchive:*)",
      "Bash(git lfs:*)"
    ]
  }
}
EOF
```

### Step 5: Set Up Project-Level Permissions (Per Repo)

```bash
mkdir -p myproject/.claude
cp llmcheatsheets/templates/settings-local-project.json myproject/.claude/settings.local.json
# Edit to match the project's needs
```

### Step 6: Create Project CLAUDE.md (Per Repo)

```bash
cp llmcheatsheets/templates/claude-md-project.md myproject/CLAUDE.md
# Edit to describe the project
```

### Step 7: Verify

```bash
cd ~/projects/myproject
claude

# In the Claude Code session, ask:
# "What context do you see from CLAUDE.md?"
# Verify it loaded both global and project context.
```

### Step 8: Install Supporting Tools

```bash
# GitHub CLI (for issue-driven workflows)
sudo apt install gh   # or brew install gh
gh auth login

# txtarchive (for code archiving)
pip install txtarchive

# Quarto (for document rendering)
# See https://quarto.org/docs/get-started/
```

---

### Step 9: Install Custom Skills

```bash
# Create skill directories
mkdir -p ~/.claude/skills/quarto
mkdir -p ~/.claude/skills/txtarchive

# Copy or create SKILL.md files with YAML frontmatter
# See Section 7 for the format
```

### Step 10: Create Custom Agents (Optional)

```bash
# Create agents directory
mkdir -p ~/.claude/agents

# Add agent markdown files
# See Section 8 for the format
```

---

## Summary

| What | Where | Purpose |
|------|-------|---------|
| Global CLAUDE.md | `~/projects/CLAUDE.md` | Cross-project context |
| Project CLAUDE.md | `repo/CLAUDE.md` | Repo-specific context |
| User-global permissions | `~/.claude/settings.local.json` | Default tool permissions |
| Project permissions | `repo/.claude/settings.local.json` | Repo-specific permissions |
| Rules (auto-loaded context) | `repo/.claude/rules/*.md` | Extended project docs |
| Memory | `~/.claude/projects/*/memory/MEMORY.md` | Persistent cross-session notes |
| Skills (user) | `~/.claude/skills/name/SKILL.md` | Auto-triggered workflow instructions |
| Skills (project) | `.claude/skills/name/SKILL.md` | Shared team workflow instructions |
| Agents (user) | `~/.claude/agents/name.md` | Custom subagents with scoped tools |
| Agents (project) | `.claude/agents/name.md` | Shared team subagents |
| MCP connections | `claude mcp add` or plugins | External service integrations |
