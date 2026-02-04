---
name: plan-feature
description: Draft or refine a complete implementation plan for a feature. Asks clarifying questions, writes `.claude/workflow/plan.md`.
argument-hint: "<feature brief> [optional: answers / constraints / APPROVED]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash(rg *), Bash(git *), Write
---

ultrathink

You are producing a *complete* plan that will be executed by implementation subagents.
Do NOT modify source code. Only write/overwrite `.claude/workflow/plan.md`.

Inputs:

- $ARGUMENTS contains the feature brief and any answers/constraints.
- If `.claude/workflow/codebase-map.md` exists, use it. Otherwise, quickly infer needed structure from the repo.

## Required behavior

1) If information is missing, produce a prioritized list of clarifying questions.
2) Do not mark the plan as complete until open questions are empty.
3) Break work into small tasks (checkboxes). Each task must include concrete file paths (or explicit discovery steps) and verification steps.

## Plan structure (write exactly this shape)

Write `.claude/workflow/plan.md` containing:

# Plan: <feature name>

## Status

- Planning: <IN PROGRESS | COMPLETE>
- Approved: <NO | YES>
- Last updated: <optional>

## Feature brief

(From $ARGUMENTS)

## Scope

- Goals
- Non-goals

## Assumptions / constraints

(bullets)

## Open questions (must be empty to complete planning)

- [ ] Q1 ...
- [ ] Q2 ...
(If none, write: “None.”)

## Proposed approach

- High-level design
- Alternatives considered (brief)
- Impacted components/files (best guess + pointers)

## Implementation tasks

1. [ ] Task 1 — <short name>
   - Files: <paths or discovery steps>
   - Steps: <bullets>
   - Verification: <tests/commands/checks>
2. [ ] Task 2 ...
(Keep tasks small; prefer 2–10 tasks depending on feature size.)

## Verification checklist (Definition of Done)

- [ ] Relevant unit tests added/updated
- [ ] Integration/e2e tests (if applicable)
- [ ] Lint/format passes
- [ ] No TODOs / debug logs left behind
- [ ] Docs updated (if needed)
- [ ] Observability/metrics/logging updated (if applicable)

## Risk & rollback

- Risks + mitigations
- Rollback strategy

## Approval

- To begin implementation, user must say exactly: APPROVE PLAN
- Approved: <NO | YES>
- Approval notes: <optional>

## Output to orchestrator

After writing `plan.md`, respond with:

- Updated files list
- Remaining open questions (if any)
- If zero open questions: say “Plan ready for validation: run /validate-plan”
- If $ARGUMENTS indicates approval (e.g., includes “APPROVED”): set Approved=YES and say “Implementation allowed: run /implement-feature”
