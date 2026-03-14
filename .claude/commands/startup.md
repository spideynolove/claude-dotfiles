Single entry point for project onboarding. Chains three phases in sequence, skipping any that are already complete.

## Phase A — Codebase Analysis

Check if `.aim/memory.jsonl` exists:

```bash
[ -f .aim/memory.jsonl ] && echo "Knowledge graph exists" || echo "NEEDS_ONBOARD"
```

If NEEDS_ONBOARD: spawn the codebase-analyst agent to build the knowledge graph:
```
Agent(subagent_type: "codebase-analyst", prompt: "Analyze the codebase at $(pwd). Store findings in .aim/")
```

Wait for completion before proceeding.

## Phase B — Project CLAUDE.md

Check if `CLAUDE.md` exists:

```bash
[ -f CLAUDE.md ] && echo "CLAUDE.md exists" || echo "NEEDS_INIT"
```

If NEEDS_INIT: run `/init-project` to generate it via an external CLI.

Wait for completion before proceeding.

## Phase C — Role Detection

Check if `.aim/roles.json` exists:

```bash
[ -f .aim/roles.json ] && echo "Roles defined" || echo "NEEDS_ROLES"
```

If NEEDS_ROLES: run `/detect-roles` to detect project type and generate roles.

## Summary

After all phases complete, print:

```
Startup complete:
  Knowledge graph: <entity count from .aim/memory.jsonl or "skipped">
  CLAUDE.md: <exists | generated | skipped>
  Project type: <from .aim/roles.json or "not detected">
  Roles: <comma-separated role IDs or "none">
```

Read the actual files to populate the summary:

```bash
[ -f .aim/memory.jsonl ] && echo "Entities: $(grep -c '"type":"entity"' .aim/memory.jsonl)"
[ -f .aim/roles.json ] && python3 -c "import json; r=json.load(open('.aim/roles.json')); print(f\"Type: {r['project_type']}, Roles: {', '.join(x['id'] for x in r['roles'])}\")"
```

## Rules

- Run phases in order: A → B → C
- Skip any phase where the output file already exists
- If a phase fails, log the error and continue to the next phase
- Do not ask the user between phases unless /detect-roles requires confirmation
