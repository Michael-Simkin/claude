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

messages=()

refl="$claude_dir/REFLECTIONS.md"
if [[ -f "$refl" ]]; then
  n="$(grep -c '^- ' "$refl" 2>/dev/null || echo 0)"
  if [[ -n "$n" ]] && [[ "$n" -gt 0 ]] 2>/dev/null; then
    messages+=("REFLECTIONS.md has $n pending learning(s).")
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
