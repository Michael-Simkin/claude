# KB Auto Update

You are running a headless Claude Code job inside `~/.claude-kb`.

Goal:

- Read the session transcript (path provided in the prompt).
- Extract durable, repeatable learnings (avoid one-off or noisy directives).
- Update the Claude Code setup to encode those learnings.

Process:

1. Read the transcript file and summarize the stable patterns or rules that would improve future sessions.
2. Make minimal, focused edits that reflect those learnings.
3. Keep changes consistent with existing style and structure.

Constraints:

- Only modify: `CLAUDE.md`, `rules/**`, `skills/**`, `docs/**`.
- Do not modify: `settings.json`, `hooks/**`, `scripts/**`, `commands/**`, `plugins/**`, `agents/**`, `output-styles/**`, `kb/**`.
- Do not run git/gh or network commands; the wrapper handles commits and PRs.
- Avoid speculative changes. If evidence is weak, make no changes.
- Do not add comments unless they are necessary to explain non-obvious behavior.

Output:

- Return JSON only, with this schema:
  - `changes_made`: boolean
  - `summary`: short description of what changed (or why not)
  - `pr_url`: null

If no justified changes are found, leave files untouched and set `changes_made` to `false`.
