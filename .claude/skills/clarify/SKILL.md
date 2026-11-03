---
name: clarify
description: Use before starting any new feature, bug fix, refactor or design task whose scope, acceptance criteria, users or edge cases are not written down. Interviews the developer and produces a one-page brief before any code is written.
---

# Clarify

Turn a vague request into a written brief that the rest of the workflow (`deep-plan`, `gates`) can be checked against. No code, no file edits, no scaffolding while this skill is running.

## When to stop and clarify

Run this skill when ANY of these is true:
- The request names an outcome but not how we'll know it's done ("add login", "make it faster").
- It touches money, personal data, auth, multi-tenancy or deletes data.
- It spans more than one repo (frontend + backend) or more than one microservice.
- You would otherwise have to guess a business rule.

Skip it for typo fixes, dependency bumps, or when a brief already exists in `docs/briefs/`.

## Procedure

1. **Restate** the request in one sentence in your own words. Ask the developer to confirm or correct it.
2. **Ask at most 5 questions per round**, highest-impact first. Prefer multiple-choice with a recommended default marked "(recommended)". Cover, in this order, only what is still unknown:
   - Who is the user/actor? (role, permission level)
   - What is the observable outcome? (screen, API response, event, email)
   - What are the business rules and invariants? ("a seat can't be reserved twice")
   - Edge cases & failure modes (empty, duplicate, concurrent, expired, unauthorised)
   - Non-functional: data volume, latency budget, Lighthouse budget, PDPA/personal data, audit trail
   - Out of scope (explicitly)
3. **Never invent answers.** If the developer says "you decide", pick the conventional default, and record it under *Assumptions* so it's visible.
4. **Write the brief** to `docs/briefs/YYYY-MM-DD-<slug>.md` using the template below.
5. Ask: "Brief OK? Next step is `deep-plan`." Do not proceed until confirmed.

## Brief template

```markdown
# <Feature name>
Status: draft | approved   Date: YYYY-MM-DD   Repos: frontend | backend:<service>

## Problem (1–3 sentences, business language)
## Actors & permissions
## Acceptance criteria (Given / When / Then, numbered — each becomes a test)
1. Given … When … Then …
## Business rules & invariants
## Edge cases & failure modes
## Non-functional requirements (perf, security, PDPA, a11y, SEO)
## Out of scope
## Assumptions (decisions made on the developer's behalf)
## Open questions
```

## Rules
- Acceptance criteria must be testable. "Fast" is not; "p95 < 300 ms for 10k rows" is.
- Use the domain's words (ubiquitous language) — the same words go into code later.
- One brief per feature. If it grows past one page, split the feature.
