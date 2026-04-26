#!/usr/bin/env python3
import json, sys, hashlib, os, pathlib

try:
    data = json.load(sys.stdin)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})
    session_id = data.get("session_id", os.environ.get("CLAUDE_SESSION_ID", "unknown"))

    key = hashlib.sha256(
        json.dumps({"tool": tool_name, "input": tool_input}, sort_keys=True).encode()
    ).hexdigest()[:16]

    cache_dir = pathlib.Path("/tmp/claude-dedup")
    cache_dir.mkdir(exist_ok=True)
    cache_file = cache_dir / f"{session_id}.txt"

    seen = set(cache_file.read_text().splitlines()) if cache_file.exists() else set()

    if key in seen:
        desc = (
            tool_input.get("file_path")
            or tool_input.get("pattern")
            or tool_input.get("query")
            or tool_input.get("command")
            or str(tool_input)[:80]
        )
        print(f"[dedup] Skipped duplicate {tool_name}({desc}) — result already in context.")
        sys.exit(2)

    with cache_file.open("a") as f:
        f.write(key + "\n")

except Exception:
    pass

sys.exit(0)
