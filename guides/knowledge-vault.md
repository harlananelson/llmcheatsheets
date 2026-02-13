# Knowledge Vault: Ontology-Driven Notes with Claude Code

A methodology for building a linked knowledge base using Claude Code as the
agent that creates, connects, and maintains notes. The vault is a folder of
markdown files with explicit rules that teach Claude how to navigate and
operate it — the same pattern used for codebases, applied to knowledge.

---

## Who This Is For

You want a "second brain" or knowledge management system, but:
- You already use Claude Code and don't want a separate tool
- You want the AI to actively find connections, not just store text
- You care about note quality over note quantity
- You want explicit rules governing how the AI operates on your notes

This guide shows how to scaffold a knowledge vault using Claude Code's
configuration layers (CLAUDE.md, `.claude/rules/`) as the control system.

---

## 1. The Core Insight

A codebase is a folder of text files connected by imports and references.
A knowledge vault is a folder of text files connected by links and topic pages.
The structural similarity means the same tools and navigation patterns work
for both.

Claude Code already knows how to:
- Read an index (CLAUDE.md) and orient via directory structure
- Follow references between files
- Create new files that link to existing ones
- Maintain consistency across a project

A knowledge vault is the same operation with different content. The addition
is explicit rules about navigation, note quality, and connection discovery.

---

## 2. Vault Structure

```
vault/
├── 00_inbox/                  # Capture zone — zero friction
├── 01_thinking/               # Active development
│   ├── topic-page.md          # Maps of Content (MOCs)
│   └── notes/                 # Individual developing notes
├── 02_reference/              # External knowledge
│   ├── tools/                 # Tool documentation
│   ├── approaches/            # Methods and patterns
│   └── sources/               # Summaries of external works
├── 03_creating/               # Drafts in progress
│   └── drafts/
├── 04_published/              # Finished work archive
├── 05_archive/                # Inactive content
├── 06_system/                 # Templates and scripts
│   └── templates/
│       └── note-template.md
├── CLAUDE.md                  # Slim routing file
├── .claude/
│   └── rules/                 # Auto-loaded rule files
│       ├── ontology-schema.md
│       ├── knowledge-constraints.md
│       ├── authority-scoring.md
│       ├── vault-operations.md
│       └── note-conventions.md
├── index.md                   # Master inventory
└── .gitignore
```

### Folder Semantics

Folders encode status. Moving a note between folders changes its lifecycle stage:

| Folder | Status | Entry Point |
|--------|--------|-------------|
| `00_inbox/` | Raw capture, unprocessed | "Capture this" |
| `01_thinking/` | Active development, topic pages | "Develop this" / "Connect this" |
| `02_reference/` | External knowledge summaries | "Reference this source" |
| `03_creating/` | Drafting toward output | "Write this up" |
| `04_published/` | Finished, stable | User confirms |
| `05_archive/` | Inactive | User confirms |
| `06_system/` | Templates, scripts | Infrastructure |

---

## 3. Three Operating Modes

The CLAUDE.md defines three modes that Claude selects based on user intent:

### Capture Mode
Quick deposits into `00_inbox/`. Zero friction. No orientation, no connection
search, no index update. Triggered by "capture," "jot down," "quick note."

### Synthesis Mode
Linking, connecting, developing. Triggered by "connect," "develop," "link,"
"find connections." Claude must:
1. Orient: read `index.md` + relevant topic pages
2. Search for related content
3. Add links woven into prose
4. Update topic pages and index

### Creation Mode
Building output documents from vault notes. Triggered by "draft," "write up."
Claude reads source notes, creates in `03_creating/drafts/`, tracks provenance.

---

## 4. The Rules System

Five rules files in `.claude/rules/` teach Claude how to operate the vault.
These are auto-loaded every session.

### `ontology-schema.md` — What exists

Defines the node types (Note, Claim, Source, TopicPage, Question, Insight,
Method) and edge types (supports, refutes, extends, contextualizes, etc.).
Adapted from the [architecture review methodology](claude-code-architecture-review.md).

Key invariant: every Note links to at least one TopicPage.

### `knowledge-constraints.md` — Quality rules

