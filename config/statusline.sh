#!/usr/bin/env bash

# Line 1: model  ctx:▌▌▌····  34%   branch
# Line 2: proj:~/path/to/project  cwd:~/path/to/current
# Line 3: 5h:▌▌▌····· 12.50% | 7d:▌▌▌····· 80.10%   (rate limits, when present)

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cwd=$(echo "$input" | jq -r '.cwd // "."')
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

# Read workspace dirs — fall back to cwd and git toplevel
ws_current=$(echo "$input" | jq -r '.workspace.current_dir // empty')
ws_project=$(echo "$input" | jq -r '.workspace.project_dir // empty')
# Fallback: use cwd for current dir, git toplevel for project dir
[ -z "$ws_current" ] && ws_current="$cwd"
[ -z "$ws_project" ] && ws_project=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)

# Abbreviate $HOME to ~
home_escaped=$(printf '%s' "$HOME" | sed 's/[[\.*^$()+?{|]/\\&/g')
abbrev() {
  printf '%s' "$1" | sed "s|^${home_escaped}|~|"
}

# ── 8-cell Unicode sparkbar (partial-fill with block elements) ────────────────
sparkbar() {
  local pct="${1:-0}"
  local cells=8
  local blocks="▏▎▍▌▋▊▉█"
  local total_eighths
  total_eighths=$(echo "$pct $cells" | awk '{printf "%d", ($1/100)*$2*8 + 0.5}')
  local bar=""
  for i in $(seq 1 $cells); do
    local cell_eighths=$(( total_eighths - (i - 1) * 8 ))
    if   [ "$cell_eighths" -ge 8 ]; then bar="${bar}█"
    elif [ "$cell_eighths" -le 0 ]; then bar="${bar}·"
    else bar="${bar}$(echo "$blocks" | cut -c$cell_eighths)"
    fi
  done
  printf '%s' "$bar"
}



# ── Rate limits ──────────────────────────────────────────────────────────────
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

fmt_reset() {
  local ts="$1"
  if [ -n "$ts" ]; then
    date -r "$ts" '+%H:%M' 2>/dev/null || date -d "@$ts" '+%H:%M' 2>/dev/null
  fi
}

# ── Assemble output ───────────────────────────────────────────────────────────
if [ -n "$used" ]; then
  ctx_bar=$(sparkbar "$used")
  ctx_pct=$(printf '%.0f' "$used")
  ctx_str="${ctx_bar} ${ctx_pct}%"
else
  ctx_str="········ -%"
fi

# Line 1
if [ -n "$branch" ]; then
  printf '%s | ctx:%s | %s' "$model" "$ctx_str" "$branch"
else
  printf '%s | ctx:%s' "$model" "$ctx_str"
fi

# Line 2: workspace directories
if [ -n "$ws_project" ] && [ -n "$ws_current" ]; then
  proj=$(abbrev "$ws_project")
  cur=$(abbrev "$ws_current")
  if [ "$ws_project" = "$ws_current" ]; then
    printf '\nproj:%s' "$proj"
  else
    printf '\nproj:%s | cwd:%s' "$proj" "$cur"
  fi
elif [ -n "$ws_project" ]; then
  printf '\nproj:%s' "$(abbrev "$ws_project")"
elif [ -n "$ws_current" ]; then
  printf '\ncwd:%s' "$(abbrev "$ws_current")"
fi

# Line 3: rate limits (5h / 7d)
rl_parts=()
if [ -n "$five_pct" ]; then
  five_bar=$(sparkbar "$five_pct")
  five_pct_fmt=$(printf '%05.2f' "$five_pct")
  five_str="5h:${five_bar} ${five_pct_fmt}%"
  five_reset_fmt=$(fmt_reset "$five_resets")
  [ -n "$five_reset_fmt" ] && five_str="${five_str}(→${five_reset_fmt})"
  rl_parts+=("$five_str")
fi
if [ -n "$seven_pct" ]; then
  seven_bar=$(sparkbar "$seven_pct")
  seven_pct_fmt=$(printf '%05.2f' "$seven_pct")
  seven_str="7d:${seven_bar} ${seven_pct_fmt}%"
  seven_reset_fmt=$(fmt_reset "$seven_resets")
  [ -n "$seven_reset_fmt" ] && seven_str="${seven_str}(→${seven_reset_fmt})"
  rl_parts+=("$seven_str")
fi
if [ ${#rl_parts[@]} -gt 0 ]; then
  # Join with a literal ' | ' (matching lines above). ${arr[*]} with IFS only
  # uses IFS's FIRST char, so it cannot produce a multi-char separator.
  rl_line="${rl_parts[0]}"
  for ((i = 1; i < ${#rl_parts[@]}; i++)); do
    rl_line="${rl_line} | ${rl_parts[i]}"
  done
  printf '\n%s' "$rl_line"
fi

