#!/bin/bash
# Dangerous command warning hook
# Returns permissionDecision: "ask" to prompt user confirmation

cmd=$(jq -r '.tool_input.command')

warn() {
  local msg="$1"
  cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"$msg"}}
HOOK_JSON
  exit 0
}

# ============================================================
# A. File system destruction
# ============================================================

# rm -rf on root, home, or parent traversal paths
if echo "$cmd" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+.*|.*\s+)(\/\s*$|\/\*|\/[a-z]*\s|~\/|~\s*$|\$HOME)'; then
  warn "危険なrm操作を検出: ルート/ホームディレクトリに対する再帰的削除の可能性があります"
fi

# rm -rf with parent directory traversal
if echo "$cmd" | grep -qE 'rm\s+.*-[a-zA-Z]*r[a-zA-Z]*.*\.\./\.\.'; then
  warn "危険なrm操作を検出: 親ディレクトリへの遡り削除はリスクがあります"
fi

# ============================================================
# B. Git destructive operations
# ============================================================

# git push --force / -f (any branch)
if echo "$cmd" | grep -qE 'git\s+push\s+.*(-f|--force|--force-with-lease)'; then
  warn "git force push を検出: リモートの履歴が上書きされる可能性があります"
fi

# git reset --hard
if echo "$cmd" | grep -qE 'git\s+reset\s+--hard'; then
  warn "git reset --hard を検出: 未コミットの変更がすべて失われます"
fi

# git clean -f
if echo "$cmd" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
  warn "git clean -f を検出: 未追跡ファイルが削除されます"
fi

# git checkout . (discard all changes)
if echo "$cmd" | grep -qE 'git\s+checkout\s+\.\s*$'; then
  warn "git checkout . を検出: 作業ディレクトリの変更がすべて破棄されます"
fi

# git branch -D (force delete)
if echo "$cmd" | grep -qE 'git\s+branch\s+-D'; then
  warn "git branch -D を検出: ブランチがマージ状態に関係なく強制削除されます"
fi

# git restore . (discard all changes)
if echo "$cmd" | grep -qE 'git\s+restore\s+\.\s*$'; then
  warn "git restore . を検出: 作業ディレクトリの変更がすべて破棄されます"
fi

# ============================================================
# C. Disk / partition operations
# ============================================================

# dd to device
if echo "$cmd" | grep -qE '\bdd\b.*of\s*=\s*/dev/'; then
  warn "dd によるデバイスへの直接書き込みを検出: データが上書きされます"
fi

# mkfs (format filesystem)
if echo "$cmd" | grep -qE '\bmkfs\.'; then
  warn "mkfs を検出: ファイルシステムのフォーマットが実行されます"
fi

# ============================================================
# D. Permission changes
# ============================================================

# chmod 777 (world-writable)
if echo "$cmd" | grep -qE 'chmod\s+(-R\s+)?777'; then
  warn "chmod 777 を検出: すべてのユーザーに読み書き実行権限を付与します"
fi

# chmod 000 (no permissions)
if echo "$cmd" | grep -qE 'chmod\s+(-R\s+)?000'; then
  warn "chmod 000 を検出: すべての権限が削除されます"
fi

# Recursive chmod/chown on root
if echo "$cmd" | grep -qE '(chmod|chown)\s+-R\s+.*\s+\/\s*$'; then
  warn "ルートディレクトリに対する再帰的な権限変更を検出: システムが壊れる可能性があります"
fi

# ============================================================
# E. Database destructive operations
# ============================================================

# DROP DATABASE / TABLE / SCHEMA
if echo "$cmd" | grep -qiE 'DROP\s+(DATABASE|TABLE|SCHEMA)\b'; then
  warn "DROP操作を検出: データベース/テーブル/スキーマが削除されます"
fi

# TRUNCATE TABLE
if echo "$cmd" | grep -qiE 'TRUNCATE\s+(TABLE\s+)?\b'; then
  warn "TRUNCATE操作を検出: テーブルの全データが削除されます"
fi

# DELETE without WHERE
if echo "$cmd" | grep -qiE 'DELETE\s+FROM\s+\S+\s*$' | grep -qivE 'WHERE'; then
  warn "WHERE句のないDELETE操作を検出: テーブルの全レコードが削除される可能性があります"
fi

# ============================================================
# F. Process termination
# ============================================================

# kill / killall / pkill
if echo "$cmd" | grep -qE '\b(kill|killall|pkill)\b'; then
  warn "プロセス停止コマンドを検出: 意図しないプロセスが終了する可能性があります"
fi

# ============================================================
# G. Disk operations (macOS)
# ============================================================

# diskutil
if echo "$cmd" | grep -qE '\bdiskutil\b'; then
  warn "diskutil を検出: ディスク操作が実行されます"
fi

# ============================================================
# H. Cloud credentials / secrets access
# ============================================================

# AWS CLI
if echo "$cmd" | grep -qE '\baws\b'; then
  warn "AWS CLI を検出: クラウドリソースへのアクセスが実行されます"
fi

# GCP CLI
if echo "$cmd" | grep -qE '\bgcloud\b'; then
  warn "gcloud を検出: GCPリソースへのアクセスが実行されます"
fi

# Azure CLI
if echo "$cmd" | grep -qE '\baz\b'; then
  warn "Azure CLI を検出: Azureリソースへのアクセスが実行されます"
fi

# macOS defaults
if echo "$cmd" | grep -qE '\bdefaults\b'; then
  warn "defaults を検出: macOSシステム設定の読み書きが実行されます"
fi

# GPG secret key export
if echo "$cmd" | grep -qE 'gpg\s+--export-secret-keys'; then
  warn "GPG秘密鍵のエクスポートを検出"
fi
