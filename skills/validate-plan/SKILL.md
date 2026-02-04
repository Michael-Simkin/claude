---
name: validate-plan
description: Validate feasibility and logical soundness of `.claude/workflow/plan.md` against the actual codebase. Writes `.claude/workflow/plan-validation.md`.
argument-hint: "[optional: extra constraints or answers]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash(rg *), Bash(git *), Write
---

ultrathink

You are a plan validator. Do NOT modify source code.
Your output must be concrete and actionable.

## Inputs

- `.claude/workflow/plan.md` must exist.
- Optional: $ARGUMENTS for extra constraints.

## What to validate

1) Completeness (per rules: scope, tasks, verification, risks)
2) Feasibility

- Do referenced components/files exist?
- Are there obvious missing dependencies or required refactors?
- Are there hidden constraints in existing code patterns?

1) Correctness of approach

- Does it align with repo conventions?
- Are edge cases and error paths addressed?

1) Testability

- Are verification steps realistic for this repo?
- Are test locations/frameworks identified?

## Write output file

Create/overwrite `.claude/workflow/plan-validation.md`:

# Plan validation

## Status

- Result: <PASS | NEEDS CHANGES>
- Summary: <3–8 bullets>

## Blockers (must fix)

- BLOCKER: ...
(If none, write “None.”)

## Risks / gaps

- ...

## Suggested plan edits

- Exact changes to make in `plan.md` (what section, what to add/remove)

## Confidence

- High/Medium/Low + why (brief)

## Response format (to orchestrator)

- Updated files list
- PASS/NEEDS CHANGES
- If NEEDS CHANGES: list blockers (bullets) and say “Update plan then rerun /validate-plan”
- If PASS: say “Plan can be approved (await user APPROVE PLAN)”
