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

# Only react to git merge / git rebase
if echo "$cmd" | grep -qE '\bgit[[:space:]]+(merge|rebase)\b'; then
  branch=$(git branch --show-current 2>/dev/null)
  if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    ask "現在のブランチが '$branch' です。main への merge/rebase は明示的な確認が必要です（CLAUDE.md の Git Workflow）。"
  fi
fi

exit 0
