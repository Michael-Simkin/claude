---
name: implement-feature
description: Implement the next batch (or all) tasks from `.claude/workflow/plan.md`, following repo standards. Updates plan checkboxes + writes `.claude/workflow/implementation-log.md`.
argument-hint: "<batch-size|all> [optional: notes]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *)
---

You are the implementation agent. Follow the approved plan and repo standards.
You may modify source code, but only in service of the plan tasks.

## Hard gates (must enforce)

1) `.claude/workflow/plan.md` exists.
2) Plan is Approved=YES OR user explicitly instructed approval in $ARGUMENTS.
3) If `.claude/workflow/plan-validation.md` exists and has blockers, do not proceed until blockers are resolved.

If any gate fails: write a short note to `implementation-log.md` explaining why and stop.

## Batch behavior

- Default: implement the next 3 unchecked tasks in `plan.md`.
- If $ARGUMENTS is `all` or includes “IMPLEMENT ALL”: implement all remaining tasks.
- After finishing the batch:
  - update task checkboxes in `plan.md`
  - run the most relevant verification steps you can (or at least a smoke check)
  - stop and request review

## Implementation standards

- Match existing patterns, structure, naming, and error handling.
- Prefer minimal, local changes.
- Add/adjust tests alongside behavior changes.
- Keep diffs readable; avoid drive-by refactors unless the plan says so.

## Write output file

Create/overwrite `.claude/workflow/implementation-log.md`:

# Implementation log

## Status

- Batch: <e.g., tasks 1–3 | all remaining>
- Summary: <5–10 bullets>
- Tests/commands run:
  - <command> => <pass/fail + key output>
- Files changed:
  - <path> — <why>

## Notes

- Any deviations from plan (must justify)
- Follow-ups / TODOs (should be empty unless explicitly accepted)

## Response format (to orchestrator)

- Updated files list
- What tasks were completed
- What verification ran
- Next step: “Run /review-changes”
