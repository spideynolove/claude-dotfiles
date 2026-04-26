#!/usr/bin/env python3
import subprocess, pathlib, sqlite3, os, sys

try:
    cwd = pathlib.Path(os.getcwd())
    db_path = None
    for parent in [cwd] + list(cwd.parents):
        candidate = parent / ".code-review-graph" / "graph.db"
        if candidate.exists():
            db_path = str(candidate)
            break

    if db_path:
        con = sqlite3.connect(db_path)
        count = con.execute("SELECT COUNT(*) FROM nodes").fetchone()[0]
        con.close()
        if count == 0:
            print("[code-review-graph] Empty graph — running build...")
            subprocess.run(["code-review-graph", "build"], check=False)
        else:
            result = subprocess.run(
                ["code-review-graph", "status"],
                capture_output=True, text=True, check=False
            )
            print(result.stdout.strip())
    else:
        result = subprocess.run(
            ["code-review-graph", "build"],
            capture_output=True, text=True, check=False
        )
        if "files" in result.stdout:
            print(result.stdout.strip())
except Exception:
    pass

sys.exit(0)
