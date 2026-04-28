#!/usr/bin/env python3
import json
import os
import pathlib
import sqlite3
import subprocess
import sys

try:
    data = json.load(sys.stdin)
    cwd = pathlib.Path(data.get("cwd") or os.getcwd())
    db_path = None
    for parent in [cwd] + list(cwd.parents):
        candidate = parent / ".code-review-graph" / "graph.db"
        if candidate.exists():
            db_path = candidate
            break
    if db_path:
        con = sqlite3.connect(db_path)
        count = con.execute("SELECT COUNT(*) FROM nodes").fetchone()[0]
        con.close()
        if count == 0:
            result = subprocess.run(["code-review-graph", "build"], cwd=str(cwd), capture_output=True, text=True, check=False)
        else:
            result = subprocess.run(["code-review-graph", "status"], cwd=str(cwd), capture_output=True, text=True, check=False)
    else:
        result = subprocess.run(["code-review-graph", "build"], cwd=str(cwd), capture_output=True, text=True, check=False)
    text = (result.stdout or "").strip()
    if text:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": text}}))
except Exception:
    pass

sys.exit(0)
