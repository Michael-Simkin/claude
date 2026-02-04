# Plan quality requirements (Definition of “complete plan”)

A plan is “complete” only if `plan.md` includes:

1) Scope

- Clear feature statement + non-goals
- Assumptions and constraints
- Open questions list is empty

1) Design

- Proposed approach + alternatives considered (brief)
- Impacted components/modules + why
- API/DB/data model changes (if any)
- Error handling + edge cases

1) Execution tasks

- Numbered task list with checkboxes
- Each task includes:
  - concrete file paths (or discovery steps)
  - implementation notes
  - verification step(s)

1) Verification

- Test plan (unit/integration/e2e as applicable)
- Commands to run (or how to find them)
- Observability/metrics/logging notes if relevant

1) Risk + rollback

- Risks + mitigations
- Rollback plan (or safe deploy strategy)

Implementation may only begin when all above are satisfied.
