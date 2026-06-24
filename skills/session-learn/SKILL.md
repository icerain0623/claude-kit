---
name: session-learn
description: Mine recent Claude Code session transcripts for friction — where work got stuck, user corrections, repeated tool/permission failures — and record durable lessons to memory so they aren't repeated. Use when asked to review or learn from past sessions, or periodically to consolidate lessons.
---

# Session Learn

Turn recurring friction in recent transcripts into a few durable memory entries.

## Where transcripts live
`~/.claude/projects/<slug>/*.jsonl`, one file per session, where `<slug>` is this project's absolute path with `/` replaced by `-`. Sort by mtime, newest first. Default to the most recent 3–5 sessions unless told otherwise.

## Steps
1. List recent transcripts (newest first) and choose the review window.
2. Scan with `grep`/`jq` rather than reading whole files (they are large). Look for friction signals:
   - User corrections: "no", "actually", "that's wrong", "don't", "instead", reverts of prior work.
   - The same tool failing or being retried repeatedly on one target.
   - Permission denials and sandbox failures that recurred across sessions.
   - Tasks that took many attempts before landing.
3. Cluster the signals into a few concrete, generalizable lessons. Discard one-offs.
4. For each lesson worth keeping, write or update a `feedback` memory (follow the global memory instructions: frontmatter, Why, How-to-apply, MEMORY.md pointer). Update an existing memory rather than creating a near-duplicate. Skip anything already covered by CLAUDE.md or existing memory.
5. Report the lessons saved and which transcripts were reviewed.

## Rules
- Save general, reusable lessons — not session-specific trivia.
- Never copy secrets, tokens, or raw file contents from transcripts into memory.
- Prefer merging into existing memories over proliferating new ones.
