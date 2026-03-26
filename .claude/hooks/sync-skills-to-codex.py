#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

MANIFEST_FILE = ".skillshare-manifest.json"
SKILL_FILENAME = "SKILL.md"

DEFAULT_TARGETS = [
    ("codex", Path.home() / ".codex/skills"),
    ("qwen", Path.home() / ".qwen/skills"),
]


def parse_targets(skill_md_path):
    content = skill_md_path.read_text()
    if not content.startswith("---"):
        return None
    try:
        end = content.index("---", 3)
    except ValueError:
        return None
    front = content[3:end]
    for line in front.splitlines():
        if line.strip().startswith("targets:"):
            val = line.split(":", 1)[1].strip().strip("[]")
            return [t.strip() for t in val.split(",") if t.strip()]
    return None


def read_managed(target_dir):
    p = target_dir / MANIFEST_FILE
    if p.exists():
        return json.loads(p.read_text()).get("managed", {})
    return {}


def write_managed(target_dir, managed):
    p = target_dir / MANIFEST_FILE
    p.write_text(json.dumps({"managed": managed}, indent=2))


def sync(source, target, tool, dry_run):
    target.mkdir(parents=True, exist_ok=True)
    managed = read_managed(target)
    found = set()

    for skill_dir in sorted(source.iterdir()):
        if not skill_dir.is_dir():
            continue
        skill_md = skill_dir / SKILL_FILENAME
        if not skill_md.exists():
            continue
        targets = parse_targets(skill_md)
        if targets is not None and tool not in targets:
            continue
        name = skill_dir.name
        found.add(name)
        link = target / name
        if link.is_symlink():
            if link.resolve() == skill_dir.resolve():
                continue
            if not dry_run:
                link.unlink()
        elif link.exists():
            continue
        if not dry_run:
            link.symlink_to(skill_dir.resolve())
            managed[name] = "symlink"
        print(f"[{tool}] linked: {name}")

    for name in list(managed.keys()):
        if name not in found:
            link = target / name
            if link.is_symlink():
                if not dry_run:
                    link.unlink()
                    del managed[name]
                print(f"[{tool}] pruned: {name}")

    if not dry_run:
        write_managed(target, managed)


def is_skill_edit(event):
    tool_name = event.get("tool_name", "")
    if tool_name not in ("Edit", "Write"):
        return False
    file_path = event.get("tool_input", {}).get("file_path", "")
    return ".claude/skills" in file_path or SKILL_FILENAME in file_path


def main():
    dry_run = "--dry-run" in sys.argv
    hook_mode = "--hook" in sys.argv

    if hook_mode:
        try:
            event = json.load(sys.stdin)
            if not is_skill_edit(event):
                return
        except (json.JSONDecodeError, AttributeError):
            return

    source = Path(os.environ.get("SKILLSHARE_SOURCE", Path.home() / ".claude/skills"))

    if not source.exists():
        print(f"source not found: {source}", file=sys.stderr)
        sys.exit(1)

    targets = DEFAULT_TARGETS
    if "SKILLSHARE_CODEX_TARGET" in os.environ:
        targets = [("codex", Path(os.environ["SKILLSHARE_CODEX_TARGET"]))]
    if "SKILLSHARE_QWEN_TARGET" in os.environ:
        targets = [("qwen", Path(os.environ["SKILLSHARE_QWEN_TARGET"]))]

    for tool, target_path in targets:
        sync(source, target_path, tool, dry_run)


if __name__ == "__main__":
    main()
