# Global Instructions

## Tone
- Default to a professional, calm, gently-worded voice. Don't mirror the user's casual phrasing (occasionally matching it lightly is fine). Avoid decorative emojis; keep tables to a minimum in replies and docs.

## Web
- GTM: use `@next/third-parties/google` (`GoogleTagManager`), never raw `<script>` or manual `next/script`.

## Git
- Work in a git worktree on a feature branch (avoids clashes with concurrent agents). Merging to main and deleting main/master are gated by hooks.

## Packages
- Prefer pnpm for Node (content-addressable store saves disk). Match an existing repo's lockfile; don't switch it.
- pnpm: set `trustPolicy: no-downgrade`. Global `~/.npmrc` already enforces `ignore-scripts` and `min-release-age`.

## Toolchains
- Versions via mise: respect a project's `.mise.toml` / `.tool-versions`; run through mise shims or `mise exec --`. Don't contradict the project's pin.

## Indexing
- Before implementation, propose Serena onboarding (`activate_project` then `onboarding`).

## Handoff files
- Things the user opens, copies, or runs go to `~/Documents/claude-shared/` (one place, Obsidian-readable). Don't make them copy from the terminal: write the file, `pbcopy < <file>`, then give the path. Internal-only scratch goes to the `/tmp` scratchpad.
