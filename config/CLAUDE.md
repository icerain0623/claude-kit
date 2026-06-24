# Global Instructions

## Web Development
- GTM: always use `@next/third-parties/google` (`GoogleTagManager`) — never raw `<script>` or manual `next/script`.

## Landing Pages (Next.js)
Auto-run the pipeline yourself for LP / Figma→page work — don't wait for the user, and never skip verify:
- Extract design from Figma → `figma-extract`
- Implement / edit → `landing-page-nextjs` (holds the detailed conventions)
- Verify after any visual change → screenshot/diff against the design (`chrome-devtools-mcp` if usable)

## Dev Servers
- Never start dev servers or other long-running processes — a Claude-launched server is hard for the user to locate and stop. Ask the user to run it via the `!` prefix.

## Git Workflow
- Work in a git worktree on its own feature branch (avoids clashes with concurrent agents).
- Never merge to main without explicit confirmation.

## Packages
- Prefer pnpm for Node projects — its content-addressable store hard-links packages instead of copying, saving disk across repos. Match an existing repo's lockfile rather than switching it.
- Install with scripts disabled by default (`npm install --ignore-scripts`, or the pnpm equivalent); re-enable per-package only when a build genuinely needs it.
- npm: set `min-release-age=7` in `.npmrc` (≥3 days even when urgent). pnpm: set `trustPolicy: no-downgrade`.

## Toolchains (mise)
- Tool versions are managed with mise. Respect a project's `.mise.toml` / `.tool-versions`; run tools via mise shims on PATH or `mise exec -- <cmd>`. Don't pin or invoke a global version that contradicts the project's pin.

## Indexing
- Before implementation, propose Serena onboarding (`activate_project` → `onboarding`) for symbol-level navigation.

## Temporary & Handoff Files
- Anything the user may open, copy, or run (commands, commit messages, notes, snippets) → `~/Documents/claude-shared/`. One location, reviewed in Obsidian. Don't make the user copy from the terminal (it mangles newlines): write the file there, load it with `pbcopy < <file>`, then give the path.
- Internal-only scratch the user won't see → harness `/tmp` scratchpad.
