# .agents-global sync notes

## Skills already in .claude-global/skills/ — not duplicated here

Pick these from `.claude-global/skills/` if you need them:

- `agents-refine`
- `graphify`
- `handoff`
- `lightpanda`
- `playwright`
- `reddit2md`
- `repomix`
- `sequential-thinking`
- `x2md`
- `xia`

## Agents (not synced — broken symlinks)

`~/.agents/agents/` entries are symlinks pointing to a `.agents/agents/` folder
inside this dotfiles repo that does not exist yet. The actual agent `.md` files
were never committed. Create `~/.agents/agents/*.md` as real files and re-sync
if you want them tracked here.

## Skipped

- `~/.agents/.skill-lock.json` — machine-specific, not portable
- `~/.agents/skills/superpowers` — symlink, skipped
