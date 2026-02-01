#!/usr/bin/env bash
set -euo pipefail

# Purpose: persist SessionEnd JSON and trigger the headless KB updater.
# Why: updates versioned rules/skills/commands in the isolated clone only.
kb_dir="/Users/michaelsi/.claude/kb"
repo_dir="${kb_dir}/repo"
state_file="${kb_dir}/state.json"
end_file="${kb_dir}/last_session_end.json"
headless_settings="${kb_dir}/headless.settings.json"

mkdir -p "${kb_dir}"
cat > "${end_file}"

if [ ! -f "${state_file}" ]; then
  printf '{\n  "last_processed_line": 0\n}\n' > "${state_file}"
fi

if [ ! -f "${headless_settings}" ]; then
  printf '{"disableAllHooks": true}\n' > "${headless_settings}"
fi

origin_url="$(git -C "/Users/michaelsi/.claude" remote get-url origin)"

if [ ! -d "${repo_dir}/.git" ]; then
  git clone "${origin_url}" "${repo_dir}"
fi

KB_ORIGIN_URL="${origin_url}" python - <<'PY'
import json
import os

state_file = os.path.expanduser("~/.claude/kb/state.json")
origin_url = os.environ.get("KB_ORIGIN_URL")
data = {}

if os.path.exists(state_file):
    with open(state_file, "r") as f:
        try:
            data = json.load(f) or {}
        except json.JSONDecodeError:
            data = {}

if "last_processed_line" not in data:
    data["last_processed_line"] = 0
if origin_url:
    data["origin_url"] = origin_url

with open(state_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

spawn_output="$(
  cd "${repo_dir}" \
    && claude -p "Process KB session-end updates." \
      --settings "${headless_settings}" \
      --add-dir "${kb_dir}" \
      --append-system-prompt-file "${repo_dir}/commands/auto/kb-session-end.md"
)"

if [[ "${spawn_output}" == *"Additions this session: none"* ]]; then
  exit 0
fi

printf "%s\n" "${spawn_output}" >&2
exit 2
