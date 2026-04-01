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
    count_file = Path(f"/tmp/cc-edits-{session_id}")
    done_file = Path(f"/tmp/cc-simplified-{session_id}")

    if done_file.exists():
        try:
            done_file.unlink()
            count_file.write_text("0")
        except OSError:
            pass
        sys.exit(0)

    try:
        count = int(count_file.read_text()) if count_file.exists() else 0
    except (ValueError, OSError):
        count = 0
    count += 1
    try:
        count_file.write_text(str(count))
    except OSError:
        sys.exit(0)

    if count >= THRESHOLD:
        print(
            f"[AUTO-SIMPLIFY] {count} file edits this session. "
            "Invoke the simplify skill now before continuing. "
            "Use: Skill(skill='simplify')",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()
