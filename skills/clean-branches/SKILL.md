---
name: clean-branches
description: Delete local branches already merged into the main branch, and optionally their remote counterparts plus stale remote-tracking refs. Use when asked to clean up, tidy, or prune branches after merging PRs. Never deletes the main branch, the current branch, or unmerged work.
---

# Clean Branches

Tidy up fully merged branches. Safe by construction: only merged branches are removed, the main branch and current branch are never touched, and nothing is deleted until the user has seen the list and confirmed.

## Steps

1. Resolve the main branch and current branch:
   - main: `git remote show origin | sed -n 's/.*HEAD branch: //p'` (fallback `main`, then `master`).
   - current: `git branch --show-current`.
2. Refresh refs so "merged" and "gone" are accurate: `git fetch --prune origin`.
3. List merged local branches, excluding main and the current branch:
   `git branch --merged <main> | grep -vE '^[*+]|^\s*(<main>|master)$'`.
4. Show the user the list and the exact delete commands. Wait for explicit confirmation.
5. Delete the confirmed local branches with `git branch -d <branch>` (use `-d`, never `-D` — it refuses unmerged work).
6. Remote cleanup only if the user asked, and confirm it separately (it changes shared state):
   for each merged branch whose upstream is gone, `git push origin --delete <branch>`.

## Rules
- Never delete `main`/`master` or the current branch.
- Use `-d` (safe). Only use `-D` if the user explicitly names a specific unmerged branch and insists.
- Remote deletion is opt-in and confirmed on its own.
- "Merged" is computed relative to main — if the working copy is far behind, run the fetch in step 2 first and say so.
