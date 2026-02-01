#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLAUDE_KB_RUN:-}" ]]; then
  exit 0
fi

exec python3 "$HOME/.claude/scripts/kb-session-end.py"
