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
  claude_status="$(git -C "$claude_dir" status --porcelain)"
  if [[ -z "$claude_status" ]]; then
    git -C "$claude_dir" pull --ff-only --quiet || true
    claude_status="$(git -C "$claude_dir" status --porcelain)"
  fi

  if [[ -n "$claude_status" ]]; then
    messages+=("~/.claude has pending changes.")
  fi
fi

if [[ -d "$kb_repo/.git" ]]; then
  if [[ -n "$(git -C "$kb_repo" status --porcelain)" ]]; then
    messages+=("~/.claude-kb has pending changes.")
  fi
fi

if [[ -d ".git" ]] && [[ ! -d ".grepai" ]]; then
  messages+=("GrepAI is not initialized in this repo. Run: 'grepai init -p ollama -b gob' or ask Claude to do it.")
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