- **Composability:** Notes must stand alone (no prerequisite reading)
- **Naming:** Notes named as claims ("batch correction requires benchmarking") not topics ("batch correction")
- **Linking:** Links woven into prose with articulated relationships, not footnote lists
- **Depth over breadth:** Fewer developed notes beat many stubs

### `authority-scoring.md` — Source quality

Deterministic formula for scoring external sources. Same pattern as the
architecture review guide: LLM proposes inputs (source type, domain, recency,
venue), formula computes the score. LLM may not assign scores directly.

### `vault-operations.md` — How Claude navigates

- **Orientation protocol:** Read index → identify topic pages → read them → then act
- **Connection search:** Every new note triggers grep for related content
- **Breadcrumbs:** After working in a topic area, log activity in the topic page
- **Index maintenance:** Update `index.md` after every create/move/archive

### `note-conventions.md` — Format rules

- YAML frontmatter with title, date, status, topics
- Status lifecycle: inbox → developing → mature → published → archived
- Bidirectional linking: if A links to B, B acknowledges A
- Topic pages are maps (they link and describe), not containers

---

## 5. Topic Pages (Maps of Content)

Topic pages live in `01_thinking/` and serve as navigation hubs. They describe
a topic area's landscape, link to relevant notes, track open questions, and
record breadcrumbs of recent activity.

```markdown
# Research Methods

Clinical research methodology, statistical approaches, and reproducibility.

## Core Notes
- [Claim-form title](notes/filename.md) — one-line relationship description

## Open Questions
- Unanswered question driving inquiry in this area

## Recent Activity
- **2026-02-13:** Created [note title](path). Connected to [other note](path).
```

Topic pages are named as topics (not claims) because they're maps, not assertions.

---

## 6. The LLM Boundary

The CLAUDE.md defines explicit boundaries:

**Claude MAY:** Create/link/move notes, propose connections, update index
and topic pages, suggest status transitions (inbox → thinking).

**Claude MUST NOT:** Delete notes without confirmation, assign authority
scores directly, skip orientation before modifying a topic area, move notes
to published/archive without confirmation.

**Claude MUST:** Orient before acting, record breadcrumbs, search for
connections after creating notes, update index after changes.

---

## 7. Bootstrapping

To scaffold a vault:

1. Use the [Knowledge Vault Skill](../skills/knowledge-vault-skill.md) — it
   generates the full directory structure, CLAUDE.md, rules files, templates,
   index, and starter topic pages
2. Or follow the structure in Section 2 and adapt the rules to your domain

The skill produces a working vault that Claude can operate immediately. Start
by capturing a few notes, then use synthesis mode to develop connections.

---

## 8. Relationship to Other Patterns

| Pattern | Where | How It Relates |
|---------|-------|---------------|
| [Architecture Review](claude-code-architecture-review.md) | Generic methodology | The vault is one application of the ontology scaffolding pattern |
| [Quarto Ontology Website](quarto-ontology-website.md) | Website builder | Another application — typed pages with metadata relationships |
| [Claude Code Setup](claude-code-setup.md) | Configuration guide | How to set up the CLAUDE.md and rules layer that the vault uses |

The vault pattern demonstrates the architecture review methodology in a
domain (knowledge management) that anyone can adopt without domain-specific
data.

---

## 9. When to Use This vs. Other Tools

**Use the vault when:**
- You already work in Claude Code and want integrated knowledge management
- You want the AI to actively maintain and connect your notes
- You value explicit rules over implicit conventions
- Your knowledge base is primarily text (not images, databases, or structured data)

**Consider alternatives when:**
- You need collaborative editing (Notion, Confluence)
- You need graph visualization (Obsidian, Logseq)
- You need structured data management (databases, spreadsheets)
- You want zero configuration (plain notes in a folder)

The vault is opinionated by design. The rules system is the value — it
prevents note sprawl, enforces quality, and teaches the AI how to be a
useful knowledge partner rather than just a file creator.

---

## 10. Future Directions: Formal Graph Methods

The convention-based vault (Sections 1-9) is Phase 1: links are markdown
references, structure is implicit in prose, and the LLM agent traverses the
graph by reading files. This works well for hundreds of notes and is
immediately operational with no infrastructure.

