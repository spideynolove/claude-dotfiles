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

## MCP tools (preferred — no file I/O required)

All tools are available via `repomix.*` through mcporter.

| Tool | Use case |
|------|----------|
| `pack_codebase` | Pack a local directory into a single context blob |
| `pack_remote_repository` | Pack a GitHub repo by URL or `user/repo` shorthand |
| `read_repomix_output` | Read a specific line range from a previously packed output |
| `grep_repomix_output` | Search packed output without re-reading everything |
| `file_system_read_file` | Read a single file via repomix's filesystem access |
| `file_system_read_directory` | List directory contents via repomix |

### Typical MCP invocation pattern

```
# Pack this repo (compress=true saves ~70% tokens, preserves signatures)
mcporter call repomix.pack_codebase(directory: "/home/hung/Public/SPIDEY/claude-code-in-action", compress: true)
# → result contains both outputId and outputFilePath
```

**CRITICAL — mcporter outputId is dead on arrival:** Each `npx mcporter call` spawns a fresh subprocess. The `outputId` only lives in the server process that created it. A second `mcporter call` to `read_repomix_output` uses a different process — the ID is always gone.

**Always use `outputFilePath` from the pack result instead:**

```
# After pack, use the file path directly — never outputId via mcporter
Read(outputFilePath)   ← use Claude Code's Read tool on the returned path

# If you need to grep the output:
Grep(pattern: "IntentSpec", path: "<outputFilePath>")
```

`read_repomix_output` and `grep_repomix_output` only work when repomix runs as a persistent MCP server (autoStart in settings.json). Via mcporter, they always fail.

### Remote repo invocation

```
mcporter call repomix.pack_remote_repository(remote: "yamadashy/repomix", compress: true)
mcporter call repomix.pack_remote_repository(remote: "https://github.com/user/repo", compress: false)
```

---

## CLI usage (when you need to write output files)

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
cd /home/hung/Public/SPIDEY/claude-code-in-action/04-uiux
repomix  # uses .repomixrc / repomix.config.json automatically
```

Output files land in `repomix-output/`. Reference them in subsequent spec stages:
- `repomix-output/repo.xml` — full context for AI consumption
- `repomix-output/summary.md` — human-readable summary

When using MCP tools during 04-uiux tasks, prefer `pack_codebase` with `compress: true` for initial survey, then `grep_repomix_output` for targeted lookups.

---

## Token limits

repomix uses `o200k_base` encoding by default (matches GPT-4o / Claude tokenization closely). Check token count in the output header. If output exceeds ~100k tokens, enable compression or narrow with `includePatterns`.
