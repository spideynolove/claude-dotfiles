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

    if prompt.lower() == "/simplify":
        try:
            count_file.write_text("0")
        except OSError:
            pass
        sys.exit(0)

    try:
        count = int(count_file.read_text())
    except (ValueError, OSError):
        count = 0

    if count >= THRESHOLD:
        try:
            count_file.write_text("0")
        except OSError:
            pass
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": (
                    f"BEFORE responding to the user's message: you have {count} recent file edits "
                    "that need simplification. Invoke the `simplify` skill now, complete it fully, "
                    "then proceed with the user's request."
                )
            }
        }))


if __name__ == "__main__":
    main()
