---
name: monsoon
description: The recurring workflow entry point. Reads the project's static config (.claude/project.md) plus live git/repo state, decides the next sensible action, and delegates to the right skill (check, release-note, clean-branches, session-learn); commits via the built-in harness behavior, not a skill. Proposes irreversible steps before acting; runs read-only steps automatically. Use to advance the workflow in a repo set up by squall.
---

# monsoon

The recurring router. Not a fixed pipeline — it inspects state and picks the next step, delegating to existing skills. Always report what was chosen and why.

## Inputs
- `.claude/project.md` (static config). If missing: suggest `petrichor` (plan) for an empty repo, or `squall` (init) for one that already has code.
- Live state: `git status`, current branch, `git tag`, unpushed commits, branches merged into the default branch.
- Optional hint: a gitignored `.claude/state.json` for cross-session goals — a hint only. If it conflicts with live git, live git wins.

## Decision (first match wins; propose, don't force)
1. No `.claude/project.md`: empty repo (no code) → suggest `petrichor` (plan it); has code → suggest `squall` (init).
2. Uncommitted changes → run `check` (default tier). If it passes, offer to commit using the built-in commit behavior (follow the CLAUDE.md Git rules); if it fails, summarize the failures and stop.
3. On a feature branch, everything committed, checks pass → offer to push / open a PR.
4. A version bump is present and `opt_in.release_note: on` → invoke `release-note`.
5. Branches merged into the default branch are piling up → suggest `clean-branches`.
6. On explicit request, or when nothing else is pending → offer `session-learn`.

## Behavior
- Read-only steps (check, inspecting state) run automatically.
- Outward or irreversible steps (commit, push, PR, branch deletion, release tagging) are proposed and run only on confirmation.
- Never start a dev server.
- State which branch and which conditions it observed, and which skill it is delegating to.

## Rules
- Don't keep mutable workflow state in committed files: use the in-session task list, or the gitignored `.claude/state.json` hint.
- monsoon only routes — defer to the dedicated skill for the actual work. Exception: committing has no dedicated skill; do it with the built-in harness behavior.
