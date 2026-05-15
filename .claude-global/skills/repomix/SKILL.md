---
name: repomix
description: Pack local or remote repos into a single context blob for whole-repository understanding. Use before tasks spanning multiple directories, architecture reviews, or onboarding to an unfamiliar codebase.
---

# Repomix — Broad Codebase Context

## When to invoke this skill

Invoke repomix **before** any task that requires whole-repository understanding:
- Writing specs or architecture docs that reference multiple directories
- 04-uiux planning stage (before IntentSpec, LayoutSpec, TokenSpec)
- Reviewing consistency across many files
- Answering "how does X work across the codebase" questions
- Onboarding to an unfamiliar codebase

**Do not use** for single-file edits, simple bug fixes, or tasks where you already have the relevant files open.

---

## CLI usage (primary method)

```bash
# Pack current directory to XML (AI-optimized, default)
repomix

# Pack to markdown (human-readable)
repomix --style markdown -o repomix-output/summary.md

# Pack with compression (Tree-sitter, ~70% fewer tokens)
repomix --compress

# Pack remote repo
repomix --remote user/repo
repomix --remote user/repo --remote-branch main -o output.xml

# Use a config file
repomix --config repomix.config.json
```

---

## MCP tools (optional — only when repomix is a persistent MCP server)

`mcporter call repomix.*` fails with "Unknown MCP server" unless repomix is registered in Claude Code's MCP settings as a persistent server (`autoStart: true`). By default it is not — use CLI above instead.

If repomix IS configured as a persistent MCP server (via `settings.json`), these tools are available:

| Tool | Use case |
|------|----------|
| `pack_codebase` | Pack a local directory — returns `outputFilePath`, use that not `outputId` |
| `pack_remote_repository` | Pack a GitHub repo by URL or `user/repo` shorthand |
| `grep_repomix_output` | Search packed output (persistent server only) |

---

## Config file format

Create `repomix.config.json` in the project root:

```json
{
  "output": {
    "filePath": "repomix-output/repo.xml",
    "style": "xml",
    "compress": false,
    "removeComments": false,
    "showLineNumbers": false,
    "fileSummary": true,
    "directoryStructure": true
  },
  "ignore": {
    "useGitignore": true,
    "useDotIgnore": true,
    "customPatterns": ["repomix-output/**", "*.lock", "dist/**", "node_modules/**"]
  },
  "tokenCount": {
    "encoding": "o200k_base"
  }
}
```

**Output style guidance:**
- `xml` — structured format, best for AI parsing (default)
- `markdown` — human-readable summaries, good for docs
- `json` — machine-parseable, good for programmatic use
- `plain` — simple text, minimal overhead

**Compression (`compress: true`):** Uses Tree-sitter to extract function signatures and structure, discarding implementation bodies. Reduces tokens ~70%. Use for large repos or when full code isn't needed.

---

## 04-uiux workflow integration

In the 04-uiux workflow, run repomix at the **start of whole-repo tasks** (before IntentSpec when working across multiple components or doing a full redesign).

```bash
cd /path/to/claude-code-in-action/04-uiux
repomix  # uses .repomixrc / repomix.config.json automatically
```

Output files land in `repomix-output/`. Reference them in subsequent spec stages:
- `repomix-output/repo.xml` — full context for AI consumption
- `repomix-output/summary.md` — human-readable summary

When using MCP tools during 04-uiux tasks, prefer `pack_codebase` with `compress: true` for initial survey, then `grep_repomix_output` for targeted lookups.

---

## Token limits

repomix uses `o200k_base` encoding by default (matches GPT-4o / Claude tokenization closely). Check token count in the output header. If output exceeds ~100k tokens, enable compression or narrow with `includePatterns`.
