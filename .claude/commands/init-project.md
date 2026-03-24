Generate a CLAUDE.md file for the current project using an external AI CLI.

## Steps

1. Check if `CLAUDE.md` already exists in the current working directory
   - If it exists, print "CLAUDE.md already exists — skipping generation" and stop

2. Try each CLI in order until one succeeds:

   **a) codex**
   ```bash
   which codex && codex exec "Read the codebase at $(pwd). Generate a CLAUDE.md with: project description, build/test/lint commands, architecture overview, code conventions. Write it to CLAUDE.md."
   ```

   **b) qwen**
   ```bash
   which qwen && qwen --approval-mode full-auto -p "Read the codebase at $(pwd). Generate a CLAUDE.md with: project description, build/test/lint commands, architecture overview, code conventions. Write it to CLAUDE.md."
   ```

   **c) kimi**
   ```bash
   which kimi && kimi --print -p "Read the codebase at $(pwd). Generate a CLAUDE.md with: project description, build/test/lint commands, architecture overview, code conventions. Write it to CLAUDE.md." -y -o text
   ```

3. After each attempt, check if `CLAUDE.md` was created:
   ```bash
   [ -f CLAUDE.md ] && echo "CLAUDE.md generated successfully"
   ```

4. If all CLIs fail or none are available, print a warning:
   "No external CLI could generate CLAUDE.md. Create it manually or run /init-project again when a CLI is available."

## Rules

- Do not generate CLAUDE.md yourself — the point is to use an external tool for a fresh perspective
- Do not modify an existing CLAUDE.md
- Report which CLI succeeded
