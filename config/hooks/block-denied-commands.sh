#!/bin/bash
# Defense-in-depth: block commands that are also in permissions.deny
# Uses exit code 2 to block before permission evaluation reaches the harness

HOOK_INPUT=$(cat)
cmd=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command')

block() {
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"'"$1"'"}}' >&2
  exit 2
}

# Extract the first word (command name) and check against denied list
# Also check for these commands appearing after && or ; or |
for denied in su sudo passwd history env printenv rsync scp sftp socat ssh nc ncat netcat nmap shutdown reboot halt poweroff crontab launchctl op vault security; do
  # Match as first command or after shell operators (&& ; | `)
  if echo "$cmd" | grep -qE "(^|&&|;|\||\`)[[:space:]]*${denied}([[:space:]]|$)"; then
    block "Blocked by security hook: '$denied' is not allowed"
  fi
done