But the vault's link structure is a **directed graph** — and graphs have a
rich mathematical theory. As a vault grows, formalizing the graph opens up
operations that convention-based linking cannot support.

### The adjacency matrix

Every vault is implicitly a directed acyclic graph (DAG) where nodes are
notes and edges are links. This graph has an **adjacency matrix** `A` where
`A[i,j] = 1` if note `i` links to note `j`:

```
         note_1  note_2  note_3  note_4
note_1  [  0       1       0       1  ]
note_2  [  0       0       1       0  ]
note_3  [  0       0       0       1  ]
note_4  [  0       0       0       0  ]
```

Weighted variants encode edge type or connection strength instead of binary
0/1. The ontology's edge types (`supports`, `refutes`, `extends`, etc.)
become different weight channels or separate adjacency matrices per relation.

### What matrix operations give you

Once the graph is a matrix, linear algebra answers structural questions that
are expensive or impossible to answer by reading files:

| Operation | What it tells you | How |
|-----------|-------------------|-----|
| **Reachability** | Can note A reach note B through any chain of links? | `(I + A)^n` — the transitive closure. Non-zero entry means reachable. |
| **Path length** | How many hops between two concepts? | `A^k` — entry `(i,j)` counts paths of exactly length `k` between `i` and `j`. |
| **Centrality** | Which notes are structurally most important? | Eigenvector centrality (dominant eigenvector of `A`). A note is important if important notes link to it — the same idea as PageRank. |
| **Clustering** | What topic communities emerge from link structure (not your subjective grouping)? | Spectral clustering on the graph Laplacian `L = D - A`. The eigenvectors of `L` with smallest non-zero eigenvalues reveal natural clusters. |
| **Latent structure** | What hidden dimensions organize the vault? | SVD of the adjacency or incidence matrix. Low-rank approximation reveals latent topics that may not correspond to your explicit topic pages. |
| **Similarity** | Which notes are structurally similar (linked to similar neighborhoods)? | Cosine similarity of rows in `A` or in a graph embedding space. |

### From convention to computation

The progression looks like:

```
Phase 1: Convention-based (this guide)
  - Links are markdown references in prose
  - LLM traverses by reading files
  - Structure is implicit, maintained by rules
  - Tools: Claude Code, grep, file system

Phase 2: Extracted graph
  - Parse vault links into an adjacency matrix
  - Compute centrality, clusters, reachability
  - Use results to guide the LLM ("these notes are structurally central,
    these clusters exist, these notes are isolated")
  - Tools: NetworkX, igraph, numpy

Phase 3: Graph embeddings
  - Embed nodes into a vector space (node2vec, TransE, or GNN-based)
  - Cosine similarity finds related concepts the link structure implies
    but that aren't explicitly linked yet
  - Combine with text embeddings (from the note content) for hybrid
    structure + semantic similarity
  - Tools: PyTorch Geometric, DGL, sentence-transformers

Phase 4: Algebraic knowledge representation
  - Represent the full typed ontology (node types, edge types, constraints)
    as a tensor algebra — adjacency tensors per relation type
  - Compositional reasoning: "find notes that `support` a claim that
    `extends` a note in cluster C" becomes a tensor contraction
  - Constraint satisfaction as linear programs over the graph
  - Tools: Custom, building on sparse tensor libraries
```

### Practical entry point

Phase 2 is accessible today with a small script:

1. Parse `index.md` and all vault `.md` files to extract links
2. Build an adjacency matrix (scipy sparse or numpy)
3. Compute eigenvector centrality, spectral clusters, and reachability
4. Output a report: "Your vault has N notes, M links. The 5 most central
   notes are ... The natural clusters are ... These 3 notes are isolated."
5. Feed that report to Claude as context for synthesis operations

This gives the LLM structural awareness it cannot get from reading files
sequentially. It knows which notes are hubs, which are orphans, and which
clusters exist — without reading every note first.

### The deeper idea

A knowledge vault's link structure IS a mathematical object. The convention-
based approach (Phase 1) works because the graph is small enough for a
sequential reader to hold in context. But graphs have properties that
sequential reading cannot efficiently discover:

- **Transitivity:** If A supports B and B supports C, does A transitively
  support C? Matrix powers answer this instantly.
