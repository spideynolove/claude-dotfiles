# Installed Plugins

Previously configured in `.claude/settings.json` under `enabledPlugins`. Removed from settings to reduce noise — reinstall selectively as needed.

## Active (were `true`)

| Plugin key | Marketplace | Purpose |
|---|---|---|
| `context7@claude-plugins-official` | claude-plugins-official | Fetch up-to-date library docs via MCP |
| `ralph-loop@claude-plugins-official` | claude-plugins-official | Loop/iteration management |
| `superpowers@superpowers-marketplace` | superpowers-marketplace | Meta-skills: brainstorming, TDD, git worktrees, verification, etc. |
| `code-simplifier@claude-plugins-official` | claude-plugins-official | Post-edit code cleanup via `/simplify` |
| `feature-dev@claude-plugins-official` | claude-plugins-official | Guided feature development (feature-dev:feature-dev skill) |
| `claude-md-management@claude-plugins-official` | claude-plugins-official | CLAUDE.md auditing and revision |
| `claude-code-setup@claude-plugins-official` | claude-plugins-official | Codebase automation recommender |
| `typescript-lsp@claude-plugins-official` | claude-plugins-official | TypeScript LSP integration |
| `superpowers-developing-for-claude-code@superpowers-marketplace` | superpowers-marketplace | Skills for Claude Code plugin development |
| `superpowers-lab@superpowers-marketplace` | superpowers-marketplace | Experimental superpowers: tmux, slack, duplicate-finder, mcp-cli |
| `episodic-memory@superpowers-marketplace` | superpowers-marketplace | Conversation search across sessions |
| `claude-hud@claude-hud` | claude-hud (jarrodwatts/claude-hud) | Status line HUD display |

## Disabled (were `false`)

| Plugin key | Reason disabled |
|---|---|
| `superpowers@claude-plugins-official` | Superseded by superpowers@superpowers-marketplace |
| `ui-ux-pro-max@ui-ux-pro-max-skill` | Not in use |
| `explanatory-output-style@claude-plugins-official` | Not in use |
| `learning-output-style@claude-plugins-official` | Not in use |

## Custom marketplace

`claude-hud` was added via `extraKnownMarketplaces`:
```json
{
  "claude-hud": {
    "source": { "source": "github", "repo": "jarrodwatts/claude-hud" }
  }
}
```
This entry is kept in `settings.json` since it's required for the HUD to install/update.

## To re-enable a plugin

```bash
# Open plugin manager
/plugin
# or add back to settings.json enabledPlugins
```
