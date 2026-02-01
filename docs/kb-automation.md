# KB Automation

## Overview

- **SessionStart hook** pulls `~/.claude` from `main` (fast-forward only) and shows the current KB PR description (if any).
- **SessionEnd hook** runs asynchronously and launches a headless KB update job that clones/updates `~/.claude-kb`, applies changes, and pushes/updates the `kb/auto` PR.

## Runtime locations (ignored by git)

- `~/.claude-kb/kb/transcripts/` - session transcripts copied by the headless job
- `~/.claude-kb/kb/run.lock/` - lock directory used to prevent concurrent runs

## Debugging

- Run `claude --debug` to see hook execution details.
- If a run fails, check `gh` output and the PR body for the last summary.
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
