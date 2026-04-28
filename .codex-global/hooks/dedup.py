#!/usr/bin/env python3
import hashlib
import json
import os
import pathlib
import sys

try:
    data = json.load(sys.stdin)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})
    session_id = data.get("session_id", "unknown")
    key = hashlib.sha256(json.dumps({"tool": tool_name, "input": tool_input}, sort_keys=True).encode()).hexdigest()[:16]
    cache_dir = pathlib.Path("/tmp/codex-dedup")
    cache_dir.mkdir(exist_ok=True)
    cache_file = cache_dir / f"{session_id}.txt"
    seen = set(cache_file.read_text().splitlines()) if cache_file.exists() else set()
    if key not in seen:
        with cache_file.open("a") as f:
            f.write(key + "\n")
except Exception:
    pass

sys.exit(0)
