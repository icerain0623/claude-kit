---
name: petrichor
description: Use when planning a new project or a feature and you want to be interviewed relentlessly until the plan is fully specified. The front-door for greenfield work — plan here first, then scaffold and run squall. Starts as one-question-at-a-time chat to grasp the overview, then switches to document-based batched Q&A for details. Resumable — re-invoke to continue.
---

# Petrichor

Interview the user relentlessly until the plan is fully specified. Walk the design tree branch by branch, resolving dependencies one at a time. Always give your recommended answer. If the codebase can answer a question, explore it instead of asking — prefer Serena's symbol tools (`get_symbols_overview`, `find_symbol`) when that MCP is already active, otherwise Grep/Read. Do not trigger Serena onboarding from here; that belongs to implementation.

Two phases, chosen by question type:
- **Phase 0 — chat, one at a time**: few, highly-dependent questions. Build the overview conversationally.
- **Phase 1+ — batched in files**: many independent details. Faster, and yields a written spec.

## Files (`docs/petrichor-plan/`)

- `00-overview.md` — single source of truth: progress header (resume pointer) + accumulated decisions. Rewritten once per round. No separate state file.
- `NN-topic.md` (`01-database.md`, …) — disposable working files for batched questions; user fills answers inline.

## Inbox & scratch (outside the repo)

Two user-owned files live in `~/Documents/claude-shared/<project>/` (`<project>` = basename of the working dir; create the dir + files if missing). These never enter the repo, so they don't affect the project:

- `TODO.md` — idea inbox. The user dumps things they want to do here, roughly, anytime.
- `scratch.md` — freeform notepad. **petrichor never reads or edits its contents** (only creates it empty once). Pure personal memo.

petrichor **reads** `TODO.md` but never silently decides from it. Each round, surface items that touch the current topics as proposed `## <decision point>` blocks in the `NN-topic.md` file (with a Recommendation, same format as any other question). Only after the user fills `Answer:` does it get promoted to `00-overview.md`. When an item is promoted, check it off in `TODO.md` with a `(→ spec)` tag — never delete it. Items the user hasn't acted on stay untouched.

## On launch

Ensure the inbox dir + `TODO.md` + `scratch.md` exist (create empty if missing). Read `TODO.md` (not `scratch.md`).

If `docs/petrichor-plan/00-overview.md` exists, read it. Its header gives the phase and open topics → resume from there, do not restart. If absent, start Phase 0.

## Phase 0

- Ask one question at a time, waiting for each answer. Recommend an answer each time.
- Switch out when you can restate the project in one paragraph and only independent details remain: present that summary, ask to proceed, wait for GO.
- **Hard stop: after 8–10 questions you MUST propose the switch.**
- On GO: write `00-overview.md` with the Phase 0 conclusions, then go to Phase 1.

## Phase 1+ (per round)

1. List open topics (DB, auth, API, errors, deploy, …). Re-read `TODO.md`; fold any items touching these topics in as proposed blocks (see Inbox & scratch).
2. Write `NN-topic.md`, one block per question, plus a free-form `## Notes` zone at the bottom:
   ```markdown
   ## <decision point>
   Recommendation: <answer + brief why>
   Answer:
   ```
3. Ask the user to fill the `Answer:` fields and send `ok` (or re-invoke). Partial is fine — unanswered items roll to the next round.
4. Read the whole file; no markers needed:
   - an `Answer:` that is actually a counter-question → answer it, do not decide yet
   - a plain answer → decided
   - always read the `## Notes` zone
5. End of round: promote agreed decisions into `00-overview.md` in ONE write. Never toggle per-question state inside topic files. Refresh the header:
   ```markdown
   # Petrichor Progress
   - Phase / Next / Open topics / Decided
   ```

## Done

When no open questions remain anywhere: set header `Next: DONE`, and tell the user `00-overview.md` is the spec to hand to implementation.

Never make the user re-summarize their answers — re-read and diff the file yourself.
