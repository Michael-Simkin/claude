#!/usr/bin/env bash
set -euo pipefail

# Purpose: enforce pull-only behavior on the main ~/.claude repo at session start.
# Why: the runtime config must only advance via fast-forward pulls.
cd "/Users/michaelsi/.claude"
git checkout master >/dev/null 2>&1 || true
git pull --ff-only origin master