- **Community structure:** Which concepts cluster together by link pattern,
  independent of your folder organization? The Laplacian's spectrum reveals
  this.
- **Importance:** Which notes would, if removed, most fragment the graph?
  Betweenness centrality answers this.
- **Latent dimensions:** What hidden axes organize your thinking that you
  haven't made explicit? SVD of the adjacency matrix reveals these.

The vault's convention-based rules (orientation protocol, connection search,
breadcrumbs) are heuristic approximations of these graph operations. The
formal methods don't replace the conventions — they augment them with
structural awareness that scales beyond what sequential reading can provide.

### Tooling landscape

The choice of language depends on the role: exploratory analysis (developing
the math), integrated agent (Claude Code calls it), or production tool
(ships as a binary).

#### Python — the default for integration

Python is the natural choice for Phases 2-3 because Claude Code can run
scripts directly and parse the output. The ecosystem covers the full stack:

| Phase | Packages | What they do |
|-------|----------|-------------|
| 2: Extracted graph | `networkx`, `igraph` | Graph construction, centrality, community detection |
| 2: Linear algebra | `scipy.sparse`, `numpy` | Adjacency matrices, eigendecomposition, matrix powers |
| 2: Clustering | `scikit-learn` | Spectral clustering, k-means on embeddings |
| 2: Visualization | `matplotlib`, `pyvis` | Static and interactive graph plots |
| 3: Graph embeddings | `PyTorch Geometric`, `DGL` | GNN-based node embeddings |
| 3: Node embeddings | `node2vec`, `gensim` | Random-walk-based node embeddings |
| 3: Hybrid | `sentence-transformers` | Text embeddings to combine with structure embeddings |

A Phase 2 pipeline is ~100 lines: parse markdown links, build a NetworkX
graph, compute `nx.eigenvector_centrality()`, `nx.community.louvain_communities()`,
and `nx.has_path()`, then output a report.

#### R — tidy graph analysis alongside research code

R is strong for Phase 2, especially if the vault analysis lives alongside
tidymodels research workflows. The tidyverse-native graph ecosystem is
well-designed:

| Package | What it does |
|---------|-------------|
| `tidygraph` | Tidy verbs for graph manipulation — `mutate()`, `filter()`, `arrange()` on nodes and edges. Wraps igraph with a tibble interface. |
| `ggraph` | Grammar-of-graphics for networks. Publication-quality graph visualizations with the same API as ggplot2. |
| `igraph` | The workhorse — centrality, community detection, shortest paths, spectral methods. Underneath tidygraph. |
| `Matrix` | Sparse matrix classes and linear algebra. Efficient adjacency matrices for large vaults. |

R is weaker for Phase 3 (graph neural networks, deep embeddings) — the
ecosystem for this lives in Python. But for Phase 2 analysis with
beautiful visualizations, tidygraph + ggraph is arguably better than
the Python equivalent.

#### Julia — performance for large vaults

Julia's value appears at scale (thousands of notes, large embedding
spaces) and in Phase 3-4 where sparse tensor operations dominate:

| Package | What it does |
|---------|-------------|
| `Graphs.jl` | Graph algorithms, equivalent to NetworkX/igraph |
| `SparseArrays` (stdlib) | Sparse matrix operations, near-C performance |
| `Arpack.jl` | Large-scale eigenvalue problems (for spectral methods on big graphs) |
| `GraphNeuralNetworks.jl` | GNN layers, graph convolutions |

Julia's type system also maps naturally to ontology node types — you can
define `Note`, `Claim`, `Source` as Julia types and dispatch graph
operations on them. This matters in Phase 4 where the typed ontology
becomes a typed algebra.

The tradeoff is ecosystem size (fewer packages, smaller community) and
startup latency (first-run compilation). Worth it when Python's speed
becomes the bottleneck.

#### Rust — production CLI tool

Rust is the wrong tool for exploration but the right tool for a finished
product. Once the math is settled, a `vault-graph` CLI built with
`petgraph` could:

- Parse all vault markdown files and extract links
- Build the adjacency matrix in memory
- Compute centrality, clusters, reachability
- Output a JSON report that Claude Code reads as context

