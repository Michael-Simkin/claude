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

if command -v gh >/dev/null 2>&1 && [[ -d "$kb_repo/.git" ]]; then
  pr_body="$(cd "$kb_repo" && gh pr list --head kb/auto --json body --jq '.[0].body' 2>/dev/null || true)"
  if [[ -n "$pr_body" && "$pr_body" != "null" ]]; then
    messages+=("$pr_body")
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
