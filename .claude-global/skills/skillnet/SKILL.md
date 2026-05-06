---
name: skillnet
description: Search, install, create, and evaluate AI agent skills from the SkillNet community registry (400k+ skills). Routes downloads to correct CLI directory (claude/codex/opencode).
trigger: /skillnet
---

# /skillnet

SkillNet is the npm for AI agent skills. Search 400k+ community skills, install them into any local CLI, create new skills from repos/docs/prompts, and evaluate quality with 5-dimension scoring.

## Usage

```
/skillnet search <query>                          # semantic search community registry
/skillnet search <query> --mode vector            # AI semantic search (more precise)
/skillnet download <url>                          # install skill package (prompts for target CLI)
/skillnet download <url> --for claude             # install to ~/.claude/skills/
/skillnet download <url> --for codex              # install to ~/.codex/skills/
/skillnet download <url> --for opencode           # install to ~/.opencode/skills/
/skillnet download <url> --for all                # install to all three CLIs
/skillnet create --github <url>                   # auto-create skill from GitHub repo (needs API key)
/skillnet create --prompt "<description>"         # generate skill from natural language (needs API key)
/skillnet create --office <file.pdf>              # extract skill from PDF/PPT/Word (needs API key)
/skillnet evaluate <path>                         # 5D quality score: safety/completeness/exec/maintainability/cost
/skillnet analyze <dir>                           # build relationship graph across all local skills
```

## CLI Directories

| CLI      | Skills directory              |
|----------|-------------------------------|
| claude   | `~/.claude/skills/`           |
| codex    | `~/.codex/skills/`            |
| opencode | `~/.opencode/skills/`         |
| dotfiles | `~/Documents/claude-dotfiles/.claude-global/skills/` |

## What You Must Do When Invoked

Always activate the venv and load credentials before running skillnet commands:
```bash
source ~/.secrets
source ~/env/.venv/bin/activate
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet <command>
```

Search and download need no API key. Create/evaluate/analyze require it.

### For `/skillnet search`

```bash
source ~/.secrets && source ~/env/.venv/bin/activate
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 skillnet search "QUERY" --limit 10
```

Present results as a table: name, stars, short description. Offer to download any result.

For `--mode vector`:
```bash
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 skillnet search "QUERY" --mode vector --threshold 0.80 --limit 10
```

### For `/skillnet download`

1. Run the download to a temp dir first to inspect:
```bash
source ~/.secrets && source ~/env/.venv/bin/activate
skillnet download URL -d /tmp/skillnet-preview
ls /tmp/skillnet-preview/
```

2. Show the user what was downloaded (skill name, description, files).

3. Determine target directories based on `--for` flag:
   - `--for claude` → `~/.claude/skills/<skill-name>/`
   - `--for codex` → `~/.codex/skills/<skill-name>/`
   - `--for opencode` → `~/.opencode/skills/<skill-name>/`
   - `--for all` → all three above
   - no flag → ask user which CLI(s)

4. Copy to each target:
```bash
cp -r /tmp/skillnet-preview/<skill-name> TARGET_DIR/
```

5. Note: SkillNet packages are structured YAML/markdown bundles — different format from Claude Code SKILL.md. They serve as reference/inspiration. If the user wants a native Claude Code skill, offer to convert it using `/skillnet create --prompt` based on the downloaded content.

6. Also copy to dotfiles mirror if installing for claude:
```bash
cp -r /tmp/skillnet-preview/<skill-name> ~/Documents/claude-dotfiles/.claude-global/skills/
```

### For `/skillnet create`

Requires `OPENAI_API_KEY` set in environment. If not set, tell the user:
> Set `OPENAI_API_KEY` in your shell environment to use create/evaluate/analyze.

```bash
# From GitHub repo
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet create --github GITHUB_URL -d ~/.claude/skills/

# From prompt
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet create --prompt "DESCRIPTION" -d ~/.claude/skills/

# From file
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet create --office FILE_PATH -d ~/.claude/skills/
```

After creation, show the generated skill name and path, then offer to evaluate it.

### For `/skillnet evaluate`

```bash
source ~/.secrets && source ~/env/.venv/bin/activate
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet evaluate PATH_TO_SKILL
```

Present the 5 scores clearly:
- Safety
- Completeness  
- Executability
- Maintainability
- Cost-Awareness

Flag any score below 0.7 as needing attention.

### For `/skillnet analyze`

```bash
source ~/.secrets && source ~/env/.venv/bin/activate
API_KEY=$OPENROUTER_API_KEY BASE_URL=https://openrouter.ai/api/v1 SKILLNET_MODEL=openai/gpt-4o skillnet analyze DIR --model openai/gpt-4o
```

Requires API key. Summarize the relationship graph: which skills are similar, depend on each other, or could be composed.

## MCP Tools (available as skillnet MCP server)

When the SkillNet MCP server is connected, you can also use its tools directly without the CLI. The MCP server exposes the same search/download/create/evaluate/analyze operations as structured tool calls.
