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
├── skills/                    # authored skills → ~/.claude/skills/<name>/
│   ├── petrichor/             # plan a new project/feature (interview) — the front door
│   ├── squall/                # one-time project init → .claude/project.md
│   ├── monsoon/               # router: read state, delegate to the right skill
│   ├── check/                 # run lint/typecheck (+test/build), log + summarize
│   ├── release-note/          # opt-in RELEASE_NOTE.md changelog
│   ├── clean-branches/        # delete merged local/remote branches
│   ├── python-setup/          # sandbox-safe Python venv onboarding
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

## Workflow

Lifecycle: `petrichor` → `squall` → `monsoon`, then `monsoon` dispatches the rest.

0. **New / empty project — `petrichor`.** Interview to a full spec, build the initial scaffold, then run `squall`. (Skip for a repo that already has code.)

1. **Once per repo — `squall`.** Detects the stack and check commands, writes `.claude/project.md` (static config that `monsoon` reads) and `.claude/CLAUDE.md` (project conventions), and enables opt-ins like release notes on confirmation.

2. **Every time after — `monsoon`.** Reads `.claude/project.md` + live git state and does the next sensible thing, delegating to the right skill:
   - uncommitted changes → `check` (lint/typecheck), then offers to commit
   - feature branch with checks passing → offers to push / open a PR
   - version bump + release notes enabled → `release-note`
   - merged branches piling up → `clean-branches`
   - on request → `session-learn`

   Read-only steps run automatically; anything outward or irreversible is proposed first.

Call a skill directly for a single step:

| skill | what it does |
| --- | --- |
| `check` | run lint/typecheck (`full` adds test+build); logs to `~/Documents/claude-shared/` |
| `release-note` | update `RELEASE_NOTE.md` from commits since the last tag (opt-in per repo) |
| `clean-branches` | delete merged local branches (remote on request); main/master is hook-protected |
| `session-info` | write the resume command (`claude --resume <id>`) to `~/Documents/claude-shared/` |
| `session-learn` | review past transcripts; propose standing rules and record error→fix lessons |
| `python-setup` | set up a sandbox-safe Python venv |

## Two kinds of skills

- **Authored skills** (e.g. `petrichor`, `monsoon`) live in `skills/` and are symlinked in by `install.sh`. Edit them here; they sync via git.
- **Plugin skills** (figma, serena, chrome-devtools, …) are *not* files here — they're restored from `settings.json`'s `enabledPlugins` + `extraKnownMarketplaces` on first launch.

## Secrets

- The real GitHub PAT lives **only** in `~/.claude/settings.local.json` (gitignored). `settings.local.json` overrides `env.GH_TOKEN` at runtime; the template carries a placeholder.
- `.gitignore` also blocks any literal `settings.json` as a safety net.
- If a real token ever lands in a commit: **rotate it immediately** on GitHub.
