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
- Append only learnings that are actionable and repeatable — not vague or session-specific.
- Append learnings to REFLECTIONS.md as unordered markdown list items (`- learning`), one per line, append-only.

## Constraints

- Append only to REFLECTIONS.md. Do not modify CLAUDE.md, rules/**, skills/**, docs/**, settings.json, hooks/**, scripts/**, commands/**, plugins/**, agents/**, or output-styles/**.
- Each learning as a markdown unordered list item (`- learning`). One item per line. Append-only. No multi-line entries.
- Do not create or switch branches. Do not run `git commit`, `git push`, or any PR commands.

## Transcript format

- `transcript_path` points to a **JSONL** file (one JSON object per line).
- Each line is a message or turn in the session.

## Extraction criteria

**Include** only if ALL of the following hold:

- **Explicit** — user preference, correction, or constraint stated clearly; or **repeated friction** (same issue appears 2+ times in transcript).
- **Actionable** — could reasonably become a rule, skill, or command (concrete, implementable).
- **Repeatable** — applies to 2+ future sessions, not tied to a single project or context.
- **Non-duplicate** — not already covered by CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md, or REFLECTIONS.md.

**Exclude**:

- One-off session facts (file paths, project names, one-time decisions).
- Vague or speculative guidance ("maybe consider X").
- Already-obvious conventions or generic best practices.
- Ephemeral chat, jokes, or context that won't generalize.
- Items that duplicate existing policy or REFLECTIONS content.
- Session-specific requests that won't recur.

**Output format**: Each learning as a markdown unordered list item (`- learning`). One item per line. Short, concrete, reusable. No multi-line entries.

## Procedure

1. **Read context** — CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md, REFLECTIONS.md.
2. **Read transcript** from `transcript_path` (JSONL).
3. **Filter candidates** — extract candidates using criteria above; drop any that fail Include or match Exclude; drop duplicates of existing context.
4. **If no learnings**: stop.
5. **Append to REFLECTIONS.md** — each learning as `- learning`, one per line, append-only. Create file if it does not exist.

## Output

- End with a short plaintext summary of how many learnings were appended (or "No learnings extracted").
