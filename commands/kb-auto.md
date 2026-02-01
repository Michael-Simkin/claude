# KB Auto Update

You are running a headless Claude Code job. Your job is to fully manage the KB update workflow.

Input:

- The prompt includes **Hook input JSON**. Parse it and extract:
  - `session_id`
  - `transcript_path`

If `transcript_path` is missing or the file doesn't exist, stop with a short note and do not create/update a PR.

## Goals

- Read the session transcript.
- Extract durable, repeatable learnings (avoid one-off or noisy directives).
- Update the Claude Code setup to encode those learnings.
- Commit, push, and create/update a PR on `kb/auto`.
- Keep the PR **body** as the human-readable summary for the next session start.

## Process

1. Read the transcript file and summarize the stable patterns or rules that would improve future sessions.
2. Make minimal, focused edits that reflect those learnings.
3. Keep changes consistent with existing style and structure.

## Allowed changes

- You may modify only: `CLAUDE.md`, `rules/**`, `skills/**`, `docs/**`.
- You may write runtime artifacts under `kb/**`, but do not commit them.
- Do not modify: `settings.json`, `hooks/**`, `scripts/**`, `commands/**`, `plugins/**`, `agents/**`, `output-styles/**`.
- Do not add comments unless they are necessary to explain non-obvious behavior.

## Procedure

1. **Assume repo exists** at `~/.claude-kb`.
   - If `~/.claude-kb/.git` does not exist, stop with a short note.
2. **Prepare `kb/auto`**:
   - `git -C ~/.claude-kb fetch origin --prune`.
   - If `origin/kb/auto` exists, checkout `kb/auto` and pull.
   - Else create `kb/auto` from `origin/main`.
   - Ensure `origin/main` is an ancestor of `kb/auto`:
     - Check: `git -C ~/.claude-kb merge-base --is-ancestor origin/main HEAD`
     - If not, merge `origin/main` into `kb/auto` (fast-forward if possible).
   - Ensure clean working tree before edits; if dirty, stop without changes.
3. **Acquire lock**:
   - Create `~/.claude-kb/kb` if needed.
   - Use an atomic lock (e.g., `mkdir ~/.claude-kb/kb/run.lock`).
   - If the lock already exists, stop without changes.
   - Remove the lock when finished.
4. **Read transcript**:
   - Read the transcript directly from `transcript_path`.
5. **Analyze transcript** and decide on changes:
   - Prefer durable policies. Avoid speculative or one-off instructions.
   - Keep diffs small and consistent with existing conventions.
6. **If no changes**:
   - Do nothing and stop.
7. **If changes exist**:
   - `git -C ~/.claude-kb add -A`
   - `git -C ~/.claude-kb commit -m "kb: auto updates from session <session_id>"`
   - `git -C ~/.claude-kb push -u origin kb/auto`
   - Create or update the PR (`gh pr create` or `gh pr edit`).
8. **PR description** (required):
   - Keep it concise and human-readable (this is what SessionStart prints).
   - Format: short readable bullet points listing **additions** only.
   - Example template:

     ```markdown
     - Added: <short addition 1>
     - Added: <short addition 2>
     - Added: <short addition 3>
     ```

## Output

- End with a short plaintext summary and PR URL (if created/updated).
