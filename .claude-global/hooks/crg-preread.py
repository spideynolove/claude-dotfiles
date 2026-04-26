#!/usr/bin/env python3
import json, sys, sqlite3, pathlib, os

try:
    data = json.load(sys.stdin)
    inp = data.get("tool_input", {})
    file_path = inp.get("file_path", "")
    if not file_path:
        sys.exit(0)

    cwd = pathlib.Path(os.getcwd())
    db_path = None
    repo_root = None
    for parent in [cwd] + list(cwd.parents):
        candidate = parent / ".code-review-graph" / "graph.db"
        if candidate.exists():
            db_path = str(candidate)
            repo_root = parent
            break

    if not db_path:
        sys.exit(0)

    try:
        rel_path = str(pathlib.Path(file_path).relative_to(repo_root))
    except ValueError:
        rel_path = file_path

    con = sqlite3.connect(db_path)
    cur = con.cursor()

    cur.execute("SELECT name, type FROM nodes WHERE file = ? LIMIT 10", (rel_path,))
    nodes = cur.fetchall()
    if not nodes:
        con.close()
        sys.exit(0)

    cur.execute("""
        SELECT DISTINCT n_caller.file, n_caller.name
        FROM edges e
        JOIN nodes n_target ON e.target = n_target.id
        JOIN nodes n_caller ON e.source = n_caller.id
        WHERE n_target.file = ? AND e.type = 'calls' LIMIT 8
    """, (rel_path,))
    callers = cur.fetchall()

    cur.execute("""
        SELECT DISTINCT n_dep.file
        FROM edges e
        JOIN nodes n_src ON e.source = n_src.id
        JOIN nodes n_dep ON e.target = n_dep.id
        WHERE n_src.file = ? AND e.type IN ('imports', 'calls') LIMIT 6
    """, (rel_path,))
    deps = [r[0] for r in cur.fetchall() if r[0] != rel_path]
    con.close()

    lines = [f"[code-review-graph] {rel_path} — {len(nodes)} nodes"]
    for name, typ in nodes[:6]:
        lines.append(f"  {typ}: {name}")
    if callers:
        caller_files = list(dict.fromkeys(f for f, _ in callers))[:3]
        lines.append(f"  called by: {', '.join(caller_files)}")
    if deps:
        lines.append(f"  depends on: {', '.join(deps[:3])}")
    lines.append("  → Use MCP tools (query_graph, get_impact_radius) for deeper analysis.")
    print("\n".join(lines))

except Exception:
    pass

sys.exit(0)
