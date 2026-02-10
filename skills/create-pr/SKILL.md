---
name: create-pr
description: Creates a PR from current changes, matching the target repo's actual PR conventions discovered via template and PR history.
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash, Write
scope: GitHub only
---

# Create PR

Creates a pull request for GitHub repos. Uses discovered templates and conventions.

## Preflight

- Run `gh auth status`; if `gh` is unavailable or unauthenticated, stop and report. Do not proceed.

## Steps

### 1. Discover PR conventions (mandatory before creating)

Run these in parallel:

a) **PR template**: Check (in order) `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md`, `pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/pull_request_template.md`. Read the template if found.

b) **Supplemental**: Skim `CONTRIBUTING.md`, `CONTRIBUTING.rst`, or `docs/CONTRIBUTING.md` for PR/convention hints.

c) **Recent PR examples**: Run `gh pr list --state merged --limit 5 --json number,title,body,labels` to get the last 5 merged PRs. Examine their body format, sections, and metadata patterns.

d) **From (a), (b), and (c)**, determine:

- Required sections (summary, description, screenshots, etc.)
- Whether a work-item link is required (Monday.com, Jira, Linear, GitHub issue, etc.)
- Naming conventions for PR titles
- Label conventions

### 2. Work-item link check

Require a work-item link if: (i) the PR template explicitly requires one, or (ii) a strong pattern exists in recent PRs (≥3 of last 5 merged PRs include work-item links: Monday.com URLs, Jira `PROJ-123`, Linear issues, GitHub `#123`).

- If required: **stop and ask the user** for the link before proceeding. Do not guess or skip.
- If neither condition holds, skip this step.

### 3. Verify there are changes to PR

- Run `git status` and `git diff` to confirm there are changes.
- If no changes exist, stop and report.

### 4. Branch management

- Detect default branch: `gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'` (fallback: `main` or `master` if `gh` fails).
- If on the default branch, create a descriptive feature branch and switch to it.
- If already on a feature branch, use it.

### 5. Commit changes

- Stage and commit with a message that follows the repo's commit conventions (check recent `git log --oneline -10` for style).

### 6. Create the PR

- Push the branch: `git push -u origin HEAD`
- Create the PR with `gh pr create`

**PR body rules:**

- **If a PR template was found**: Follow its structure exactly. Fill in each section concisely. Leave optional sections empty or remove them if not applicable.
- **If recent PRs show a consistent format but no template exists**: Match that format.
- **Fallback (no template, no consistent format)**: One short paragraph summarizing what changed and why. No extra sections (test plan, checklist, deployment, screenshots). Minimal is correct.

For the PR title: match the naming convention from recent PRs (e.g., `feat: ...`, `fix: ...`, `[PROJ-123] ...`, or plain English).

### 7. Report

Return:

- PR URL
- 1-2 sentence summary of what was created

## Rules

- NEVER pad the PR with boilerplate sections that aren't in the repo's conventions.
- NEVER invent a "Test Plan", "Screenshots", "Checklist", or "Deployment" section unless the template or PR history shows one.
- When in doubt about format, lean minimal. One clear paragraph beats five empty sections.
- Stop and report if `gh` is unavailable or auth is missing.
