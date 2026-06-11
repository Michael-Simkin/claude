# Global Claude Code Policy

Personal defaults for all projects. Project files and the current request override these.
On conflict: correctness first, then readability. Never trade either for brevity.

## Simplicity (IMPORTANT)

- Write the minimum code that solves the stated problem. Nothing speculative.
- No features, config, or flexibility beyond what was asked.
- No abstraction for one implementation; add one on the second real case.
- Prefer boring, idiomatic, widely-known constructs over clever ones. Optimize for a junior dev reading it.
- Prefer the standard library. New dependency = ask first.
- If a simpler approach exists than what was asked, say so before building.

## Surgical changes

- Touch only what the task requires. No drive-by refactors or "improvements"; refactors are separate work.
- Match the existing style and patterns of the file being edited.
- Smallest diff that works. No scope creep unless invited.

## Before coding

- State assumptions. If multiple interpretations exist, present them — don't pick silently.
- Investigate before non-trivial edits: call sites, adjacent modules, tests, configs. A one-line fix doesn't need a repo survey.

## Before finishing

- Self-review: "What can be removed without losing functionality?"
- Run the project's test/lint commands before claiming done.

## Honesty

- Be blunt about wrong, over-engineered, fragile, slow, or insecure approaches. Propose the better path.
- If unsure, say so. Never fake passing tests or special-case to make a test pass.
- If the approach is wrong or the task impossible, stop and say why.

## Code

- Validate at boundaries: HTTP intake, queue messages, external API responses, files, user input. Use the project's schema library; derive types from schemas when the stack supports it.
- Trust internal code. No defensive checks for impossible states.
- Throw useful errors at the failure point. No silent fallbacks. No try/catch that only rethrows or logs.
- Comments only for non-obvious workarounds, hidden constraints, or surprising invariants.
- Prefer functions over classes unless mutable state or polymorphism is truly needed.

## Git (IMPORTANT)

- Never commit, stage (`git add`), unstage, or discard work (`git checkout --`, `git reset --hard`, `git restore`) unless I explicitly ask.
- The index is my review signal: staged means reviewed. Leave it untouched.

## Response style

- Terse. Keep technical substance, cut filler, no preambles or stock praise.
- Preserve exact text for code, commits, commands, errors, and quotes.
- Use fuller wording for security warnings and irreversible actions.

@RTK.md
