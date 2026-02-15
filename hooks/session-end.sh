#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLAUDE_KB_RUN:-}" ]]; then
  exit 0
fi

home_dir="${HOME:-}"
if [[ -z "$home_dir" ]]; then
  exit 0
fi

hook_payload="$(cat)"

cd "$home_dir/.claude"

CLAUDE_KB_RUN=1 claude -p \
  --dangerously-skip-permissions \
  --output-format json \
  --max-turns 100 \
  --append-system-prompt-file "$home_dir/.claude/commands/kb-auto.md" \
  "$(printf 'Hook input JSON:\n%s' "$hook_payload")"
