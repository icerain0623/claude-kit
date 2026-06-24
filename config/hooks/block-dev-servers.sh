#!/bin/bash
# Block long-running dev servers.
# A Claude-launched server is hard for the user to locate, stop, and restart,
# so hand it back: the user runs it themselves via the `!` prefix.

cmd=$(jq -r '.tool_input.command')

deny() {
  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"$1"}}
HOOK_JSON
  exit 0
}

MSG="dev サーバはユーザーが起動・管理します。Claude は起動せず、ユーザーに \`!<command>\` での実行を依頼してください。"

# JS/TS dev servers
if echo "$cmd" | grep -qE '\b(npm|pnpm|yarn|bun)\b[[:space:]]+(run[[:space:]]+)?(dev|start|serve|preview)\b'; then
  deny "$MSG"
fi
# Require an explicit server subcommand. The trailing `?` here previously made
# the subcommand optional, so `vite build` / `next lint` / `ng build` were all
# denied. (Bare `vite` with no subcommand still starts a dev server but is rare;
# the `npm/pnpm run dev` form above is the common path and is covered.)
if echo "$cmd" | grep -qE '\b(next|vite|nuxt|remix|astro|webpack-dev-server|ng)\b[[:space:]]+(dev|serve|start|preview)\b'; then
  deny "$MSG"
fi
if echo "$cmd" | grep -qE '\bnodemon\b'; then
  deny "$MSG"
fi

# Other ecosystems
if echo "$cmd" | grep -qE '\b(rails[[:space:]]+(s|server)|php[[:space:]]+artisan[[:space:]]+serve|flask[[:space:]]+run|uvicorn|gunicorn|python[0-9.]*[[:space:]]+-m[[:space:]]+http\.server|http-server)\b'; then
  deny "$MSG"
fi

exit 0
