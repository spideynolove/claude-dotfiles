# Claude Code Toolstack

## Installed Packages

| Repo | Version | Install path |
|---|---|---|
| `github.com/rtk-ai/rtk` | latest | system PATH |
| `github.com/mksglu/context-mode` | latest | `/plugin` marketplace |
| `github.com/jahala/tilth` | v0.6.3 | `~/.local/bin/tilth` |
| `github.com/tirth8205/code-review-graph` | 2.3.2 | `~/env/.venv` (from fork) |
| `github.com/Mibayy/token-savior` | 2.6.0 | optional `~/env/.venv` |

---

## RTK (`github.com/rtk-ai/rtk`)

**What it does:** CLI proxy that compresses noisy build/test/log output before it reaches Claude's context. 60-90% token reduction on high-output operations.

**Scope:** Build, test, log, git diffs only. Discovery commands (`find`, `ls`, `grep`, `cat`, `which`, etc.) are excluded via `[hooks] exclude_commands` in `~/.config/rtk/config.toml` — they must run natively to preserve exact paths, line numbers, and full content.

**How installed:** Active globally via hook. Excluded commands pass through natively with no overhead.

**Privacy:** Zero telemetry, local-only. Confirmed safe.

**Key commands:**
```bash
rtk gain              # token savings analytics
rtk gain --history    # command history with savings
rtk proxy <cmd>       # run raw command without filtering
```

---

## context-mode (`github.com/mksglu/context-mode`)

**What it does:** Solves three sides of the context problem:
1. **Context saving** — sandbox tools keep raw data out of context (98% reduction)
2. **Session continuity** — SQLite+FTS5 tracks all events; BM25 retrieves relevant state after `/compact`
3. **Think in code** — LLM writes analysis scripts instead of reading raw data

**How installed:**
```
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode
/reload-plugins
```
Result: 13 hooks active (PreToolUse, PostToolUse, PreCompact, SessionStart)

**MCP entry:** `~/.claude.json` via plugin system (not manual)

**Slash commands:**
- `/context-mode:ctx-stats` — token savings breakdown this session
- `/context-mode:ctx-doctor` — diagnostics (run if behavior seems off)
- `/context-mode:ctx-insight` — browser dashboard, 15+ personal metrics
- `/context-mode:ctx-upgrade` — pull latest, rebuild, fix hooks
- `/context-mode:ctx-purge` — wipe all indexed content (destructive)

**Sandbox tools (Claude calls these):**
- `ctx_execute` — run code in 11 language runtimes
- `ctx_batch_execute` — multiple commands in one call
- `ctx_execute_file` — process files without exposing raw content
- `ctx_index` — markdown chunking with FTS5 indexing
- `ctx_search` — BM25-ranked retrieval
- `ctx_fetch_and_index` — URL fetch with 24h TTL cache

**Workflow change from old strategy:**
- Old: split tasks at 60% context, fear `/compact` losing state
- New: threshold is ~80%, `/compact` is safe (PreCompact hook indexes first)
- `claude --continue` resumes with full indexed state; `claude` alone = fresh slate
- Key behavioral shift: prompt Claude to write analysis scripts via `ctx_execute` instead of reading files directly

---

## tilth (`github.com/jahala/tilth`)

**What it does:** Smart code reading — replaces Grep/Read/Glob with AST-aware equivalents. Gives structural outlines for large files, finds definitions vs usages, shows callee chains. Benchmarked: 44% cost reduction on Sonnet, 84%→94% accuracy.

**How installed:**
```bash
# Binary
curl -L https://github.com/jahala/tilth/releases/download/v0.6.3/tilth-x86_64-unknown-linux-musl.tar.gz | tar -xz -C ~/.local/bin/
# MCP registration
tilth install claude-code   # writes to ~/.claude.json
```

**MCP tools (Claude calls these — routing enforced by CLAUDE.md):**
- `tilth_search` — AST-aware search, finds definitions + usages + callee chains
- `tilth_read` — smart file read (outline if large, full if small)
- `tilth_files` — glob/find replacement
- `tilth_deps` — blast-radius check before rename/delete
- `tilth_diff` — structural diff at function level

**CLAUDE.md routing:** `DO NOT use Grep, Read, or Glob. Always use tilth_search, tilth_read, tilth_files.`

**Edit mode (optional, not yet installed):**
```bash
tilth install claude-code --edit
```
Adds `tilth_edit` with hash-anchored lines — rejects edits if file changed since last read.

---

## code-review-graph (`github.com/tirth8205/code-review-graph`)

**What it does:** Builds a knowledge graph of the codebase (AST-parsed nodes + edges). Provides call graph traversal, impact radius, community detection, risk-scored code review.

**How installed:**
```bash
uv pip install ~/Public/SPIDEY/code-review-graph   # from personal fork
code-review-graph install claude-code
```

**Personal fork:** `~/Public/SPIDEY/code-review-graph`

**Patches applied to fork (3 commits):**

1. `435063e` — Redirect all install paths to global `~/.claude/`:
   - `.mcp.json` → `~/.mcp.json`
   - skills → `~/.claude/skills/`
   - hooks → `~/.claude/settings.json`
   - `CLAUDE.md` → `~/.claude/CLAUDE.md`

2. `10e32f9` — `_crg_bin()`: resolve binary path from active venv via `shutil.which()` so hooks work without venv activation

3. `b88ca7a` — Drop hardcoded `--repo` from hooks (find_project_root() resolves from runtime cwd); `.resolve()` on all CLI repo_root paths (fixes 0-nodes bug)

