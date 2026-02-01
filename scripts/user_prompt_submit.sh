#!/usr/bin/env bash
set -euo pipefail

# Purpose: append raw UserPromptSubmit hook JSON to a local queue file.
# Why: the session-end processor needs the unmodified event stream.
mkdir -p "/Users/michaelsi/.claude/kb"
cat >> "/Users/michaelsi/.claude/kb/queue.user_prompt_submit.jsonl"
printf '\n' >> "/Users/michaelsi/.claude/kb/queue.user_prompt_submit.jsonl"
