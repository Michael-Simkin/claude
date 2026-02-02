#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLAUDE_KB_RUN:-}" ]]; then
  exit 0
fi

home_dir="${HOME:-}"
if [[ -z "$home_dir" ]]; then
  exit 0
fi

claude_dir="$home_dir/.claude"
kb_repo="$home_dir/.claude-kb"

messages=()

if [[ -d "$claude_dir/.git" ]]; then
  if [[ -n "$(git -C "$claude_dir" status --porcelain)" ]]; then
    messages+=("KB sync skipped: uncommitted changes in $claude_dir")
  else
    if ! git -C "$claude_dir" pull --ff-only --quiet; then
      messages+=("KB sync failed: git pull --ff-only in $claude_dir")
    fi
  fi
fi

if [[ -d "$kb_repo/.git" ]]; then
  diff_output="$(
    KB_REPO="$kb_repo" python3 - <<'PY'
import json
import os
import subprocess

repo = os.environ.get("KB_REPO")
if not repo:
    raise SystemExit(0)

def run(cmd):
    result = subprocess.run(cmd, cwd=repo, text=True, capture_output=True)
    return result.stdout.strip()

stat = run(["git", "-c", "color.ui=false", "diff", "--stat"])
diff = run(["git", "-c", "color.ui=false", "diff"])

if not stat and not diff:
    raise SystemExit(0)

parts = []
if stat:
    parts.append("KB diff summary:\n" + stat)
if diff:
    parts.append("KB diff:\n" + diff)

msg = "\n\n".join(parts).strip()
max_chars = 8000
if len(msg) > max_chars:
    msg = msg[:max_chars].rstrip() + "\n...[truncated]"

print(msg)
PY
  )"
  if [[ -n "$diff_output" ]]; then
    messages+=("$diff_output")
  fi
fi

if (( ${#messages[@]} )); then
  joined="$(printf '%s\n' "${messages[@]}")"
  joined="${joined%$'\n'}"
  KB_SYSTEM_MESSAGE="$joined" python3 - <<'PY'
import json
import os

msg = os.environ.get("KB_SYSTEM_MESSAGE")
if msg:
    print(json.dumps({"systemMessage": msg}))
PY
fi
