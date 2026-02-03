# KB Automation

## Overview

- **SessionStart hook** pulls `~/.claude` from `main` (fast-forward only) and prints a compact list of tracked file changes (staged/unstaged) for `~/.claude` and `~/.claude-kb`.
- **SessionEnd hook** runs asynchronously and launches a headless KB update job that updates files directly on `~/.claude-kb` `main` (no commits, no PRs).

## Runtime locations (ignored by git)

- `~/.claude-kb/kb/run.lock/` - lock directory used to prevent concurrent runs

## Debugging

- Run `claude --debug` to see hook execution details.
- If a run fails, check the hook output in the transcript.

## Manual test (local)

SessionStart:

```shell
bash "$HOME/.claude/hooks/session-start.sh"
```

SessionEnd (async):

```shell
echo '{"session_id":"manual-test","transcript_path":"/path/to/transcript.jsonl"}' | bash "$HOME/.claude/hooks/session-end.sh"
```
