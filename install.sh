#!/usr/bin/env bash
# Install my personal Claude Code setup into ~/.claude via symlinks.
# Run on a NEW machine after cloning, from your own terminal
# (NOT inside the Claude Code sandbox — it writes to ~ and runs git config).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/skills"

backup() {
  # back up a real (non-symlink) file/dir before replacing it
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mv "$1" "$1.bak.$(date +%s)"
    echo "  backed up existing $1 -> $1.bak.*"
  fi
}

link() {
  backup "$2"
  ln -sfn "$1" "$2"
  echo "  linked $2 -> $1"
}

echo "Linking config ..."
link "$REPO/config/CLAUDE.md"              "$CLAUDE_DIR/CLAUDE.md"
link "$REPO/config/statusline.sh"          "$CLAUDE_DIR/statusline.sh"
link "$REPO/config/settings.template.json" "$CLAUDE_DIR/settings.json"
for h in "$REPO"/config/hooks/*.sh; do
  link "$h" "$CLAUDE_DIR/hooks/$(basename "$h")"
done

echo "Linking authored skills ..."
for s in "$REPO"/skills/*/; do
  link "${s%/}" "$CLAUDE_DIR/skills/$(basename "${s%/}")"
done

echo "Wiring global gitignore ..."
link "$REPO/config/gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile "$HOME/.gitignore_global"

echo "Wiring global npm config ..."
link "$REPO/config/npmrc" "$HOME/.npmrc"

echo "Creating shared handoff dir ..."
mkdir -p "$HOME/Documents/claude-shared"

cat <<'EOF'

Done linking. Remaining steps:

  1. SECRET (never committed) — create ~/.claude/settings.local.json:
       { "env": { "GH_TOKEN": "github_pat_..." } }
  2. Install jq if missing (hooks depend on it):  brew install jq
  3. Plugin-based skills (figma, serena, etc.) are restored from
     settings.json's enabledPlugins + extraKnownMarketplaces on first launch.

Then restart Claude Code.
EOF
