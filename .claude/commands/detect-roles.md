Detect the project type from file-presence signals and generate developer roles. No LLM inference needed for detection — use deterministic file checks.

## Detection Logic

Run these checks against the current working directory:

```bash
HAS_PACKAGE_JSON=false; [ -f package.json ] && HAS_PACKAGE_JSON=true
HAS_FRONTEND=false; [ -f package.json ] && grep -qE '"(react|vue|angular|next|nuxt|svelte|solid)"' package.json 2>/dev/null && HAS_FRONTEND=true
HAS_BACKEND=false; ([ -f requirements.txt ] || [ -f pyproject.toml ]) && grep -qlE '(fastapi|django|flask)' requirements.txt pyproject.toml 2>/dev/null && HAS_BACKEND=true
[ -f package.json ] && grep -qE '"(express|nestjs|hono|fastify)"' package.json 2>/dev/null && HAS_BACKEND=true
HAS_DB=false; (ls *.db docker-compose* 2>/dev/null | grep -q . || grep -rqlE '(prisma|typeorm|sqlalchemy|mongoose|drizzle)' package.json pyproject.toml 2>/dev/null) && HAS_DB=true
HAS_AI_ML=false; (grep -qlE '(torch|tensorflow|transformers|langchain|openai|anthropic)' requirements.txt pyproject.toml package.json 2>/dev/null) && HAS_AI_ML=true
HAS_SYSTEMS=false; ([ -f Cargo.toml ] || [ -f go.mod ]) && HAS_SYSTEMS=true
HAS_INFRA=false; ([ -d terraform ] || [ -d k8s ] || [ -f Dockerfile ]) && HAS_INFRA=true
HAS_DATA=false; ([ -f dbt_project.yml ] || [ -d airflow ]) && HAS_DATA=true
```

## Classification (first match wins)

| Condition | Project Type |
|-----------|-------------|
| HAS_FRONTEND && HAS_BACKEND | `web-fullstack` |
| HAS_FRONTEND | `web-frontend` |
| HAS_BACKEND && HAS_DB | `web-backend` |
| HAS_AI_ML | `ai-ml` |
| HAS_SYSTEMS | `systems` |
| HAS_INFRA | `infra` |
| HAS_DATA | `data-pipeline` |
| *(none match)* | `general` |

## Role Templates

Based on detected project type, propose these roles:

**web-fullstack:**
- architect → claude, task_types: design, review, refactor
- frontend-dev → qwen, task_types: implement, component, style
- backend-dev → qwen, task_types: implement, api, database
- tester → qwen, task_types: test, verify

**web-frontend:**
- architect → claude, task_types: design, review, refactor
- ui-dev → qwen, task_types: implement, component, style
- tester → qwen, task_types: test, verify

**web-backend:**
- architect → claude, task_types: design, review, refactor
- api-dev → qwen, task_types: implement, api, database
- tester → qwen, task_types: test, verify

**ai-ml:**
- ai-engineer → claude, task_types: design, implement, model
- data-engineer → qwen, task_types: implement, pipeline, data
- tester → qwen, task_types: test, verify

**systems:**
- architect → claude, task_types: design, review, refactor
- developer → qwen, task_types: implement, optimize
- tester → qwen, task_types: test, verify

**infra:**
- platform-engineer → claude, task_types: design, review, infrastructure
- developer → qwen, task_types: implement, configure
- tester → qwen, task_types: test, verify

**data-pipeline:**
- data-engineer → claude, task_types: design, pipeline, model
- developer → qwen, task_types: implement, transform
- tester → qwen, task_types: test, verify

**general:**
- architect → claude, task_types: design, review, refactor
- developer → qwen, task_types: implement
- tester → qwen, task_types: test, verify

## Output

1. Print the detected project type and the signals that matched
2. Print the proposed roles in a table
3. Ask the user: "Accept these roles? (y/edit/skip)"
   - **y**: Write `.aim/roles.json`
   - **edit**: Let user modify roles before writing
   - **skip**: Do not write roles file

## roles.json Format

```json
{
  "project_type": "<detected type>",
  "roles": [
    {"id": "<role>", "preferred_tool": "<tool>", "task_types": ["<type>", "..."]}
  ]
}
```

Create `.aim/` directory if it doesn't exist before writing.
