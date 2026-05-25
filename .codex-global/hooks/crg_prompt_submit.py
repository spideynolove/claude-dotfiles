#!/usr/bin/env python3
import json
import os
import pathlib
import re
import shutil
import sqlite3
import subprocess
import sys

CRG = (
    os.environ.get("CODE_REVIEW_GRAPH_BIN")
    or shutil.which("code-review-graph")
    or os.path.expanduser("~/env/.venv/bin/code-review-graph")
)

KEYWORDS = (
    "review", "refactor", "impact", "blast radius", "callers", "callees",
    "dependents", "affected", "coverage", "architecture",
)

HANDOFF = (
    "This is code-review-graph's first-pass change analysis (from the code-review-graph "
    "CLI). For deeper detail use code-review-graph tooling (CLI: code-review-graph "
    "detect-changes / code-review-graph status; or mcporter/MCP if registered on this "
    "agent) before relying on git diff. Once CRG narrows the risky files/symbols, hand "
    "them to tilth (tilth_read, tilth_search) for precise reading."
)

UNAVAILABLE = "CRG graph unavailable for this repo. Run: code-review-graph build"


def emit(text):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": text,
        }
    }))


def has_intent(prompt):
    if any(k in prompt for k in KEYWORDS):
        return True
    return bool(re.search(r"before\b.*\bcommit", prompt))


def repo_root(cwd):
    r = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=str(cwd), capture_output=True, text=True,
    )
    out = r.stdout.strip()
    return pathlib.Path(out) if r.returncode == 0 and out else None


def find_graph(root):
    for parent in [root] + list(root.parents):
        db = parent / ".code-review-graph" / "graph.db"
        if db.exists():
            return db
    return None


def main():
    data = json.load(sys.stdin)
    prompt = (data.get("prompt") or data.get("user_prompt") or data.get("message") or "").lower()
    if not has_intent(prompt):
        return
    cwd = pathlib.Path(data.get("cwd") or os.getcwd())
    root = repo_root(cwd)
    if not root:
        return
    db = find_graph(root)
    if not db:
        emit(UNAVAILABLE)
        return
    con = sqlite3.connect(db)
    nodes = con.execute("SELECT COUNT(*) FROM nodes").fetchone()[0]
    con.close()
    if nodes == 0:
        emit(UNAVAILABLE)
        return
    dirty = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=str(root), capture_output=True, text=True,
    ).stdout.strip()
    base = "HEAD" if dirty else "HEAD~1"
    subprocess.run(
        [CRG, "update", "--skip-flows"],
        cwd=str(root), capture_output=True, text=True,
    )
    r = subprocess.run(
        [CRG, "detect-changes", "--brief", "--base", base],
        cwd=str(root), capture_output=True, text=True,
    )
    brief = (r.stdout or "").strip()
    if brief:
        emit(brief + "\n\n" + HANDOFF)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
