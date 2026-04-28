#!/usr/bin/env python3
import json
import subprocess
import sys


def main():
    payload = sys.stdin.read()
    result = subprocess.run(
        ["rtk", "hook", "claude"],
        input=payload,
        text=True,
        capture_output=True,
    )
    if result.stderr:
        print(result.stderr, end="", file=sys.stderr)
    stdout = result.stdout.strip()
    if not stdout:
        sys.exit(result.returncode)
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
