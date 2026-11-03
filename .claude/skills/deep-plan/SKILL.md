---
name: deep-plan
description: Use after a brief (and, for backend, a domain model) is approved and before writing implementation code for any feature touching more than one file, layer, repo or service. Produces a step-by-step implementation plan with files, data-access strategy, test list, risks and an architecture decision record when needed.
---

# Deep plan

Plan the work so implementation becomes mechanical and reviewable. Output is a plan file; no production code is written by this skill.

## Inputs
- `docs/briefs/<feature>.md` (approved) — run `clarify` first if missing.
- Backend: `docs/domain/<context>/<feature>.md` — run `domain-model` first if missing.
- `CLAUDE.md` of the repo (conventions, folder structure).

## Procedure

1. **Read the codebase around the change** — the module/route it lives in, similar existing features, shared libs. Reuse patterns that already exist.
2. **Verify APIs** with `fresh-docs` for anything framework-specific you're about to plan.
3. **Draft the plan** with the template below. Be concrete: real file paths, real type names.
4. **Data-access strategy (backend, mandatory section).** For every query/write state:
   - Exact Prisma call; `select` only needed columns (never return whole rows by default)
   - Indexes needed (composite index order = equality columns first, then range/sort)
   - Pagination: cursor/keyset for lists that grow (`WHERE (createdAt,id) < (?,?) ORDER BY createdAt DESC, id DESC LIMIT n`); offset only for small admin tables
   - Batch writes: `createMany` / `updateMany` / chunked (e.g. 500 rows) instead of loops; never N+1 (use `include`/`in` lookups or a read model)
   - Transactions: what must be atomic; use interactive `$transaction` only around one aggregate; set isolation level when invariants depend on reads
   - Concurrency: optimistic locking via `version` column for aggregates edited concurrently
   - Deletes: soft-delete (`deletedAt`) for business records + partial index; hard-delete only for PDPA erasure jobs
   - Expected complexity per operation (e.g. O(log n) index seek + O(k) rows returned)
5. **Frontend section (mandatory for UI work).** Server vs Client Component split, data fetching location, caching (`'use cache'`, tags, invalidation), Server Action vs calling backend, loading/error/not-found boundaries, metadata/SEO, image strategy, a11y notes, performance budget impact.
6. **Test list** — map every acceptance criterion and every invariant to a test (unit / integration / e2e) before any code.
7. **Risks & rollback** — migrations that lock tables, breaking API/event changes (version them), feature flags.
8. **ADR** — if the plan makes a decision that is hard to reverse (new service, new transport, new DB table shape, auth approach), write `docs/adr/NNNN-<title>.md` (Context / Decision / Consequences / Alternatives).
9. Save as `docs/plans/YYYY-MM-DD-<slug>.md`, show a short summary, and wait for approval.

## Plan template

```markdown
# Plan: <feature>   Brief: <link>   Model: <link>
## Summary (3 lines)
## Steps (each step = one small commit, tests first)
1. [ ] <step> — files: … — test: …
## Contracts (API routes, request/response Zod schemas, events + versions)
## Data-access strategy (see skill rules)
## Frontend strategy (if UI)
## Test list (criterion → test type → file)
## Security notes (authz per endpoint, input validation, PII touched)
## Risks / migrations / rollback
## ADRs created
```

## Rules
- Steps small enough that each passes `gates` on its own.
- If the plan exceeds ~15 steps, split the feature.
- Plans are living docs: update the checkbox as steps land.
