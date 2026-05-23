#!/usr/bin/env python3
import json, sys, re

def strip_r_flag(args):
    args = re.sub(r'\s--recursive\b', '', args)
    args = re.sub(r'\s-([a-zA-Z]*)r([a-zA-Z]+)', r' -\1\2', args)
    args = re.sub(r'\s-r\b', '', args)
    return args

def to_rg(cmd):
    segments = re.split(r'(&&|\|\||;)', cmd)
    out = []
    for seg in segments:
        m = re.match(r'^(\s*)(rtk grep|rgrep|grep)(\s+.*)?$', seg, re.DOTALL)
        if m:
            lead, args = m.group(1), m.group(3) or ''
            out.append(f'{lead}rg{strip_r_flag(args)}')
        else:
            out.append(seg)
    return ''.join(out)

try:
    data = json.load(sys.stdin)
    cmd = data.get("tool_input", {}).get("command", "")
    new_cmd = to_rg(cmd)
    if new_cmd != cmd:
        data["tool_input"]["command"] = new_cmd
        print(json.dumps({"tool_input": data["tool_input"]}))
except Exception:
    pass
sys.exit(0)
