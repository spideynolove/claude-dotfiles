#!/usr/bin/env python3
import subprocess, pathlib, sqlite3, os, sys

HOME = pathlib.Path.home()
SCAN_ROOTS = [HOME / "Documents"]

def count_nodes(db_path):
    try:
        con = sqlite3.connect(str(db_path))
        n = con.execute("SELECT COUNT(*) FROM nodes").fetchone()[0]
        con.close()
        return n
    except Exception:
        return -1

def build_sync(repo_root):
    result = subprocess.run(
        ["code-review-graph", "build"],
        capture_output=True, text=True, check=False,
        cwd=str(repo_root),
    )
    return result.stdout.strip()

def build_bg(repo_root):
    log_path = HOME / ".claude" / "crg-build.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log = open(log_path, "a")
    log.write(f"\n=== {repo_root} ===\n")
    log.flush()
    subprocess.Popen(
        ["code-review-graph", "build"],
        cwd=str(repo_root),
        stdout=log,
        stderr=subprocess.STDOUT,
    )

try:
    cwd = pathlib.Path(os.getcwd())

    current_db = None
    current_repo = None
    for parent in [cwd] + list(cwd.parents):
        candidate = parent / ".code-review-graph" / "graph.db"
        if candidate.exists():
            current_db = candidate.resolve()
            current_repo = parent
            break

    if current_repo:
        n = count_nodes(current_db)
        if n == 0:
            print(f"[code-review-graph] Empty graph — building {current_repo.name}...")
            out = build_sync(current_repo)
            print(out or "[code-review-graph] Build complete")
        else:
            result = subprocess.run(
                ["code-review-graph", "status"],
                capture_output=True, text=True, check=False,
                cwd=str(current_repo),
            )
            print(result.stdout.strip())
    else:
        out = build_sync(cwd)
        if "files" in out:
            print(out)

    for scan_root in SCAN_ROOTS:
        if not scan_root.exists():
            continue
        for db_path in scan_root.rglob(".code-review-graph/graph.db"):
            resolved = db_path.resolve()
            if current_db and resolved == current_db:
                continue
            if count_nodes(resolved) == 0:
                repo_root = db_path.parent.parent
                print(f"[code-review-graph] Background build: {repo_root.name}")
                build_bg(repo_root)

except Exception:
    pass

sys.exit(0)
