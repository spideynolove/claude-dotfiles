# mcp-knowledge-graph — Persistent Codebase Knowledge

## When to invoke

Use this skill when:
- Starting work on a codebase you want to remember across sessions
- Extracting and persisting architectural facts (components, dependencies, decisions)
- Building a project knowledge graph from a repomix-packed codebase
- Querying previously stored architectural context instead of re-reading files

**Do not use** for: general conversation memory (use episodic-memory), temporary session notes, or storing raw code (store facts *about* code, not the code itself).

---

## The combo workflow: repomix → analyze → knowledge-graph

```
1. repomix.pack_codebase()           ← get full codebase content
2. grep/read the output              ← extract architectural facts
3. aim_memory_store()                ← persist entities (components, modules, services)
4. aim_memory_link()                 ← persist relations (depends_on, calls, owns)
5. aim_memory_add_facts()            ← add observations to existing entities
```

In subsequent sessions: skip steps 1-2, query directly:

```
6. aim_memory_search("auth")         ← find relevant entities by keyword
7. aim_memory_get(["AuthService"])   ← exact lookup of known entity
```

This saves repacking the entire codebase every session — the graph acts as a persistent index.

---

## All 10 tools via mcporter

| Tool | Purpose |
|------|---------|
| `aim_memory_store` | Create new entities (components, people, concepts) |
| `aim_memory_link` | Create typed relations between entities |
| `aim_memory_add_facts` | Append observations to existing entities |
| `aim_memory_forget` | Delete entities (cascades to their relations) |
| `aim_memory_remove_facts` | Delete specific observations from an entity |
| `aim_memory_unlink` | Delete specific relations |
| `aim_memory_read_all` | Dump entire knowledge graph for a context |
| `aim_memory_search` | Substring search across names, types, observations |
| `aim_memory_get` | Exact lookup by entity name(s) |
| `aim_memory_list_stores` | List all databases (project-local + global) |

### Choosing where to store: project vs global

| Use case | `location` | `context` | Resulting file | Shareable? |
|----------|-----------|-----------|----------------|------------|
| Team/project knowledge | `"project"` | omit | `.aim/memory.jsonl` | ✓ commit it |
| Personal notes on a project | `"global"` | omit | `~/.aim/memory.jsonl` | ✗ stays local |
| Personal named database | `"global"` | `"work"` | `~/.aim/memory-work.jsonl` | ✗ stays local |

**Default: omit `context:`, use `location: "project"`** — produces `.aim/memory.jsonl` in the project root. Commit this file to share architectural knowledge with the team. The global context-loader hook also reads this file automatically on session start.

Only use `context:` when you need multiple separate graphs in the same project (rare). Named contexts create `memory-{name}.jsonl` files which are harder to discover and don't share well.

### Example: build a project knowledge graph

```
# Initialize once
mkdir .aim    ← creates project-local storage

# Store entities — no context: needed
mcporter call knowledge-graph.aim_memory_store(
  location: "project",
  entities: [
    {"name": "AuthService", "entityType": "service", "observations": ["Handles JWT auth", "Stateless"]},
    {"name": "UserRepository", "entityType": "repository", "observations": ["PostgreSQL", "Owns user table"]}
  ]
)

# Link them
mcporter call knowledge-graph.aim_memory_link(
  location: "project",
  relations: [
    {"from": "AuthService", "to": "UserRepository", "relationType": "depends_on"}
  ]
)

# Query later
mcporter call knowledge-graph.aim_memory_search(query: "auth")
mcporter call knowledge-graph.aim_memory_get(names: ["AuthService"])
```

### Personal notes (not committed)

```
mcporter call knowledge-graph.aim_memory_store(
  location: "global",
  entities: [{"name": "my-note", "entityType": "note", "observations": ["Personal observation"]}]
)
```

---

## Storage mechanics (important for correct usage)

- **Project-local file**: `.aim/memory.jsonl` — created when `location: "project"` and no `context:` given
- **Global file**: `~/.aim/memory.jsonl` — created when `location: "global"`
- **Auto-detection**: if `.aim/` exists in project root, project-local is used automatically when `location` is omitted
- **Full rewrite**: every write operation rewrites the entire file — keep graphs focused, not massive
- **No concurrency**: do not run two sessions writing to the same graph simultaneously
- **Safety marker**: every file starts with `{"type":"_aim","source":"mcp-knowledge-graph"}` — do not edit files manually unless you preserve this

---

## Entity and relation design

```
Entity: {name, entityType, observations[]}
- name: unique identifier (e.g. "AuthService", "UserController")
- entityType: semantic category (service, repository, module, concept, decision, person)
- observations: string[] of facts — append via aim_memory_add_facts

Relation: {from, to, relationType}
- relationType: active-voice verb (depends_on, calls, owns, extends, implements, manages)
- directional: from→to and to→from are different
```

**Naming conventions:**
- Entity names: `PascalCase` for code components, `snake_case` for concepts
- Relation types: `snake_case` verbs

---

## Search behavior (know the limits)

- `aim_memory_search` — **substring match**, case-insensitive, across name + type + observations
- `aim_memory_get` — **exact name match only**, case-sensitive
- **No semantic/vector search** — if you stored "AuthService handles JWT", searching "authentication" will NOT find it; "JWT" will
- Implication: use consistent, predictable observation wording when storing facts

---

## Initializing a project graph

```bash
mkdir .aim
```

Commit `.aim/memory.jsonl` to share the graph with the team — it's just a JSONL file, safe to version-control.

If you want personal notes excluded from commits, add `~/.aim/` to nothing (it's already outside the repo). Only add `.aim/*.jsonl` to `.gitignore` if the graph contains secrets or machine-specific paths that shouldn't be shared.

---

## Limitations

- Large graphs degrade performance (full in-memory load per operation)
- No append mode — each write rewrites the whole file
- No fuzzy or semantic search — keyword precision matters
- No versioning or rollback built-in
- Project detection searches up 5 directory levels for `.git`, `package.json`, `.aim`, etc.
