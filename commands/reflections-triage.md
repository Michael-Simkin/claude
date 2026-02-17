# Reflections Triage

You are running an interactive triage job in ~/.claude. Triage each reflection in ~/.claude/REFLECTIONS.md one-by-one, decide an action, and execute it.

## Scope

- All edits occur in ~/.claude (this global repo).
- Source: ~/.claude/REFLECTIONS.md. Items = lines starting with `-` followed by space (unordered markdown list).
- Process items in order, one at a time. Use AskQuestion exactly once per reflection (no batching).
- If a reflection item spans continuation lines (indented or wrapped), treat the whole block as one reflection and remove the whole block when removing.

## Objective

- Convert raw reflections into durable policy improvements with minimal ambiguity.
- Prefer concrete updates over passive backlog accumulation.
- Keep only reflections that are reusable, specific, and implementable.

## Decision rubric

Evaluate each reflection in this order:

1. **Is it still valid?**
   - If stale, contradicted, or context-dependent, discard.
2. **Is it actionable and repeatable?**
   - Must be implementable and likely to recur in future sessions.
3. **Is it already covered by existing policy?**
   - If fully covered, discard.
   - If partially covered, prefer updating the existing rule/skill/command.
4. **Where does it best belong?**
   - Rule, skill, CLAUDE policy, or automation command/hook.

## Action mapping guidance

- **Update existing rule** when intent already exists but needs tighter wording, added constraints, or clearer examples.
- **Add new rule** when behavior is durable and not represented in any existing rule file.
- **Update existing skill** when the reflection changes a repeatable multi-step workflow already described by a skill.
- **Add new skill** when the reflection requires a new reusable workflow with explicit steps.
- **Update CLAUDE.md policy** when the reflection changes global behavior expectations across sessions.
- **Update hooks/commands automation** when the reflection indicates prompt/automation flow changes (for example, extraction gates, triage flow, hook wiring).
- **Keep for later** only when likely useful but currently underspecified.
- **Discard** when non-actionable, non-repeatable, duplicate, stale, or too vague.

## Worked examples

- Reflection: "Before editing, inspect hook + command files together for end-to-end behavior."
  - Likely action: **Update existing rule** or **Update hooks/commands automation**.
  - Why: concrete, repeatable, automation-focused.

- Reflection: "I used macOS in this session."
  - Likely action: **Discard**.
  - Why: one-off environmental fact, no durable behavior.

- Reflection: "When extracting reflections, compare against CLAUDE.md/rules/skills/commands first."
  - Likely action: **Update hooks/commands automation**.
  - Why: direct instruction about extraction workflow behavior.

- Reflection: "Be better at structure."
  - Likely action: **Discard** (or **Keep for later** only if user later provides concrete definition).
  - Why: vague and not implementable as-is.

## Logic example (internal)

```text
if not actionable_or_repeatable(reflection):
  discard
elif fully_covered_by_existing_policy(reflection):
  discard
elif partially_covered_by_existing_policy(reflection):
  update_existing_target(reflection)
else:
  select_best_new_target(reflection)  # rule, skill, CLAUDE.md, or hooks/commands
```

## Procedure

1. Read ~/.claude/REFLECTIONS.md. Parse items as lines starting with `-` followed by space. If empty or no items, stop with "No reflections to triage."
2. **Load policy context** — Read CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md (and REFLECTIONS.md from step 1). Use this context when classifying to avoid duplicate or already-covered suggestions.
3. **Early gate** — Before classification, discard items that are non-actionable (cannot become rule/skill/command), non-repeatable (one-off, session-specific, vague), stale, or fully duplicate. Remove discarded items from REFLECTIONS.md without AskQuestion.
4. For each remaining reflection in order:
   - Analyze the reflection using the Decision rubric and Action mapping guidance.
   - Recommend 1–2 top options based on content (e.g., "sounds like a rule" -> update/add rule; "about hooks" -> update hooks/commands).
   - Present options to the user using AskQuestion exactly once. Order options by relevance, best first:
     - Update existing rule
     - Add new rule
     - Update existing skill
     - Add new skill
     - Update CLAUDE.md policy
     - Update hooks/commands automation
     - Keep for later
     - Discard
   - Execute the chosen action directly in ~/.claude:
     - **Update existing rule/skill**: Edit the appropriate file in rules/ or skills/.
     - **Add new rule**: Create a new file in rules/.
     - **Add new skill**: Create a new directory + SKILL.md in skills/.
     - **Update CLAUDE.md**: Edit CLAUDE.md (rules, orchestrator, tooling, etc.).
     - **Update hooks/commands**: Edit files in hooks/ or commands/.
     - **Keep for later**: Do nothing; leave the item in ~/.claude/REFLECTIONS.md.
     - **Discard**: Remove the item only.
   - For Apply (any of the first six) or Discard: remove the processed reflection from ~/.claude/REFLECTIONS.md after completing the action.
   - For Keep for later: do not remove; move on.
5. After all items are processed, output a brief summary:
   - Counts by action (e.g., Updated rule: 2, Add new rule: 1, Discard: 1, Keep for later: 1).
   - Files changed (list).

## Constraints

- One AskQuestion per reflection. Never batch multiple reflections in one prompt.
- Recommend top options before showing the full list.
- Explain recommendation briefly using rubric terms (actionable, repeatable, covered/not covered).
- Execute the chosen change immediately before moving to the next reflection.
- Do not create or switch branches. No git commit, git push, or PR commands.