**What goes where:**

| Location | What | Why |
|---|---|---|
| `~/.mcp.json` | MCP server entry | Global, all sessions |
| `~/.claude/settings.json` | PostToolUse + SessionStart hooks | Global, all projects |
| `~/.claude/CLAUDE.md` | Routing instructions | Global, all sessions |
| `~/.claude/skills/` | Skill files | Global |
| `project/.code-review-graph/graph.db` | The graph | Per-project, codebase-specific |

**Per-project setup (one-time per codebase):**
```bash
cd your-project
git add -u    # sync git index with disk first (important!)
source ~/env/.venv/bin/activate
code-review-graph build
```

**MCP tools (Claude calls these):**
- `detect_changes` — risk-scored analysis of changes
- `get_review_context` — token-efficient source snippets
- `get_impact_radius` — blast radius of a change
- `get_affected_flows` — which execution paths are impacted
- `query_graph` — callers_of / callees_of / imports_of / tests_for
- `semantic_search_nodes` — find functions/classes by name or keyword
- `get_architecture_overview` — high-level structure
- `refactor_tool` — rename planning, dead code detection

**Hooks in `~/.claude/settings.json`:**
```json
PostToolUse (Edit|Write|Bash): git check && code-review-graph update --skip-flows || true
SessionStart: git check && code-review-graph status || skip
```

**Known issue:** `git ls-files` only returns tracked files — untracked new files won't be indexed until `git add`ed (no commit needed, staging is enough).

---

## token-savior (`github.com/Mibayy/token-savior`)

**What it does:** Optional persistent memory engine across sessions plus structural code navigation. Stores decisions, conventions, bugfixes, and guardrails in SQLite WAL+FTS5.

**Default policy:** Do not register token-savior as an always-on MCP server in Claude Code or Codex. Use native Codex memories, context-mode, and code-review-graph first. Install token-savior only for explicit recall workflows.

**Optional install:**
```bash
source ~/env/.venv/bin/activate
uv pip install "token-savior-recall[mcp]"
```

**Why not `memory-vector`:** Pulls in PyTorch + full NVIDIA CUDA stack (~2GB). FTS5 BM25 search (included in base) is sufficient; vector embeddings are an optional upgrade.

**Profiles (set via `TOKEN_SAVIOR_PROFILE`):**

| Profile | Tools advertised | ~Tokens | Use case |
|---|---|---|---|
| `full` (default) | 106 | ~10,950 | All capabilities |
| `core` | 54 | ~5,800 | Daily coding, no memory engine |
| `nav` | 28 | ~3,100 | Read-only exploration |
| `lean` | 59 | ~6,620 | Memory engine off |
| `ultra` | 17 | ~2,740 | Hot tools only |

**Memory 3-layer progressive disclosure (always start at Layer 1):**

| Layer | Tool | Tokens/result | When |
|---|---|---|---|
| 1 | `memory_index` | ~15 | Always first |
| 2 | `memory_search` | ~60 | If Layer 1 matched |
| 3 | `memory_get` | ~200 | If Layer 2 confirmed |

If an explicit workflow needs token-savior MCP, register it temporarily with a narrow workspace scope and remove it afterward.

---

## How They Work Together

### Automatic (zero user action)

| Event | What fires |
|---|---|
| Session start | context-mode injects routing rules; code-review-graph reports graph status |
| Edit/Write/Bash | RTK compresses build/test/log output (discovery commands excluded); context-mode sandboxes large outputs; code-review-graph incrementally updates graph |
| Before `/compact` | context-mode indexes session events to FTS5 |

### Explicit (Claude calls on demand, guided by CLAUDE.md routing)

| Need | Tool | Why not the alternative |
|---|---|---|
| Find a symbol/function | `tilth_search` | Grep is text-only; tilth is AST-aware |
| Read a file | `tilth_read` | Read dumps whole file; tilth outlines first |
| Understand impact of a change | `get_impact_radius` | Can't be done with grep |
| Code review | `detect_changes` + `get_review_context` | Token-efficient vs reading whole files |
| Recall past decision | Native Codex memories or explicit token-savior workflow | Avoid default MCP bloat |
| Large command output | `ctx_execute` / `ctx_batch_execute` | Keeps raw data out of context |

### Layered session model

```
Session starts
  → context-mode: inject routing rules (use sandbox tools, not Bash)
  → code-review-graph: report graph status for this project

During work
  → tilth: all code reading and search
  → code-review-graph: structural analysis, impact, call graph
  → context-mode: sandbox large outputs

On every Edit/Write/Bash
  → code-review-graph: incremental graph update

Before /compact
  → context-mode: index session events (state survives compaction)

Next session
  → context-mode restores relevant session state after compaction
```

### What each tool owns

| Concern | Owner |
|---|---|
| Token reduction (build/test/log output) | RTK (discovery commands excluded) |
| Token reduction (tool output / context) | context-mode |
| Token reduction (code reading) | tilth |
| Code structure / call graph | code-review-graph |
| Memory across sessions | Native Codex memories or explicit token-savior workflow |
| Context window survival across `/compact` | context-mode events |

---

## Maintenance

```bash
# Reinstall code-review-graph after fork changes
source ~/env/.venv/bin/activate
uv pip install ~/Public/SPIDEY/code-review-graph

# Update context-mode
/context-mode:ctx-upgrade

# Update tilth binary
curl -L https://github.com/jahala/tilth/releases/latest/download/tilth-x86_64-unknown-linux-musl.tar.gz | tar -xz -C ~/.local/bin/
```
