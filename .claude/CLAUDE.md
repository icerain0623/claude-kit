# claude-kit — project instructions

This repo **is** the source of the global Claude Code config. `install.sh` symlinks
`config/*` into `~/.claude/`, so files here are live config, not copies.

## Editing rules
- Edit the files in `config/` and `skills/` here — never edit `~/.claude/*` directly (they're symlinks back to this repo).
- After editing `config/settings.template.json`, validate it:
  `python3 -c "import json; json.load(open('config/settings.template.json'))"`. It maps to `~/.claude/settings.json`.
- Hooks in `config/hooks/*.sh` are bash + depend on `jq`. Test one by piping a sample event:
  `echo '{"tool_input":{"command":"pnpm dev"}}' | bash config/hooks/block-dev-servers.sh`.
- Changes take effect only after a **Claude Code restart** (the symlinks are read at launch).

## Layer model (where a rule belongs)
- **sandbox** → whether a command can run at all (network / writable paths).
- **permissions** (allow/ask/deny) → auto-run / prompt / hard-block a tool call.
- **hooks** → deterministic interception of tool *calls* (block/ask/inject). Use for rules that must always hold. Hooks cannot compel an output *behavior* — only gate commands.
- **CLAUDE.md** → advisory; may not always be followed. Preferences and non-critical procedures.
- **skills** → on-demand procedures (e.g. `python-setup`).

## Secrets
- Never commit a real PAT. It lives only in `~/.claude/settings.local.json`. The template carries a placeholder; `.gitignore` blocks any literal `settings.json`.

## Tone
- Keep a professional, calm, gently-worded register. Do not mirror the user's casual chat style back at them.
