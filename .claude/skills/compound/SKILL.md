---
name: compound
description: Use after a feature, bug fix or incident is finished (gates green), after a review finds a recurring mistake, or when the developer says "remember this" or "don't do that again". Captures the lesson into the repo's CLAUDE.md, docs/solutions, skills or tests so the next task is easier than this one.
---

# Compound (make every task make the next one easier)

Each unit of work should leave the system smarter: a rule, a test, a snippet, a fixed skill. This skill does the capture.

## Procedure

1. **Retrospect in 5 questions** (answer briefly, ask the developer to add theirs):
   - What took longer than it should have, and why?
   - What mistake did Claude or the developer make that could recur?
   - What did we learn about the framework (new API, deprecation, gotcha)?
   - What pattern did we create that should be reused?
   - What would have caught the problem earlier (test, lint rule, gate)?
2. **Choose the right home for each lesson** (prefer the most automatic):
   | Lesson type | Where it goes |
   |---|---|
   | Can be enforced by a tool | lint rule, type, test, CI gate (best) |
   | Project convention | `CLAUDE.md` of that repo (one bullet, imperative) |
   | Deprecated/changed API | `fresh-docs` skill's deprecation list |
   | Reusable solution to a solved problem | `docs/solutions/<topic>.md` (problem → cause → fix → link) |
   | Workflow improvement | the relevant skill's SKILL.md |
   | Learned concept | `docs/learning-log.md` (via `teach`) |
3. **Edit the files** — keep entries short; delete or merge any rule that's now outdated (rules rot; prune as you add).
4. **Show the diff** of every knowledge file changed and ask for approval before committing.
5. Commit as `chore(knowledge): <lesson>`.

## Rules
- If code changed a feature that already has a walkthrough in `docs/walkthroughs/`, update that walkthrough too.
- CLAUDE.md stays under ~200 lines. If it grows, move detail into `docs/` and link it.
- A lesson without a home is lost: never end with "noted for next time" only.
- Lessons are facts from this repo, not generic advice.
