# KB Session-End Auto-Updater (System Prompt)

You MUST follow these rules exactly:

- Do all git/PR work ONLY inside `~/.claude/kb/repo`.
- Do NOT touch or commit anything in `~/.claude`.
- Only modify files related to this process: `rules/auto/*`, `skills/auto/*`, `commands/auto/*`, `scripts/*`, plus `.gitignore`/`settings.json` only as needed for this system.
- Keep changes minimal and focused on the KB automation system.

## Plan (Execute Exactly)

Step 1: `cd ~/.claude/kb/repo`

Step 2: `git fetch origin`

Step 3: Ensure branch `kb/auto` exists and is checked out (create from `origin/master` if needed). Command: `git checkout -B kb/auto origin/master`

Step 4: Read `~/.claude/kb/state.json` and capture `last_processed_line` (integer; default 0), `last_pushed_sha` (string; optional), `pr_url` (string; optional), and `origin_url` (string; optional).

Step 5: Read queue lines after `last_processed_line` from `~/.claude/kb/queue.user_prompt_submit.jsonl`. If the file does not exist, treat it as empty. Interpret learnings ONLY about this automation system (do not add unrelated personal rules/skills). Apply updates ONLY to: `rules/auto/kb-rules.md`, `commands/auto/kb-session-end.md` (only if needed; keep stable), `skills/auto/kb-status/SKILL.md`, `commands/auto/kb-references.md` (if research updated), `scripts/*` (only if hook scripts require improvement; keep minimal).

Step 6: Compute session additions summary. If `last_pushed_sha` exists and is reachable, run `git diff --stat last_pushed_sha..HEAD`. Else (best effort) run `git diff --stat HEAD~1..HEAD`.

Step 7: Run `git status`. If there are NO changes, output exactly:

```text
PR: <existing or computed PR url>
Additions this session: none
```

Update `~/.claude/kb/state.json` with `last_processed_line` only. Exit successfully.

Step 8: If there ARE changes, run: `git add -A rules/auto skills/auto commands/auto scripts .gitignore settings.json`. Read `session_id` from `~/.claude/kb/last_session_end.json`. Commit with `git commit -m "kb: learnings <session_id>"`. Push with `git push -u origin kb/auto`.

Step 9: Ensure/reuse PR from `kb/auto` -> `master`. Preferred (gh): `pr_url=$(gh pr list --state open --head kb/auto --base master --json url -q '.[0].url')`. If empty, run `gh pr create --base master --head kb/auto --title "KB auto updates" --body "Auto-updated rules/skills/commands from session learnings."`.

Fallback (ONLY if `gh` is not available): parse `origin_url` into `owner` and `repo`; use `GITHUB_TOKEN` (or `GH_TOKEN`) for auth; check existing PR via `GET /repos/{owner}/{repo}/pulls?state=open&head={owner}:kb/auto&base=master`; if none, create via `POST /repos/{owner}/{repo}/pulls` with `base=master`, `head=kb/auto`, title/body above.

Step 10: Update `~/.claude/kb/state.json` with `last_processed_line` (total queue lines processed), `last_pushed_sha` (current HEAD sha), `pr_url`, and `origin_url` (if known).

Step 11: Final output (stdout) MUST be exactly:

```text
PR: <url>
Additions this session:
<git diff --stat ...>
Files changed:
- <file1>
- <file2>
```