This ships as a single binary, runs in milliseconds, and needs no runtime.
It's the Phase 2 pipeline hardened for daily use — a tool Claude Code calls
before every synthesis operation.

#### Mathematica / Wolfram Language — develop the math

Mathematica is exceptional for the *exploratory* phase where you're
figuring out which graph operations are informative:

- `Graph[]`, `AdjacencyMatrix[]`, `CommunityStructure[]`,
  `EigenvectorCentrality[]` are first-class language primitives
- Symbolic computation lets you express the ontology algebra formally —
  define composition rules for edge types, derive properties symbolically
  before evaluating numerically
- The notebook environment supports rapid iteration with inline
  visualization

But Mathematica is a poor *agent*. It's proprietary, expensive, and hard
to integrate as a CLI tool. The workflow is: develop and prove operations
in Mathematica, then implement the production version in Python/Julia/Rust.

The free Wolfram Engine (developer license) can be scripted from the
command line via `wolframscript`, which partially addresses the integration
gap — but the license terms and startup overhead make it impractical as
a sub-agent that Claude Code calls on every vault operation.

### Integration: MCP server as the bridge

The cleanest integration path is an **MCP server** that exposes graph
operations as tools Claude Code can call natively:

```
Claude Code                    MCP Server (Python/Rust)
    │                               │
    ├── analyze_vault_graph() ──────►  Parse .md files
    │                               │  Build adjacency matrix
    │                               │  Compute centrality, clusters
    │◄── {centrality: [...],  ──────┤  Return structured report
    │     clusters: [...],          │
    │     isolated: [...]}          │
    │                               │
    ├── find_similar(note_id) ──────►  Cosine similarity in
    │                               │  embedding space
    │◄── [related_notes...] ────────┤
```

With an MCP server, `analyze_vault_graph` becomes a tool as natural as
`search_preprints` or `compound_search`. Claude's orientation protocol
could call it automatically: read `index.md`, call the graph analysis
tool, then operate with structural awareness.

The server can be built in:
- **Python** (simplest, use `networkx` + the MCP SDK)
- **TypeScript** (if you want the MCP SDK's native language)
- **Rust** (fastest, use `petgraph`, expose via MCP protocol)

This separates concerns cleanly: the graph engine handles the math, the
LLM handles the reasoning, and the MCP protocol handles the interface.

### Recommended progression

| When | What | Language | Why |
|------|------|----------|-----|
| Now | Phase 1 convention-based vault | Markdown + Claude Code | No infrastructure needed |
| 50+ notes | Phase 2 graph analysis script | Python or R | Quick to build, informative results |
| 200+ notes | Phase 2 as MCP server | Python or Rust | Integrates into Claude Code natively |
| Scaling | Phase 3 graph + text embeddings | Python (PyTorch Geometric + sentence-transformers) | Finds connections the link structure implies but hasn't made explicit |
| Research | Phase 4 algebraic formalization | Julia or Mathematica → Julia | Performance on tensor operations, type system for ontology |

Start with convention-based linking (this guide). Add graph analysis when
the vault is large enough that sequential reading misses structural
patterns. The formal methods don't replace the conventions — they augment
them.

### References

- Newman, M. E. J. (2010). *Networks: An Introduction*. Oxford University Press.
  — The standard reference for graph theory applied to real networks.
- Grover & Leskovec (2016). "node2vec: Scalable Feature Learning for Networks."
  — Graph embedding method that maps nodes to vectors preserving neighborhood structure.
- Bordes et al. (2013). "Translating Embeddings for Modeling Multi-relational Data."
  — TransE: knowledge graph embeddings where relations are translations in vector space.
- Chung, F. R. K. (1997). *Spectral Graph Theory*. AMS.
  — Mathematical foundations for using eigenvalues of graph matrices.
- Hamilton, W. L. (2020). *Graph Representation Learning*. Morgan & Claypool.
  — Modern survey of graph neural networks and embedding methods.
- Csardi & Nepusz (2006). "The igraph software package for complex network research."
  — The igraph library, used by both R and Python for graph algorithms.
- Pedersen, T. L. (2024). *tidygraph* and *ggraph* R packages.
  — Tidy interface for graph manipulation and grammar-of-graphics visualization.
