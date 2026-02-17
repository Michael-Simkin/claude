# KB Auto Update

You are running a headless Claude Code job. Your job is to append session learnings to REFLECTIONS.md.

Input:

- The prompt includes **Hook input JSON**. Parse it and extract:
  - `session_id`
  - `transcript_path`

If `transcript_path` is missing or the file doesn't exist, stop with a short note and do not update REFLECTIONS.md.

## Context (read before extraction)

**Required.** Read these files in full before extracting from the transcript. Use them to avoid duplicates and to ground learnings in existing policy:

- CLAUDE.md
- rules/*.md
- skills/*/SKILL.md
- commands/*.md
- REFLECTIONS.md

## Goals

- Extract durable, actionable learnings grounded in existing policy (rules, skills, commands, REFLECTIONS).
- Append only learnings that are actionable and repeatable, not vague or session-specific.
- Make each learning specific enough that it could be implemented as a rule, skill, or command with little or no rewriting.
- Append learnings to REFLECTIONS.md as unordered markdown list items (`- learning`), one per line, append-only.

## Non-goals

- Do not summarize the entire conversation.
- Do not preserve project-specific notes that are unlikely to recur.
- Do not restate generic best practices unless the transcript adds a concrete, durable preference or constraint.

## Constraints

- Append only to REFLECTIONS.md. Do not modify CLAUDE.md, rules/**, skills/**, docs/**, settings.json, hooks/**, scripts/**, commands/**, plugins/**, agents/**, or output-styles/**.
- Each learning as a markdown unordered list item (`- learning`). One item per line. Append-only. No multi-line entries.
- Do not create or switch branches. Do not run `git commit`, `git push`, or any PR commands.

## Transcript format

- `transcript_path` points to a **JSONL** file (one JSON object per line).
- Each line is a message or turn in the session.

## Quality gates (all must pass)

Use these gates in order. Reject the candidate immediately when any gate fails.

1. **Evidence gate**
   - Pass if the learning is either:
     - Explicit user preference, correction, or hard constraint, or
     - Repeated friction (same issue appears 2+ times in transcript).
2. **Specificity gate**
   - Pass only if the statement has a clear trigger and action.
   - Weak: "Be more careful with tests."
   - Strong: "When adding tests to a file that already uses AAA sections, keep Arrange/Act/Assert structure consistent with adjacent tests."
3. **Actionability gate**
   - Pass only if the learning could become a concrete rule, skill, or command update.
4. **Repeatability gate**
   - Pass only if it should apply to 2+ future sessions.
   - Reject one-off details tied to a specific path, ticket, branch, or temporary context.
5. **Novelty gate**
   - Pass only if not already covered by CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md, or REFLECTIONS.md.
6. **Formatting gate**
   - Pass only if it can be written as one concise markdown bullet in imperative style.

## Exclude list (always reject)

- One-off session facts (file paths, project names, one-time decisions).
- Vague or speculative guidance ("maybe consider X").
- Already-obvious conventions or generic best practices.
- Ephemeral chat, jokes, or context that won't generalize.
- Items that duplicate existing policy or REFLECTIONS content.
- Session-specific requests that won't recur.

## Candidate worksheet (internal only)

For each candidate, internally record:

- **Evidence**: short supporting quote or repeated pattern from transcript.
- **Trigger**: when this guidance should be applied.
- **Action**: what to do.
- **Why durable**: why it should recur.
- **Overlap check**: what existing rule/skill/command was checked and why this is not a duplicate.
- **Final line**: one-line bullet candidate.

Do not output the worksheet. Output only appended bullets and final summary.

## Logic example (internal)

```text
for candidate in extracted_candidates:
  if not passes_evidence_gate(candidate): reject
  elif not passes_specificity_gate(candidate): reject
  elif not passes_actionability_gate(candidate): reject
  elif not passes_repeatability_gate(candidate): reject
  elif not passes_novelty_gate(candidate, existing_policy): reject
  else: accept(normalize_to_single_line_bullet(candidate))
```

## Examples

### Good examples (accept)

- "Before changing automation behavior in ~/.claude, verify both hook scripts and command prompts so the end-to-end path is covered."
- "When a task requests strict output structure, include explicit include/exclude criteria and at least one positive and negative example in the prompt."
- "When a user asks to avoid subagents, execute the same workflow directly and keep verification steps equivalent."

### Bad examples (reject)

- "This project uses macOS."
- "Try to be better at coding."
- "Today we edited kb-auto.md."
- "Use a clearer approach maybe."

### Rewrite examples (weak -> strong)

- Weak: "Avoid duplicates."
- Strong: "Before appending a new reflection, compare it against CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md, and REFLECTIONS.md; skip if intent already exists."

- Weak: "Handle edge cases."
- Strong: "If transcript_path is missing or unreadable, stop without writing REFLECTIONS.md and output a short failure reason."

## Output format

Each learning must be a markdown unordered list item (`- learning`), one item per line, short, concrete, reusable, and single-line only.

## Procedure

1. **Read context** — CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md, REFLECTIONS.md.
2. **Read transcript** from `transcript_path` (JSONL).
3. **Extract candidates** — start from explicit directives and repeated friction points.
4. **Apply quality gates** — reject anything that fails any gate or matches the Exclude list.
5. **Normalize accepted lines** — rewrite to single-line imperative bullets with concrete trigger + action.
6. **Deduplicate accepted lines** — remove near-duplicates among accepted candidates and against REFLECTIONS.md.
7. **If no learnings**: stop.
8. **Append to REFLECTIONS.md** — each learning as `- learning`, one per line, append-only. Create file if it does not exist.

## Output

- End with a short plaintext summary of how many learnings were appended (or "No learnings extracted").
