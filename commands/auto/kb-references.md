# KB References (Concepts Only)

## BayramAnnakov/claude-reflect
- Two-stage flow: automatic capture into a queue, manual/controlled apply step.
- Hybrid detection (regex + semantic) to reduce false positives.
- Deduplication and skill-targeted updates to keep memory clean.

## haddock-development/claude-reflect-system
- Confidence tiers (high/medium/low) to gate what becomes durable rules.
- Safe updates with backups and explicit review/rollback paths.
- Git-backed learning history to keep changes auditable.

## jainabhishek/reflect-skill
- Clear “learning loop” framing: correct → extract → persist → reload.
- Explicit separation between model memory and file-based instructions.
- Auto vs manual reflection modes for safety.

## thedotmack/claude-mem
- Lifecycle hooks to capture and persist context automatically.
- Separation of capture, storage, and retrieval with progressive disclosure.
- Keep data local and provide structured access paths (IDs/queries).

## affaan-m/everything-claude-code
- Organized layout of rules/skills/commands with clear install boundaries.
- Continuous-learning patterns built around hooks + scripts.
- Minimal, explicit configuration for hooks to avoid ambiguity.

## wshobson/commands
- Consistent command naming and directory-based organization.
- Workflow vs tool split for multi-step vs focused tasks.
- Clear invocation patterns and argument handling.

## karanb192/claude-code-hooks
- Event logger utility to inspect raw hook payloads before automation.
- Small, single-purpose hooks with explicit safety scopes.
- Documented matcher + command patterns for maintainability.
