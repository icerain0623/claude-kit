---
name: session-learn
description: Mine recent Claude Code session transcripts for patterns — instructions the user repeated across sessions (candidates for a standing rule), errors hit more than once plus the fix that worked, and general friction — then propose rules and record error→fix lessons to memory so they aren't repeated. Use when asked to review or learn from past sessions, or periodically to consolidate lessons.
---

# Session Learn

## Where transcripts live
`~/.claude/projects/<slug>/*.jsonl`, one file per session, where `<slug>` is this project's absolute path with `/` replaced by `-`. Sort by mtime, newest first. Review as many as the context budget allows — ideally all of them; only cap to the most recent when the volume would overflow context. State how many you reviewed.

## Steps
1. List recent transcripts (newest first) and choose the review window.
2. Scan with `grep`/`jq` rather than reading whole files (they are large). Look for three kinds of signal:
   - **Repeated asks / corrections** across sessions ("again, use…", "I told you…", "no, do it this way", repeated reverts) — strongest candidates for a standing rule.
   - **Recurring errors** — a same/similar failure hit more than once; capture the error signature with the fix that worked.
   - **General friction** — many-attempt tasks, recurring permission/sandbox denials.
3. Cluster the signals into a few concrete, generalizable lessons. Discard one-offs.
4. Turn each kept lesson into the right artifact:
   - A repeated ask/correction → propose a **standing rule**. If it's broadly applicable, suggest adding it to the global CLAUDE.md (show the exact line); otherwise write a `feedback` memory. Present rule suggestions to the user for approval before editing CLAUDE.md.
   - A recurring error → write an `error→fix` entry: the error signature and the resolution that worked, as a `feedback` or `reference` memory, so the next occurrence is solved fast.
   - Other friction → a `feedback` memory.
   Follow the global memory instructions (frontmatter, Why, How-to-apply, MEMORY.md pointer). Update an existing entry rather than creating a near-duplicate. Skip anything already covered by CLAUDE.md or existing memory.
5. Report: rules suggested (for approval), error→fix entries saved, other lessons saved, and how many transcripts were reviewed.

## Rules
- Save general, reusable lessons — not session-specific trivia.
- Don't edit the global CLAUDE.md unprompted; rule suggestions go to the user first.
- Never copy secrets, tokens, or raw file contents from transcripts into memory.
- Prefer merging into existing entries over proliferating new ones.
