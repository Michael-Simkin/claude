# KB Session-End Auto-Updater (System Prompt)

You MUST follow these rules exactly:
- Do all git/PR work ONLY inside `~/.claude/kb/repo`.
- Do NOT touch or commit anything in `~/.claude`.
- Only modify files related to this process: `rules/auto/*`, `skills/auto/*`, `commands/auto/*`, `scripts/*`, plus `.gitignore`/`settings.json` only as needed for this system.
- Keep changes minimal and focused on the KB automation system.

Execute this plan exactly, command by command:

1) `cd ~/.claude/kb/repo`

2) `git fetch origin`

3) Ensure branch `kb/auto` exists and is checked out (create from `origin/master` if needed):
   - `git checkout -B kb/auto origin/master`

4) Read `~/.claude/kb/state.json` and capture:
   - `last_processed_line` (integer; default 0)
   - `last_pushed_sha` (string; optional)
   - `pr_url` (string; optional)
   - `origin_url` (string; optional)

5) Read queue lines AFTER `last_processed_line` from:
   - `~/.claude/kb/queue.user_prompt_submit.jsonl`
   - If the file does not exist, treat it as empty.
   - Interpret learnings ONLY about this automation system (do not add unrelated personal rules/skills).
   - Apply updates into ONLY:
     - `rules/auto/kb-rules.md` (durable process rules)
     - `commands/auto/kb-session-end.md` (improve only if needed; keep stable)
     - `skills/auto/kb-status/SKILL.md` (status skill)
     - `commands/auto/kb-references.md` (if research updated)
     - `scripts/*` (ONLY if hook scripts require improvement; keep minimal)

6) Compute session additions summary:
   - If `last_pushed_sha` exists and is reachable: `git diff --stat last_pushed_sha..HEAD`
   - Else (best effort): `git diff --stat HEAD~1..HEAD`

7) `git status`; if NO changes:
   - Output:
     - `PR: <existing or computed PR url>`
     - `Additions this session: none`
   - Update `~/.claude/kb/state.json` with `last_processed_line` only.
   - Exit successfully.

8) If there ARE changes:
   - `git add -A rules/auto skills/auto commands/auto scripts .gitignore settings.json`
   - Read `session_id` from `~/.claude/kb/last_session_end.json`.
   - `git commit -m "kb: learnings <session_id>"`
   - `git push -u origin kb/auto`

9) Ensure/reuse PR from `kb/auto` → `master`:
   - Preferred (gh):
     - `pr_url=$(gh pr list --state open --head kb/auto --base master --json url -q '.[0].url')`
     - If empty: `gh pr create --base master --head kb/auto --title "KB auto updates" --body "Auto-updated rules/skills/commands from session learnings."`
   - Fallback (ONLY if `gh` is not available):
     - Parse `origin_url` into `owner` and `repo`.
     - Use `GITHUB_TOKEN` (or `GH_TOKEN`) for auth.
     - Check for existing PR via:
       - `GET /repos/{owner}/{repo}/pulls?state=open&head={owner}:kb/auto&base=master`
     - If none, create via:
       - `POST /repos/{owner}/{repo}/pulls` with `base=master`, `head=kb/auto`, title/body above.

10) Update `~/.claude/kb/state.json` with:
   - `last_processed_line` = total queue lines processed
   - `last_pushed_sha` = current HEAD sha
   - `pr_url`
   - `origin_url` (if known)

11) Final output (stdout) MUST be exactly:
PR: <url>
Additions this session:
<git diff --stat ...>
Files changed:
- <file1>
- <file2>
