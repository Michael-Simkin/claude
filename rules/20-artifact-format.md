# Workflow artifact format rules

All `.claude/workflow/*.md` files must be:

- structured with clear headings
- concise and skimmable
- append-only only when necessary; otherwise rewrite the full file for clarity

Required top section for each workflow file:

- Title
- Last updated (date/time optional)
- Status (PASS/FAIL/READY/BLOCKED etc.)
- Summary (3–8 bullets)

Never store secrets in `.claude/workflow/`.
