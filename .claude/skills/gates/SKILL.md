---
name: gates
description: Use before declaring any task, step, commit or pull request done, and whenever the developer says "check", "verify", "ready to merge" or "is this done". Runs the quality gates for the current repo (types, lint, tests, build, data-access review, Lighthouse/a11y for frontend) and refuses to call work done until they pass.
---

# Gates (definition of done)

Nothing is "done" because it compiles. It's done when every applicable gate below is green and the evidence is shown.

## Procedure

1. Detect the repo type from `package.json` (Next.js → frontend gates; NestJS → backend gates).
2. Run each gate in order. **Stop at the first red gate**, fix it (or ask), re-run from that gate.
3. Report a table: gate → command → result (pass/fail + key numbers). Paste the real output summary, never "should pass".
4. Only then say "done", and tick the step in `docs/plans/…`.

## Shared gates (both repos)

| # | Gate | Command (adapt to package scripts) | Pass rule |
|---|---|---|---|
| 1 | Types | `npm run typecheck` (`tsc --noEmit`) | 0 errors; no `any`, no `@ts-ignore` added |
| 2 | Lint/format | `npm run lint` | 0 errors |
| 3 | Unit tests | `npm test` | all pass |
| 4 | No JS files | `git ls-files '*.js' '*.jsx' '*.mjs' '*.cjs'` | empty, except tool configs explicitly allowed in CLAUDE.md |
| 5 | Secrets | `git diff --cached` scan for keys/tokens/.env | none committed |
| 6 | Deps | `npm audit --omit=dev` | no high/critical |
| 7 | Brief check | Each acceptance criterion in the brief has a passing test | 100 % mapped |

## Backend gates (NestJS)

| # | Gate | Pass rule |
|---|---|---|
| B1 | Domain unit tests cover every invariant in the domain model | 1+ test per invariant |
| B2 | Integration tests against real Postgres (Testcontainers or docker compose) | pass |
| B3 | e2e HTTP / message tests (`npm run test:e2e`) | pass |
| B4 | Migration review: `prisma migrate diff` reviewed; no full-table rewrite/lock on large tables without plan | approved |
| B5 | Data-access review: no N+1, `select` used, list endpoints paginated (cursor), needed indexes exist, batch writes used | checklist ✓ |
| B6 | Validation: every controller input & message payload parsed by a Zod 4 schema; responses don't leak internal fields | ✓ |
| B7 | AuthZ: every new endpoint has an explicit guard/policy & a test for the forbidden case | ✓ |
| B8 | Architecture: domain layer imports nothing from Nest/Prisma (`dependency-cruiser` or grep) | ✓ |

## Frontend gates (Next.js)

| # | Gate | Pass rule |
|---|---|---|
| F1 | `next build` | success, no warnings about deprecated APIs |
| F2 | Playwright e2e (`npx playwright test`) | all pass, incl. critical user journeys |
| F3 | Accessibility: `@axe-core/playwright` on each changed page | 0 violations |
| F4 | Lighthouse (production build, mobile preset) on changed routes — `lhci autorun` | Performance, Accessibility, Best Practices, SEO = **100**; LCP < 2.5 s, CLS < 0.1, TBT < 200 ms |
| F5 | Bundle: `'use client'` only where interactivity is needed; no large lib in client bundle without reason | reviewed |
| F6 | SEO: `generateMetadata`/metadata, canonical, `robots.ts`, `sitemap.ts`, one `<h1>`, descriptive link text | ✓ |

## Rules
- Never weaken a gate (skip test, lower threshold, add ignore) without the developer's explicit OK and a note in the PR.
- Flaky test = red. Fix or quarantine with an issue link.
- If a gate can't run locally (e.g. no Docker), say so plainly instead of claiming success.
