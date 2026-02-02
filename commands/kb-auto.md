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
- Keep the working tree on `main`.
- Never commit or push.

## Process

1. Read the transcript file and summarize the stable patterns or rules that would improve future sessions.
2. Make minimal, focused edits that reflect those learnings.
3. Keep changes consistent with existing style and structure.

## Allowed changes

- You may modify only: `CLAUDE.md`, `rules/**`, `skills/**`, `docs/**`.
- You may write runtime artifacts under `kb/**`, but do not commit them.
- Do not modify: `settings.json`, `hooks/**`, `scripts/**`, `commands/**`, `plugins/**`, `agents/**`, `output-styles/**`.
- Do not add comments unless they are necessary to explain non-obvious behavior.
- Do not create or switch to branches other than `main`.
- Do not run `git commit`, `git push`, or any PR-related commands (`gh pr ...`).

## Procedure

1. **Assume repo exists** at `~/.claude-kb`.
   - If `~/.claude-kb/.git` does not exist, stop with a short note.
2. **Stay on `main` and stay current**:
   - `git -C ~/.claude-kb checkout main`
   - `git -C ~/.claude-kb fetch origin --prune`
   - If the working tree is clean, `git -C ~/.claude-kb pull --ff-only origin main`.
   - If the working tree is dirty, use a temporary stash to fast-forward:
     - `git -C ~/.claude-kb stash push -u -m "kb-auto"`
     - `git -C ~/.claude-kb pull --ff-only origin main`
     - `git -C ~/.claude-kb stash pop`
   - If any step fails or causes conflicts, stop without changes.
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
   - Leave changes as uncommitted modifications on `main`.

## Output

- End with a short plaintext summary of additions made (or "No changes").
