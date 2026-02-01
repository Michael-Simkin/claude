#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLAUDE_KB_RUN:-}" ]]; then
  exit 0
fi

hook_payload="$(cat)"

CLAUDE_KB_RUN=1 claude -p \
  --dangerously-skip-permissions \
  --output-format json \
  --max-turns 100 \
  --append-system-prompt-file "$HOME/.claude/commands/kb-auto.md" \
  "$(printf 'Hook input JSON:\n%s' "$hook_payload")"
