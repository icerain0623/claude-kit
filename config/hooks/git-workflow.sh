#!/bin/bash
# Enforce the one git-workflow rule that's mechanically checkable:
# never merge into main/master without explicit confirmation.
# (Working in a worktree / feature branch is advisory — left to CLAUDE.md.)

cmd=$(jq -r '.tool_input.command')

ask() {
  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"$1"}}
HOOK_JSON
  exit 0
}

deny() {
  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"$1"}}
HOOK_JSON
  exit 0
}

# Hard guard: never delete the main/master branch (local or remote).
# Local: git branch -d/-D main|master
if echo "$cmd" | grep -qE 'git[[:space:]]+branch[[:space:]]+(-[a-zA-Z]*[dD][a-zA-Z]*[[:space:]]+)(.*[[:space:]])?(main|master)([[:space:]]|$)'; then
  deny "main/master ブランチの削除は禁止です。"
fi
# Remote: git push ... --delete main|master  OR  git push origin :main
if echo "$cmd" | grep -qE 'git[[:space:]]+push[[:space:]]+.*(--delete[[:space:]]+.*(main|master)|:[[:space:]]*(main|master))([[:space:]]|$)'; then
  deny "リモートの main/master ブランチの削除は禁止です。"
fi

# Only react to git merge / git rebase
if echo "$cmd" | grep -qE '\bgit[[:space:]]+(merge|rebase)\b'; then
  branch=$(git branch --show-current 2>/dev/null)
  if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    ask "現在のブランチが '$branch' です。main への merge/rebase は明示的な確認が必要です（CLAUDE.md の Git Workflow）。"
  fi
fi

exit 0
