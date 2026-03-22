# CodeGraphContext — Structural Code Intelligence

CodeGraphContext (CGC) parses source code with tree-sitter and builds a queryable graph of functions, classes, and their relationships. Use it to answer structural questions that text search can't: "who calls this?", "what would break?", "where is dead code?"

Supports 14 languages: Python, JS/TS, Java, C/C++, C#, Go, Rust, Ruby, PHP, Swift, Kotlin, Dart, Perl.

## When to invoke

Use CGC **instead of grep** when questions are structural:
- Tracing callers / callees across a large codebase
- Impact analysis before refactoring a function or class
- Finding dead code before a cleanup
- Identifying the most complex functions to prioritize
- Answering "what calls X?" or "what does Y depend on?"

**Do not use** for text/regex search, reading file contents, or single-file edits.

---

## Installation

```bash
pip install codegraphcontext
# or with uv:
uv pip install codegraphcontext
```

Verify: `cgc --help`

Default backend: KùzuDB (zero-config, embedded). No server needed.

---

## Core workflow

### 1 — Index the repo

```bash
# Index current directory
cgc index .

# Index a specific path
cgc index /path/to/project
```

Run once; re-run after large changes or use `cgc watch` for live updates.

### 2 — Analyze

```bash
# Who calls a function?
cgc analyze callers <function_name>

# What does a function call?
cgc analyze calls <function_name>

# Visualize call chain interactively
cgc analyze calls <function_name> --viz

# Find complex functions (default threshold: 10)
cgc analyze complexity --threshold 15

# Detect dead code
cgc analyze dead-code

# Explore class hierarchy
cgc analyze tree <ClassName> --viz
```

### 3 — Find patterns

```bash
cgc find pattern "<search_term>"
```

### 4 — List indexed repos

```bash
cgc list
```

### 5 — Live watch (keep graph current)

```bash
cgc watch /path/to/project
```

---

## MCP server mode (optional)

CGC can expose its graph as an MCP server so Claude can query it conversationally:

```bash
cgc mcp setup    # interactive wizard
cgc mcp start    # launch the server
```

When the MCP server is running, Claude can use `cgc.*` tools directly without shell commands. Prefer the CLI above unless you need persistent conversational access.

---

## Typical task patterns

**Impact analysis before refactoring:**
```bash
cgc index .
cgc analyze callers target_function
```

**Find what to clean up:**
```bash
cgc analyze dead-code
cgc analyze complexity --threshold 20
```

**Understand an unfamiliar module:**
```bash
cgc analyze calls entry_point_function --viz
cgc analyze tree CoreClassName --viz
```

---

## Integration with other skills

- **repomix** — use repomix for broad file-content context; use CGC for structural/relational queries
- **mcp-knowledge-graph** — CGC focuses on code structure; knowledge-graph stores architectural decisions and patterns

---

## Notes

- First `cgc index` may take 30–60 seconds on large repos
- Graph is stored locally in `.cgc/` by default
- Add `.cgc/` to `.gitignore`
