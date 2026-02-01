# KB Automation

## Overview

- **SessionStart hook** pulls `~/.claude` from `main` (fast-forward only) and shows the most recent KB PR from `~/.claude-kb/kb/last_pr.txt`.
- **SessionEnd hook** runs asynchronously, copies the transcript into `~/.claude-kb/kb/transcripts/`, launches a headless KB update job, and pushes/updates the `kb/auto` PR.

## Runtime locations (ignored by git)

- `~/.claude-kb/kb/transcripts/` - session transcripts copied from hooks
- `~/.claude-kb/kb/last_pr.txt` - most recent PR URL or status note
- `~/.claude-kb/kb/last_claude_output.json` - raw headless output
- `~/.claude-kb/kb/run.lock` - lock file for concurrent runs

## Debugging

- Run `claude --debug` to see hook execution details.
- If a run fails, check `last_claude_output.json` and `last_pr.txt`.
- If `gh` is not authenticated, run `gh auth status`.

## Manual test (local)

SessionStart:

```shell
bash "$HOME/.claude/hooks/session-start.sh"
```

SessionEnd (async):

```shell
echo '{"session_id":"manual-test","transcript_path":"/path/to/transcript.jsonl"}' | bash "$HOME/.claude/hooks/session-end.sh"
```
