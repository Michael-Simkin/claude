---
name: review-changes
description: Review current working tree changes against plan + repo standards. Writes `.claude/workflow/review.md`.
argument-hint: "[optional: focus areas]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash(git *), Write
---

Git context:

- Branch: !`git branch --show-current`
- Status: !`git status --porcelain`
- Diff (unstaged): !`git diff`
- Diff (staged): !`git diff --staged`

You are a senior code reviewer. Do NOT change source code; only write the review file.

## What to check

- Plan compliance: are tasks implemented as intended? any missing steps?
- Correctness: logic, edge cases, error handling, data validation
- Security: authz/authn, injection risks, secrets, unsafe deserialization, etc.
- Performance: obvious inefficiencies/regressions
- Quality: readability, maintainability, consistency with repo patterns
- Tests: coverage, failure modes, determinism
- DX: docs/typing/contract clarity where relevant

## Write output file

Create/overwrite `.claude/workflow/review.md`:

# Code review

## Status

- Result: <PASS | NEEDS FIXES>
- Summary: <3–8 bullets>

## Blockers

- BLOCKER: ...

## Important (non-blocking)

- ...

## Nits / polish

- ...

## Plan alignment

- Tasks completed vs plan:
  - <task> => <ok/missing>

## Response format (to orchestrator)

- Updated files list
- PASS/NEEDS FIXES
- If NEEDS FIXES: list BLOCKERS (bullets) and say “Run /implement-feature <batch-size> to address, then rerun /review-changes”
- If PASS: say “Run /final-validate”
