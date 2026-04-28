---
name: mcp-knowledge-graph
description: Use when starting work on a codebase you want to remember across sessions, extracting architectural facts, or querying persistent project knowledge instead of re-reading files. Centers the knowledge-graph MCP and project-local `.aim` storage.
---

# MCP Knowledge Graph

## When To Use

Use this skill when:
- Starting work on a codebase you want to remember across sessions
- Extracting and persisting architectural facts like components, dependencies, and decisions
- Building a project knowledge graph from broad codebase analysis
- Querying previously stored architectural context instead of re-reading files

Do not use it for temporary session notes, raw code dumps, or general chat memory.

## Core Workflow

1. Gather broad codebase context first, often with `repomix`
2. Extract durable facts, not raw code
3. Store entities with `aim_memory_store`
4. Store relations with `aim_memory_link`
5. Append facts with `aim_memory_add_facts`
6. Query later with `aim_memory_search` or `aim_memory_get`

## Storage Choice

| Use case | `location` | `context` | Result |
|----------|------------|-----------|--------|
| Team or project knowledge | `"project"` | omit | `.aim/memory.jsonl` in the repo |
| Personal notes for a project | `"global"` | omit | global memory file |
| Separate named personal graph | `"global"` | set | named global memory db |

Default to `location: "project"` with no `context` so the graph is easy to discover and commit.

## Main Operations

| Tool | Purpose |
|------|---------|
| `aim_memory_store` | Create entities |
| `aim_memory_link` | Create typed relations |
| `aim_memory_add_facts` | Append observations |
| `aim_memory_search` | Keyword search across the graph |
| `aim_memory_get` | Exact lookup by entity name |
| `aim_memory_read_all` | Dump a graph for review |
| `aim_memory_list_stores` | Discover available stores |
| `aim_memory_forget` | Delete entities |
| `aim_memory_remove_facts` | Delete observations |
| `aim_memory_unlink` | Delete relations |

## Entity Design

- Use stable entity names like `AuthService`, `UserRepository`, `BillingFlow`
- Use semantic types like `service`, `repository`, `module`, `decision`, `concept`
- Store facts as concise observations
- Use active relation verbs like `depends_on`, `calls`, `owns`, `implements`

## Search Limits

- `aim_memory_search` is substring-based, not semantic
- `aim_memory_get` is exact-name lookup
- Observation wording matters; use predictable terminology

## Example Pattern

1. Store components and decisions
2. Link them with explicit relations
3. Query by keyword before re-reading the repo

Prefer focused graphs over huge ones because writes rewrite the whole file.
