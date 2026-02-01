#!/usr/bin/env python3
import datetime as dt
import fcntl
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


def run(cmd, cwd=None, env=None, check=True):
    result = subprocess.run(
        cmd,
        cwd=cwd,
        env=env,
        text=True,
        capture_output=True,
    )
    if check and result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {' '.join(cmd)}\n"
            f"stdout: {result.stdout}\n"
            f"stderr: {result.stderr}"
        )
    return result


def build_env():
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    env["GH_PROMPT_DISABLED"] = "1"
    return env


def write_last_pr(state_dir, message):
    state_dir.mkdir(parents=True, exist_ok=True)
    (state_dir / "last_pr.txt").write_text(message.strip() + "\n")


def get_origin_url(source_repo, env):
    result = run(["git", "-C", str(source_repo), "remote", "get-url", "origin"], env=env)
    return result.stdout.strip()


def get_default_branch(repo, env):
    result = run(
        ["git", "-C", str(repo), "symbolic-ref", "refs/remotes/origin/HEAD"],
        env=env,
        check=False,
    )
    if result.returncode == 0:
        ref = result.stdout.strip()
        if ref.startswith("refs/remotes/origin/"):
            return ref.split("/", 3)[3]
    return "main"


def ensure_kb_repo(source_repo, kb_repo, env):
    if (kb_repo / ".git").exists():
        return
    origin_url = get_origin_url(source_repo, env)
    if kb_repo.exists():
        shutil.rmtree(kb_repo)
    kb_repo.parent.mkdir(parents=True, exist_ok=True)
    run(["git", "clone", origin_url, str(kb_repo)], env=env)


def ensure_clean(repo, env):
    result = run(["git", "-C", str(repo), "status", "--porcelain"], env=env)
    return result.stdout.strip() == ""


def ensure_kb_branch(repo, default_branch, env):
    run(["git", "-C", str(repo), "fetch", "origin", "--prune"], env=env)
    local_branch = run(
        ["git", "-C", str(repo), "show-ref", "--verify", "--quiet", "refs/heads/kb/auto"],
        env=env,
        check=False,
    )
    remote_branch = run(
        ["git", "-C", str(repo), "show-ref", "--verify", "--quiet", "refs/remotes/origin/kb/auto"],
        env=env,
        check=False,
    )

    if local_branch.returncode != 0:
        if remote_branch.returncode == 0:
            run(["git", "-C", str(repo), "checkout", "-b", "kb/auto", "origin/kb/auto"], env=env)
        else:
            run(
                ["git", "-C", str(repo), "checkout", "-b", "kb/auto", f"origin/{default_branch}"],
                env=env,
            )
    else:
        run(["git", "-C", str(repo), "checkout", "kb/auto"], env=env)

    if remote_branch.returncode == 0:
        run(["git", "-C", str(repo), "pull", "--ff-only", "origin", "kb/auto"], env=env, check=False)


def sanitize_session_id(session_id):
    if not session_id:
        return "unknown"
    return re.sub(r"[^a-zA-Z0-9._-]+", "_", session_id)[:80]


def copy_transcript(transcript_path, dest_dir, session_id):
    dest_dir.mkdir(parents=True, exist_ok=True)
    safe_id = sanitize_session_id(session_id)
    dest_path = dest_dir / f"{safe_id}.jsonl"
    shutil.copy2(transcript_path, dest_path)
    return dest_path


def collect_text(obj, parts):
    if isinstance(obj, dict):
        if isinstance(obj.get("text"), str):
            parts.append(obj["text"])
        for value in obj.values():
            collect_text(value, parts)
    elif isinstance(obj, list):
        for item in obj:
            collect_text(item, parts)


def extract_response_json(raw_output):
    try:
        top = json.loads(raw_output)
    except json.JSONDecodeError:
        return None

    parts = []
    collect_text(top, parts)
    if not parts:
        return None
    text = "\n".join(parts).strip()
    if not text:
        return None
    candidate = text
    if not candidate.startswith("{"):
        start = candidate.find("{")
        end = candidate.rfind("}")
        if start == -1 or end == -1 or end <= start:
            return None
        candidate = candidate[start : end + 1].strip()
    try:
        return json.loads(candidate)
    except json.JSONDecodeError:
        return None


def gh_pr_url(repo, base_branch, env):
    result = run(
        [
            "gh",
            "pr",
            "list",
            "--head",
            "kb/auto",
            "--base",
            base_branch,
            "--json",
            "url",
            "--jq",
            ".[0].url",
        ],
        cwd=repo,
        env=env,
        check=False,
    )
    url = result.stdout.strip()
    return url if url else None


def extract_url(text):
    match = re.search(r"https?://\\S+", text)
    return match.group(0) if match else None


