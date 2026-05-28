# RTK - Rust Token Killer (Codex CLI)

**Scope**: High-output commands only — build, test, log, git diffs. NOT discovery or file-reading.

## When to prefix with `rtk`

Use `rtk` for commands with noisy output where compression is safe:

```bash
rtk git log --oneline -20
rtk cargo test
rtk npm run build
rtk pytest -q
rtk docker ps
```

## When NOT to use `rtk`

Discovery and source-of-truth commands must run natively — RTK's semantic compression causes wrong inference:

```bash
find . -name "*.py"      # not: rtk find
ls ~/.codex/             # not: rtk ls
grep -r "hook" ~/.codex/ # not: rtk grep
which rtk                # not: rtk which
```

## Meta Commands

```bash
rtk gain            # Token savings analytics
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run raw command without filtering
```

## Verification

```bash
rtk --version
rtk gain
which rtk
```
