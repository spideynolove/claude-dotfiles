#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "")
    session_id = re.sub(r"[^a-zA-Z0-9_-]", "_", session_id) or "unknown"
    count_file = Path(f"/tmp/cc-edits-{session_id}")

    try:
        count = int(count_file.read_text())
    except (ValueError, OSError):
        count = 0
    try:
        count_file.write_text(str(count + 1))
    except OSError:
        pass


if __name__ == "__main__":
    main()