def main():
    if os.environ.get("CLAUDE_KB_RUN"):
        return 0

    payload = sys.stdin.read().strip()
    try:
        data = json.loads(payload) if payload else {}
    except json.JSONDecodeError:
        data = {}

    session_id = data.get("session_id", "unknown")
    transcript_path = data.get("transcript_path")

    home = Path.home()
    source_repo = home / ".claude"
    kb_repo = home / ".claude-kb"
    state_dir = kb_repo / "kb"
    transcripts_dir = state_dir / "transcripts"

    env = build_env()

    if not transcript_path:
        write_last_pr(state_dir, "KB run skipped: missing transcript_path")
        return 0

    transcript_path = Path(transcript_path)
    if not transcript_path.exists():
        write_last_pr(state_dir, f"KB run skipped: transcript not found ({transcript_path})")
        return 0

    state_dir.mkdir(parents=True, exist_ok=True)
    lock_path = state_dir / "run.lock"
    lock_file = lock_path.open("w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return 0

    lock_file.write(f"{os.getpid()}\n")
    lock_file.flush()

    if shutil.which("claude") is None:
        write_last_pr(state_dir, "KB run failed: claude CLI not found")
        return 0

    try:
        ensure_kb_repo(source_repo, kb_repo, env)
    except Exception as exc:
        write_last_pr(state_dir, f"KB run failed: clone error ({exc})")
        return 0

    if not (kb_repo / ".git").exists():
        write_last_pr(state_dir, f"KB run failed: {kb_repo} is not a git repo")
        return 0

    if not ensure_clean(kb_repo, env):
        write_last_pr(state_dir, f"KB run skipped: dirty working tree in {kb_repo}")
        return 0

    default_branch = get_default_branch(kb_repo, env)
    try:
        ensure_kb_branch(kb_repo, default_branch, env)
    except Exception as exc:
        write_last_pr(state_dir, f"KB run failed: branch setup error ({exc})")
        return 0

    transcript_copy = copy_transcript(transcript_path, transcripts_dir, session_id)

    prompt = (
        "Run the KB auto-update.\\n"
        f"Session ID: {session_id}\\n"
        f"Transcript: {transcript_copy}\\n"
        "Follow the kb-auto instructions and output JSON only."
    )

    claude_env = env.copy()
    claude_env["CLAUDE_KB_RUN"] = "1"

    claude_cmd = [
        "claude",
        "-p",
        "--dangerously-skip-permissions",
        "--output-format",
        "json",
        "--max-turns",
        "64",
        "--append-system-prompt-file",
        str(kb_repo / "commands" / "kb-auto.md"),
        prompt,
    ]

    claude_result = run(claude_cmd, cwd=kb_repo, env=claude_env, check=False)
    output_path = state_dir / "last_claude_output.json"
    output_path.write_text(claude_result.stdout or "")

    response_json = extract_response_json(claude_result.stdout or "")
    summary = None
    if isinstance(response_json, dict):
        summary = response_json.get("summary")

    status = run(["git", "-C", str(kb_repo), "status", "--porcelain"], env=env)
    if status.stdout.strip() == "":
        timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        note = f"No changes from KB run at {timestamp}."
        if summary:
            note = f"{note} Summary: {summary}"
        write_last_pr(state_dir, note)
        return 0

    run(["git", "-C", str(kb_repo), "add", "-A"], env=env)

    commit_title = f"kb: auto updates from session {session_id}"
    commit_result = run(
        ["git", "-C", str(kb_repo), "commit", "-m", commit_title],
        env=env,
        check=False,
    )
    if commit_result.returncode != 0:
        err = commit_result.stderr.strip() or commit_result.stdout.strip()
        write_last_pr(state_dir, f"KB run failed: commit error ({err})")
        return 0

    push_result = run(["git", "-C", str(kb_repo), "push", "-u", "origin", "kb/auto"], env=env, check=False)
    if push_result.returncode != 0:
        write_last_pr(state_dir, f"KB run failed: push error ({push_result.stderr.strip()})")
        return 0

    if shutil.which("gh") is None:
        write_last_pr(state_dir, "KB run complete: branch pushed, gh not found")
        return 0

    pr_url = gh_pr_url(kb_repo, default_branch, env)
    if not pr_url:
        summary_line = summary or "Automated config updates from session transcript."
        body = (
            "## Summary\\n"
            f"- {summary_line}\\n"
            f"- Session: {session_id}\\n\\n"
            "## Test plan\\n"
            "- Not run (automated update)\\n"
        )
        title = f"KB: auto update from session {session_id}"
        create_result = run(
            [
                "gh",
                "pr",
                "create",
                "--head",
                "kb/auto",
                "--base",
                default_branch,
                "--title",
                title,
                "--body",
                body,
            ],
            cwd=kb_repo,
            env=env,
            check=False,
        )
        pr_url = extract_url(create_result.stdout) or gh_pr_url(kb_repo, default_branch, env)

    if pr_url:
        write_last_pr(state_dir, pr_url)
    else:
        write_last_pr(state_dir, "KB run complete: branch pushed, PR not created")

    return 0


if __name__ == "__main__":
    sys.exit(main())
