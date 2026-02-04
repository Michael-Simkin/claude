---
name: map-codebase
description: Map the repository structure, entry points, build/test tooling, and inventory all docs. Writes `.claude/workflow/codebase-map.md` + `.claude/workflow/docs-inventory.md`.
argument-hint: "[optional: focus area or directory]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(find *), Bash(rg *), Bash(git *), Write
---

You are mapping an existing codebase for a senior engineer who will plan and implement a feature.
Do NOT modify source code. Only write/overwrite files under `.claude/workflow/`.

## Goals

1) Produce a stable, high-signal codebase map.
2) Inventory documentation and point to the most relevant docs for future work.
3) Capture repo standards: formatting/linting/testing/build commands.

## Steps

1) Identify repository type(s)

- Detect primary languages/frameworks (package manifests, build files).
- Identify runtime entry points, services, apps, packages, and shared libs.

1) Create `docs-inventory.md`

- List docs files and what they cover (README, docs/, ADRs, RFCs, architecture, runbooks).
- Include paths and 1–2 line summaries.

1) Create `codebase-map.md`
Include:

- High-level architecture (components and responsibilities)
- Directory map (top-level + key subdirs)
- Key modules/files (entry points, routing/controllers, core domain, infra, data access)
- Data flow (where requests/events enter, how they propagate, where persistence happens)
- Cross-cutting concerns (auth, permissions, config, logging, metrics)
- Build/lint/test commands (from scripts/config/README)
- Standards/conventions observed (naming, patterns, error handling)

1) Output a short summary

- What you learned (5–10 bullets)
- Top 5 “files to read first” for feature work
- Any missing docs or suspicious gaps

## Deliverables (write these files)

- `.claude/workflow/docs-inventory.md`
- `.claude/workflow/codebase-map.md`

## Response format (to orchestrator)

- Updated files list
- 5–10 bullet summary
- Recommended next command: `/plan-feature <feature brief>`
