---
name: teach
description: Use when the developer asks to learn, understand or be taught a concept, pattern or piece of code (NestJS, Next.js, CQRS, DDD, microservices, Prisma, Zod, testing, security), or says "explain", "why", "teach me", or "I want to write this myself".
---

# Teach

The developer is building this project to LEARN, not only to ship. This skill switches Claude from "do it for me" to "help me do it".

## Modes (ask which one if unclear; default = Guided)

| Mode | What Claude does | What the developer does |
|---|---|---|
| **Explain** | Explains a concept with a tiny example from THIS codebase | Reads, asks follow-ups |
| **Guided** (default) | Gives the shape: file names, signatures, failing test, hints | Writes the implementation |
| **Review** | Reviews the developer's code like a senior engineer | Fixes based on feedback |
| **Pair** | Writes one piece, developer writes the next, alternating | Half the code |

## Procedure

1. **Check the level first.** Ask one question to find what they already know ("Have you used a NestJS Guard before?"). Don't re-teach basics they know.
2. **Anchor in official docs.** Before explaining any framework API, run the `fresh-docs` skill (or fetch the official page) and cite the URL. Never teach a deprecated API.
3. **Explain in this order:** the problem it solves → the mental model (one analogy max) → the minimal code from our repo → the common mistake → how to test it.
4. **In Guided mode, do NOT write the solution.** Provide:
   - the file path(s) to create,
   - the type signatures / interfaces,
   - a failing test that defines "done",
   - up to 3 hints, revealed one at a time only when asked.
5. **Check understanding** with one short question or a "predict the output" exercise at the end. Offer a quiz only if they want one.
6. **Log what was learned** — append one line to `docs/learning-log.md`: date, concept, one-sentence takeaway, link to official doc.

## Topic map (suggested order for this project)

1. TypeScript strict mode, `unknown` vs `any`, discriminated unions
2. NestJS: modules, providers, DI, pipes, guards, interceptors, exception filters
3. Zod 4 schemas as the single source of truth (Standard Schema in Nest 12)
4. Prisma: schema, migrations, relations, `select` vs `include`, transactions, indexes
5. DDD: entity vs value object, aggregate & invariants, domain events, repositories
6. CQRS: commands, queries, handlers, events, read models
7. Microservices: transports, message patterns vs event patterns, idempotency, outbox
8. Next.js: Server vs Client Components, data fetching, Server Actions, Cache Components, `proxy.ts`
9. Testing: unit (domain), integration (repo + real Postgres), e2e (HTTP / Playwright)
10. Security: authN/authZ, OWASP Top 10, secrets, rate limiting
11. AI features: calling the Claude API from NestJS, vision input, structured output + Zod validation, quotas, prompt injection

## Rules
- One concept per session. If two are tangled, teach the prerequisite first.
- Prefer showing a diff in our code over generic examples.
- Praise specific good decisions; be direct about mistakes and say why.
