---
description: Show KB auto-updater queue and state status.
allowed-tools: ReadFile, Shell
---

# KB Status

## Goal
Report queue size, `last_processed_line`, `last_pushed_sha`, and `pr_url`.

## Steps
1. Read `~/.claude/kb/state.json` and extract the fields if present.
2. Count lines in `~/.claude/kb/queue.user_prompt_submit.jsonl` (0 if missing).
3. Print a short status summary.
