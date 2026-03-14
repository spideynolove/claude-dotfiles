Spawn the codebase-analyst agent to build a persistent knowledge graph for the current project.

The agent will:
1. Pack the current working directory with repomix (compress: true)
2. Analyze the packed output using sequential-thinking — three branches: structure, runtime-behaviors, limits-and-failures
3. Persist entities and relations to the knowledge graph (location: "project") into .aim/memory.jsonl

After this completes, context-loader.sh will automatically inject the graph at the start of every future session in this project.

Run this once per project. Re-run when the architecture changes significantly.
