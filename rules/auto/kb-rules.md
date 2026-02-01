# KB Auto-Updater Rules

- The runtime repo is `~/.claude` and must never be committed from; it stays on `master` and only fast-forward pulls.
- All versioned changes for this system happen in `~/.claude/kb/repo` on branch `kb/auto`.
- Only update `rules/auto/*`, `skills/auto/*`, `commands/auto/*`, `scripts/*`, plus `.gitignore`/`settings.json` when required for this system.
- Keep one open PR from `kb/auto` to `master`; keep pushing updates to the same branch.
