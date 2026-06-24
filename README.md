# claude-kit

My portable [Claude Code](https://claude.com/claude-code) setup — config **and** authored skills in one repo, so a new machine is one `git clone` + `./install.sh` away.

> **Private repo.** It mirrors `~/.claude`. No real secrets are committed (see [Secrets](#secrets)), but keep it private.

## Layout

```
claude-kit/
├── install.sh                 # symlinks everything below into ~/.claude
├── config/
│   ├── CLAUDE.md              # global instructions       → ~/.claude/CLAUDE.md
│   ├── settings.template.json # permissions/sandbox/hooks → ~/.claude/settings.json (PAT is a placeholder)
│   ├── statusline.sh          #                           → ~/.claude/statusline.sh
│   ├── gitignore_global       # wired via core.excludesfile
│   ├── npmrc                  # supply-chain hardening    → ~/.npmrc (ignore-scripts=true)
│   └── hooks/*.sh             # PreToolUse hooks          → ~/.claude/hooks/
├── skills/
│   ├── forge/                 # authored skills           → ~/.claude/skills/<name>/
│   ├── python-setup/          # sandbox-safe Python venv onboarding
│   ├── clean-branches/        # delete merged local/remote branches
│   ├── check/                 # run lint/typecheck (+test/build), log + summarize
│   ├── release-note/          # opt-in RELEASE_NOTE.md changelog
│   ├── session-info/          # write session resume info to claude-shared
│   └── session-learn/         # mine past transcripts into memory lessons
└── .claude/CLAUDE.md          # project-scoped rules for working on claude-kit itself
```

## Prerequisites

- **`jq`** — required; the PreToolUse hooks parse their input with it (`brew install jq`).
- **Plugins** (figma, serena, context7, chrome-devtools, deploy-on-aws, …) are **not** installed by `install.sh`. They restore automatically from `settings.json`'s `enabledPlugins` + `extraKnownMarketplaces` on first launch — just restart Claude Code and let it pull them.
- **Toolchains** are your responsibility to install (Homebrew, etc.). The sandbox is pre-wired for them: `go`/`cargo`/`colima` run unsandboxed (`excludedCommands`); `~/.gradle`, `~/.m2`, `~/.cargo`, `~/.pyenv` are writable. For Python, invoke the `python-setup` skill (macOS has no `python`, and system pip writes outside the sandbox).

## Setup on a new machine

```bash
git clone git@github.com:<you>/claude-kit.git
cd claude-kit
./install.sh
```

Then:

```bash
# ~/.claude/settings.local.json  (secret — never committed)
{ "env": { "GH_TOKEN": "github_pat_..." } }
```

Restart Claude Code.

## Two kinds of skills

- **Authored skills** (e.g. `forge`) live in `skills/` and are symlinked in by `install.sh`. Edit them here; they sync via git.
- **Plugin skills** (figma, serena, chrome-devtools, …) are *not* files here — they're restored from `settings.json`'s `enabledPlugins` + `extraKnownMarketplaces` on first launch.

## Secrets

- The real GitHub PAT lives **only** in `~/.claude/settings.local.json` (gitignored). `settings.local.json` overrides `env.GH_TOKEN` at runtime; the template carries a placeholder.
- `.gitignore` also blocks any literal `settings.json` as a safety net.
- If a real token ever lands in a commit: **rotate it immediately** on GitHub.
