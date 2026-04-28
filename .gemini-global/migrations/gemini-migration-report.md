# Gemini CLI Migration Report

**Date**: Monday, April 27, 2026
**Target**: Gemini CLI (v0.39.1)
**Source**: Claude Code (~/.claude)

## 1. Work Completed

### **Infrastructure & Global Config**
- **Instruction Alignment**: Symlinked `~/.gemini/GEMINI.md` to your existing `CLAUDE.md`. This ensures consistent behavior across tools without maintaining two instruction sets.
- **Command Portability**: Symlinked `~/.claude/commands/` to `~/.gemini/commands/`. All your slash commands (e.g., `refactor`, `semantic-commit`, `xia-group`) are now available in Gemini.
- **Skill Discovery**: Fixed the gap in personal skills. Symlinked the following from `~/.claude/skills/` to the shared pool `~/.agents/skills/`:
  - `agents-refine`, `handoff`, `lightpanda`, `reddit2md`, `x2md`, `xia`.

### **Lifecycle Hooks Synchronization**
Merged your advanced Python-based hooks into `~/.gemini/settings.json`. Gemini now executes these automatically:
1. **PreToolUse: Dedup**: Prevents redundant file reads/searches (saves context).
2. **PreToolUse: CRG Preread**: Enhances `Read` tool calls with graph context.
3. **PreToolUse: RTK**: Integrated `rtk hook gemini` for token-efficient shell output.
4. **PostToolUse: CRG Update**: Automatically keeps `code-review-graph` indices fresh after edits.
5. **SessionStart: CRG Init**: Initializes graph context on startup.

## 2. Validation & Testing

- **Hook Logic**: Verified `dedup.py` and `crg-preread.py` are executable and handle Gemini-style tool payloads.
- **RTK Compatibility**: Verified `rtk` binary is present and the `gemini` hook target is correctly configured in settings.
- **Skill Visibility**: Confirmed Gemini can discover both the shared system skills (like `sequential-thinking`) and your newly symlinked personal skills.
- **Command Execution**: Confirmed that markdown-based commands in `~/.gemini/commands/` are parsed and executable.

## 3. Gemini CLI vs. Codex: Key Differences

While both tools are used for coding, their migration and operational strategies differ:

| Feature | Gemini CLI | Codex |
|---|---|---|
| **Instruction File** | Uses `GEMINI.md` (local/global). | Uses `AGENTS.md` (local/global). |
| **Settings Format** | `settings.json` (JSON). Same hook schema as Claude Code. | `config.toml` (TOML). Uses `hooks.json` for automation. |
| **Hook Management** | Native support for `PreToolUse`, `PostToolUse`, `SessionStart` within `settings.json`. | Native support, but usually managed via separate `hooks.json` in `~/.codex/`. |
| **Skill Path** | Reads from `~/.agents/skills/` and `~/.gemini/skills/`. | Reads from `~/.agents/skills/` and `~/.codex/skills/`. |
| **MCP Strategy** | Registers servers in `settings.json`. | Prefers `mcporter` for on-demand skill-mediated MCP to save startup time. |
| **Extension Logic** | Supports `gemini-extension.json` for directory-level superpowers. | Uses a custom plugin/module system in `~/.codex/plugins`. |
| **Philosophy** | **1:1 Mirroring**: Gemini is a direct fork/evolution of the Claude Code architecture, making migration nearly transparent. | **Modular Optimization**: Codex focuses on decoupling tools (mcporter) and using different file formats (TOML) for cleaner management. |

## 4. Operational Notes

- **Claude HUD**: The `statusLine` feature from Claude Code (claude-hud) is not compatible with the current Gemini CLI version and was skipped.
- **Persistence**: Gemini retains sessions for 30 days by default (configured in `settings.json`).
- **Security**: OAuth-personal is the active auth method.

## 5. Next Steps

- **RTK Tuning**: Monitor `rtk hook gemini` output to ensure it correctly compacts your specific project's build logs.
- **GEMINI.md Refinement**: While symlinked to `CLAUDE.md`, you may want to eventually add a `GEMINI.md` that leverages specific Gemini features (like thinking modes) if they diverge from Claude.
