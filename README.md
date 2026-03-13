# claude-dotfiles

Portable `~/.claude/` configuration — agents, skills, hooks, and global instructions for Claude Code.

## Structure

```
.claude/
├── CLAUDE.md                          ← global instructions applied to all projects
├── settings.json                      ← base settings (copy and edit paths per machine)
├── hooks/
│   └── context-loader.sh              ← auto-injects .aim/ knowledge graph on session start
├── agents/
│   ├── orchestrator.md                ← full coding pipeline: clarify→analyze→plan→implement→review→test
│   ├── codebase-analyst.md            ← repomix + sequential-thinking + knowledge-graph
│   └── mcp-manager.md                 ← MCP executor with CLI fallback chain
└── skills/
    ├── repomix/SKILL.md               ← broad codebase context via repomix
    ├── mcp-knowledge-graph/SKILL.md   ← persistent entity/relation graph
    ├── sequential-thinking/SKILL.md   ← structured cognitive analysis
    └── nuxt/SKILL.md                  ← Nuxt full-stack Vue framework
```

## Install

```bash
git clone <this-repo> ~/dotfiles/claude-dotfiles
cd ~/dotfiles/claude-dotfiles
bash install.sh
```

`install.sh` symlinks agents, skills, hooks, and `CLAUDE.md` into `~/.claude/`.

Then copy and edit `settings.json` manually — it contains fields that differ per machine:

```bash
cp .claude/settings.json ~/.claude/settings.json
```

## What is NOT synced

| Path | Reason |
|------|--------|
| `.claude/plugins/` | Managed by Claude Code installer — like `node_modules` |
| `.claude/projects/` | Conversation history JSONL — large and personal |
| `.claude/backups/`, `cache/`, `debug/` | Transient, machine-generated |
| `.claude/.credentials.json` | Auth tokens |
| `.mcporter/mcporter.json` | Contains absolute node/python paths per machine |

## Multi-machine strategy

```
main       ← shared: skills, agents, hooks, CLAUDE.md
i5-gen12   ← this machine (Intel i5 Gen12)
pc-work    ← example: work machine with different paths
```

Improve skills/agents/hooks on any machine → merge to `main` → pull on others.
Keep `settings.json` local — never merge it to `main`.

## mcp-manager fallback chain

The `mcp-manager` agent tries AI CLIs in priority order before falling back to direct mcporter calls:

1. `gemini-cli` — `gemini -y -m gemini-2.5-flash -p "<task>"`
2. `kimi` — `kimi -p "<task>"`
3. `qwen-code` — `qwen -p "<task>"`
4. `codex` — `codex "<task>"`
5. `mcporter` — always available

## Context stack

These dotfiles implement a three-layer context strategy:

| Layer | Tool | Purpose |
|-------|------|---------|
| Tool access | mcporter | On-demand MCP invocation, keeps context lean |
| Content | repomix | Packs codebase to compressed XML (~70% token reduction) |
| Structure | mcp-knowledge-graph | Persistent entity/relation graph across sessions |

The `context-loader.sh` hook fires once per session and injects the project's `.aim/` knowledge graph summary automatically.
