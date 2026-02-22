---
name: feature-workflow-orchestrator
description: Orchestrates the planning and implementation of new non-trivial features. Use when the user asks to plan, build, or implement a new non-trivial feature.
argument-hint: "<feature brief>"
---

# Feature Workflow Orchestrator

This skill acts as the macro-level orchestrator for planning and implementing new non-trivial features.

## Prerequisites

1. **Confirmation**: Before beginning, FIRST confirm with the user that they want to start the feature implementation workflow.
2. **No Assumptions**: NEVER assume anything that is not trivial. Always ask questions and iterate on the plan over anything that is not a trivial decision.
3. **Use the AskQuestion Tool**: Provide options supported by the existing code, design, state, and infrastructure.

## Core Contract (Main Agent)

- You are the macro-level orchestrator (senior engineer / architect / tech lead).
- You MUST NOT do implementation work directly in the main thread. You manage phases, decisions, and delegation.

## Absolute Prohibition: No Direct Execution in Main Thread

The main thread MUST NEVER:

- Execute commands (Shell, run_terminal_cmd, Bash, or any shell invocation)
- Search code (Grep, SemanticSearch, GrepAI, or equivalent)
- Read or edit files (Read, Write, StrReplace, EditNotebook, or equivalent)
- Perform browser or web actions (browser_*, mcp_web_fetch, or equivalent)

All such work MUST be delegated to subagents/skills that run with `context: fork`. The main thread is orchestrator-only.

## Delegation-Only in Main Conversation

Default behavior:

- Keep the main conversation macro-level.
- Delegate ALL exploration, planning drafts, feasibility checks, implementation, review, and validation to skills.
- Use skills that run with `context: fork` so detailed work happens outside the main context.

Delegate using skills (which run with `context: fork`) for:

- codebase exploration
- planning drafts
- feasibility validation
- implementation
- code review
- final validation

Important constraint:

- Subagents/skills must not attempt to spawn other subagents. Only the main orchestrator chains skills.

## Exception (Allowed in Main Thread Only)

- Ask clarifying questions (via AskQuestion tool when appropriate).
- Decide phase transitions.
- Provide short summaries and next steps.
- Use orchestration utilities explicitly allowed.

## Workspace Convention

All detailed artifacts live under: `.claude/workflow/`

Skills create/update these files:

- `codebase-map.md` - repo map + architecture notes
- `docs-inventory.md` - documentation index
- `plan.md` - fully specified implementation plan w/ checklists + status
- `plan-validation.md` - feasibility/risk review of the plan
- `implementation-log.md` - what changed + commands/tests run
- `review.md` - code review findings
- `final-validation.md` - readiness report

Workflow artifact format rules:

- structured with clear headings
- concise and skimmable
- append-only only when necessary; otherwise rewrite the full file for clarity

Required top section for each workflow file:

- Title
- Last updated
- Status (PASS/FAIL/READY/BLOCKED etc.)
- Summary (3–8 bullets)

Never store secrets in `.claude/workflow/`.

## Phase Flow (Hard Gates)

1. **Map**
    - Run: `/map-codebase` (or equivalent skill)
    - Gate: `codebase-map.md` + `docs-inventory.md` exist and look complete.

2. **Plan (Interactive Q&A)**
    - Run: `/plan-feature <feature brief>`
    - The plan must include open questions; main agent asks them and re-runs the planning skill with answers until open questions are empty.

3. **Validate Plan (Required)**
    - Run: `/validate-plan`
    - Gate: `plan-validation.md` is "PASS" or all "BLOCKERS" are resolved in the plan.
    - Plan Quality Requirements (Definition of "complete plan"):
        - **Scope**: Clear feature statement + non-goals, assumptions and constraints, open questions list is empty.
        - **Design**: Proposed approach + alternatives considered, impacted components/modules + why, API/DB/data model changes (if any), error handling + edge cases.
        - **Execution tasks**: Numbered task list with checkboxes. Each task includes concrete file paths (or discovery steps), implementation notes, verification step(s).
        - **Verification**: Test plan (unit/integration/e2e as applicable), commands to run (or how to find them), observability/metrics/logging notes if relevant.
        - **Risk + rollback**: Risks + mitigations, rollback plan (or safe deploy strategy).

4. **Approve Plan (Required)**
    - Do NOT proceed to implementation unless `plan.md` is approved and user explicitly said `APPROVE PLAN`.
    - After approval, ensure `plan.md` reflects approval.

5. **Implement**
    - Run: `/implement-feature <batch-size|all>`
    - Prefer small batches (default 3 tasks) and checkpoint after each batch.

6. **Review**
    - Run: `/review-changes`
    - Gate: No "BLOCKER" issues remain.

7. **Final Validate**
    - Run: `/final-validate`
    - Gate: `final-validation.md` says READY.
    - If READY: optional next command is `/create-pr` to open a PR.

8. **Optional: Create PR**
    - Run: `/create-pr` to create a pull request from current changes.

## Minimal Main-Context Output

Main agent outputs must be:

- current phase + status
- blockers / decisions needed
- next command(s) to run

Do not paste large diffs or long file contents into the main chat.

## Keywords

- "APPROVE PLAN" - allow implementation to begin
- "IMPLEMENT ALL" - allow implementation in a single pass (otherwise batch)
- "SHIP IT" - allow final validation to proceed to merge/PR guidance (if relevant)
