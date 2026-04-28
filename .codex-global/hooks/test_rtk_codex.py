#!/usr/bin/env python3
import json
import subprocess
import unittest


class RtkCodexHookTest(unittest.TestCase):
    def test_rewrite_is_silent_success(self):
        payload = {
            "tool_name": "Bash",
            "tool_input": {"command": "ls -la"},
            "session_id": "test",
        }
        result = subprocess.run(
            ["python3", "/home/hung/.codex/hooks/rtk_codex.py"],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            check=True,
        )
        self.assertEqual(result.stdout, "")
        self.assertEqual(result.stderr, "")


class DedupHookTest(unittest.TestCase):
    def test_duplicate_command_is_silent_and_allowed(self):
        payload = {
            "tool_name": "Bash",
            "tool_input": {"command": "sed -n '1,220p' /home/hung/.codex/hooks.json"},
            "session_id": "dedup-test",
        }
        for _ in range(2):
            result = subprocess.run(
                ["python3", "/home/hung/.codex/hooks/dedup.py"],
                input=json.dumps(payload),
                text=True,
                capture_output=True,
            )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
