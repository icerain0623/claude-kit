#!/usr/bin/env bash
# Static-lint the shell in this repo. shellcheck catches quoting/unset-var/syntax
# classes; it does NOT catch logic errors (see test-hooks.sh for those).
#   brew install shellcheck   # if missing
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not installed — run: brew install shellcheck"
  exit 127
fi

# shellcheck disable=SC2086
shellcheck "$REPO/install.sh" "$REPO/lint.sh" "$REPO/test-hooks.sh" \
           "$REPO/config/statusline.sh" "$REPO"/config/hooks/*.sh
