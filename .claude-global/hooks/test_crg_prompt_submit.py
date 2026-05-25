import json
import os
import pathlib
import sqlite3
import subprocess
import sys
import tempfile

HOOK = os.path.expanduser("~/.claude/hooks/crg_prompt_submit.py")


def run(payload, cwd=None, env=None):
    p = subprocess.run(
        [sys.executable, HOOK],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        cwd=cwd,
        env=env,
    )
    return p.stdout.strip()


def init_git_repo(path):
    subprocess.run(["git", "init", "-q"], cwd=path, check=True)
    subprocess.run(["git", "config", "user.email", "t@t.t"], cwd=path, check=True)
    subprocess.run(["git", "config", "user.name", "t"], cwd=path, check=True)


def commit(repo, name, content):
    (pathlib.Path(repo) / name).write_text(content)
    subprocess.run(["git", "add", "."], cwd=repo, check=True)
    subprocess.run(["git", "commit", "-q", "-m", "c"], cwd=repo, check=True)


def make_graph(repo):
    gdir = pathlib.Path(repo) / ".code-review-graph"
    gdir.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(gdir / "graph.db")
    con.execute("CREATE TABLE nodes (id INTEGER)")
    con.execute("INSERT INTO nodes VALUES (1)")
    con.commit()
    con.close()
    exclude = pathlib.Path(repo) / ".git" / "info" / "exclude"
    exclude.write_text(exclude.read_text() + "\n.code-review-graph/\n")


def make_fake_crg(bindir):
    fake = pathlib.Path(bindir) / "fake-crg"
    lines = [
        "#!/usr/bin/env python3",
        "import sys, pathlib",
        "args = sys.argv[1:]",
        "log = pathlib.Path(__file__).parent / 'crg_calls.log'",
        "with log.open('a') as f:",
        "    f.write(' '.join(args) + chr(10))",
        "if args and args[0] == 'detect-changes':",
        "    print('CHANGES: 2 files, blast radius 3 functions')",
        "sys.exit(0)",
    ]
    fake.write_text("\n".join(lines) + "\n")
    fake.chmod(0o755)
    return str(fake)


def test_no_intent_produces_no_output():
    assert run({"prompt": "what is the weather today", "cwd": os.getcwd()}) == ""


def test_missing_prompt_field_produces_no_output():
    assert run({"cwd": os.getcwd()}) == ""


def test_not_a_git_repo_produces_no_output():
    d = tempfile.mkdtemp()
    assert run({"prompt": "review my changes", "cwd": d}, cwd=d) == ""


def test_git_repo_without_graph_emits_build_reminder():
    d = tempfile.mkdtemp()
    init_git_repo(d)
    out = run({"prompt": "review my changes", "cwd": d}, cwd=d)
    payload = json.loads(out)
    ctx = payload["hookSpecificOutput"]["additionalContext"]
    assert "code-review-graph build" in ctx
    assert payload["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"


def test_intent_keyword_refactor_is_detected():
    d = tempfile.mkdtemp()
    init_git_repo(d)
    out = run({"prompt": "help me refactor this module", "cwd": d}, cwd=d)
    assert "code-review-graph build" in out


def test_graph_present_dirty_uses_head_base_and_emits_brief():
    d = tempfile.mkdtemp()
    bindir = tempfile.mkdtemp()
    init_git_repo(d)
    commit(d, "a.txt", "x")
    make_graph(d)
    (pathlib.Path(d) / "a.txt").write_text("y")
    env = dict(os.environ, CODE_REVIEW_GRAPH_BIN=make_fake_crg(bindir))
    out = run({"prompt": "review my changes", "cwd": d}, cwd=d, env=env)
    assert "CHANGES:" in out
    assert "tilth_read" in out
    calls = (pathlib.Path(bindir) / "crg_calls.log").read_text()
    assert "update --skip-flows" in calls
    assert "detect-changes --brief --base HEAD\n" in calls


def test_graph_present_clean_uses_head_tilde_base():
    d = tempfile.mkdtemp()
    bindir = tempfile.mkdtemp()
    init_git_repo(d)
    commit(d, "a.txt", "x")
    commit(d, "a.txt", "y")
    make_graph(d)
    env = dict(os.environ, CODE_REVIEW_GRAPH_BIN=make_fake_crg(bindir))
    run({"prompt": "review my changes", "cwd": d}, cwd=d, env=env)
    calls = (pathlib.Path(bindir) / "crg_calls.log").read_text()
    assert "detect-changes --brief --base HEAD~1" in calls
