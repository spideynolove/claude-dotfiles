# Communication Rules

## Acknowledging Feedback

When feedback IS correct:

✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ "[Just fix it and show in the code]"

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression

**Why no thanks:** Actions speak. Just fix it. The code itself shows you heard the feedback.

**If you catch yourself about to write "Thanks":** DELETE IT. State the fix instead.

## Correcting Your Pushback

If you pushed back and were wrong:

✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining

State the correction factually and move on.

## Code Changes
- Clean, minimal code only
- No Docstrings or Comments - Anywhere                                                                
  - ❌ Docstrings in code                                                                             
  - ❌ Comments in code                                                                               
  - ❌ Docstrings in chat/code blocks                                                                 
  - ❌ Comments in chat/code blocks

## Git Commits
- NEVER create git commits automatically after completing a task
- ONLY commit when explicitly asked by the user
- Do not suggest committing unless the user asks

## Common Env

### Local Python Dev
- `source /home/hung/env/.venv/bin/activate` before using `python`
- `uv pip install xxx` before any new package installations.

## Testing

Minimum 80% test coverage. TDD workflow: write test (RED) → implement (GREEN) → refactor.
All features require unit + integration tests. E2E tests for critical user flows.

## TypeScript

- Explicit types on exported functions and public APIs; let TypeScript infer locals
- Use `interface` for extendable object shapes, `type` for unions/intersections
- Avoid `any`; use `unknown` for external input and narrow safely
- Immutable updates via spread: `return { ...obj, field: value }`
- No `console.log` in production code; use proper logging libraries
- Validate external input with Zod; infer types from schemas

## Security

Before any commit:
- No hardcoded secrets — use environment variables only
- Validate all user inputs at system boundaries
- Parameterized queries (no string interpolation in SQL)
- Sanitize HTML outputs (XSS prevention)
- Error messages must not leak internal state

Security issue found → STOP → use `security-reviewer` agent → fix before continuing.