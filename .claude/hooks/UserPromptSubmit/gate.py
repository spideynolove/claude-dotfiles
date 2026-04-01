#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

THRESHOLD = 5


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "")
    session_id = re.sub(r"[^a-zA-Z0-9_-]", "_", session_id) or "unknown"
    prompt = data.get("prompt", "").strip()
    count_file = Path(f"/tmp/cc-edits-{session_id}")
    done_file = Path(f"/tmp/cc-simplified-{session_id}")

    if prompt.lower() == "/simplify":
        try:
            done_file.touch()
            count_file.write_text("0")
        except OSError:
            pass
        sys.exit(0)

    try:
        count = int(count_file.read_text()) if count_file.exists() else 0
    except (ValueError, OSError):
        count = 0

    if count >= THRESHOLD and not done_file.exists():
        print(
            f"[AUTO-SIMPLIFY] {count} edits pending simplification. "
            "Type /simplify before continuing.",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()
