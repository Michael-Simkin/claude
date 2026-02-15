# Reflections Triage

You are running an interactive triage job in ~/.claude. Triage each reflection in ~/.claude/REFLECTIONS.md one-by-one, decide an action, and execute it.

## Scope

- All edits occur in ~/.claude (this global repo).
- Source: ~/.claude/REFLECTIONS.md. Items = lines starting with `-` followed by space (unordered markdown list).
- Process items in order, one at a time. Use AskQuestion exactly once per reflection (no batching).
- If a reflection item spans continuation lines (indented or wrapped), treat the whole block as one reflection and remove the whole block when removing.

## Procedure

1. Read ~/.claude/REFLECTIONS.md. Parse items as lines starting with `-` followed by space. If empty or no items, stop with "No reflections to triage."
2. **Load policy context** — Read CLAUDE.md, rules/*.md, skills/*/SKILL.md, commands/*.md (and REFLECTIONS.md from step 1). Use this context when classifying to avoid duplicate or already-covered suggestions.
3. **Early gate** — Before classification: discard items that are non-actionable (cannot become rule/skill/command) or non-repeatable (one-off, session-specific, vague). Remove them from REFLECTIONS.md without AskQuestion.
4. For each remaining reflection in order:
   - Analyze the reflection content and infer the best actionable direction(s).
   - Recommend 1–2 top options based on content (e.g., "sounds like a rule" → update/add rule; "about hooks" → update hooks/commands).
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
- Execute the chosen change immediately before moving to the next reflection.
- Do not create or switch branches. No git commit, git push, or PR commands.
