---
name: code-review-graph
description: Use code-review-graph through CLI or mcporter for codebase maps, impact analysis, semantic search, graph status, and review context without keeping the MCP server natively registered in Codex.
compatibility: claude-code
---

> Note: Converted from Claude Skill.

# Code Review Graph

Use this skill when a task benefits from structural codebase context, impact analysis, graph-backed search, or keeping the local graph fresh.

Prefer the CLI for routine work:

```bash
code-review-graph status
code-review-graph build
code-review-graph update --skip-flows
code-review-graph detect-changes --brief
```

Use mcporter when an MCP tool is specifically useful without exposing the server as a native Codex MCP:

```bash
npx mcporter list code-review-graph --schema
npx mcporter call code-review-graph.TOOL_NAME key=value
```

The global Codex hooks already run `code-review-graph build` or `status` on session start and `code-review-graph update --skip-flows` after Bash or apply_patch edits.
