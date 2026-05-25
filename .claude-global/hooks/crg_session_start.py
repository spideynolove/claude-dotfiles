#!/usr/bin/env python3
import json
import os
import pathlib
import shutil
import sqlite3
import subprocess
import sys

CRG = (
    os.environ.get("CODE_REVIEW_GRAPH_BIN")
    or shutil.which("code-review-graph")
    or os.path.expanduser("~/env/.venv/bin/code-review-graph")
)


def repo_root(cwd):
    r = subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=str(cwd), capture_output=True, text=True)
    out = r.stdout.strip()
    return out if r.returncode == 0 and out else None


try:
    data = json.load(sys.stdin)
    cwd = pathlib.Path(data.get("cwd") or os.getcwd())
    root = repo_root(cwd)
    if root:
        root = pathlib.Path(root)
        db_path = root / ".code-review-graph" / "graph.db"
        if db_path.exists():
            con = sqlite3.connect(db_path)
            count = con.execute("SELECT COUNT(*) FROM nodes").fetchone()[0]
            con.close()
            sub = "build" if count == 0 else "status"
        else:
            sub = "build"
        result = subprocess.run([CRG, sub], cwd=str(root), capture_output=True, text=True, check=False)
        text = (result.stdout or "").strip()
        if text:
            print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": text}}))
except Exception:
    pass

sys.exit(0)
