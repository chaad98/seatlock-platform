---
name: walkthrough
description: Use after a feature or plan step passes `gates`, when the developer asks "document this", "write it up", "how does this work", or wants to follow along with what was built. Writes a tutorial-style walkthrough of the feature (what, why, files, key code explained, how to run and test) and keeps the MVP roadmap up to date.
---

# Walkthrough (follow-along docs per feature)

This is a learning project. Every finished feature gets a guide the developer can read top to bottom and rebuild on their own, plus an always-current roadmap of the MVP.

## Two documents this skill owns

1. `docs/roadmap.md` — the MVP at a glance (create it from the first brief if missing).
2. `docs/walkthroughs/NN-<feature-slug>.md` — one per feature, numbered in build order (01, 02, …) so they read like chapters of a book.

## Procedure

1. **Collect inputs:** the feature's brief (`docs/briefs/`), domain model (`docs/domain/`), plan (`docs/plans/`), and the actual diff (`git diff` against the commit before the feature started). Write from the real code, never from the plan alone.
2. **Write the walkthrough** with the template below. Rules:
   - Plain English, short sentences. Explain *why* before *how*.
   - Show only the important code (aggregate method, command handler, Zod schema, Prisma query, Server Component, Server Action), 5–30 lines each, with the file path above every snippet. Don't paste whole files.
   - After each snippet, 2–4 bullet points: what it does, the concept it demonstrates (link the official doc), and the common mistake it avoids.
   - Draw the request flow as a Mermaid sequence diagram when more than two parts are involved (browser → Next.js → gateway → service → DB / NATS).
   - End with "Try it yourself": 1–3 small exercises that extend the feature.
3. **Update `docs/roadmap.md`:** tick the feature, link its walkthrough, and list what's next.
4. **Link everything:** walkthrough ↔ brief ↔ plan ↔ ADRs; add a one-line entry to `docs/learning-log.md` for each new concept (as `teach` does).
5. Show the developer the walkthrough path and ask if any part needs a deeper explanation; deepen that section rather than adding new ones.

## Walkthrough template

```markdown
# NN · <Feature name>
Repos: frontend | backend:<service>   Brief: <link>   Plan: <link>   Date: YYYY-MM-DD

## What we built (2–3 sentences, user's point of view)
## Why it's built this way (architecture choices, link ADRs)
## How a request flows
​```mermaid
sequenceDiagram
  ...
​```
## Files added or changed
| File | Layer | Purpose |
## Key code, explained
### <step name> — `path/to/file.ts`
<snippet>
- What it does …
- Concept: … ([docs](…))
- Watch out: …
## Database changes (migration, indexes, why, query complexity)
## Security notes (authz, validation, what an attacker can't do)
## How to run it
## How it's tested (unit / integration / e2e, with commands)
## What you learned (3–5 bullets)
## Try it yourself (1–3 exercises)
```

## Roadmap template (`docs/roadmap.md`)

```markdown
# MVP roadmap — <project name>
Goal: <one sentence>   Last updated: YYYY-MM-DD

| # | Feature | Repo / service | Status | Walkthrough |
| 01 | … | backend:identity | ✅ done | [01-…](walkthroughs/01-….md) |
| 02 | … | frontend | 🔄 in progress | — |
| 03 | … | backend:booking | ⏳ next | — |

## Architecture today (Mermaid diagram of services and how they talk)
## Concepts covered so far (links into walkthroughs)
```

## Rules
- Never document code that doesn't exist yet; walkthroughs describe what is merged.
- If the code changes later, update the walkthrough in the same commit (`compound` checks this).
