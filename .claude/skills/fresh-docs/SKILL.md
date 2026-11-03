---
name: fresh-docs
description: Use before writing or recommending code that calls a framework or library API (Next.js, React, NestJS, Prisma, Zod, Tailwind, shadcn, Playwright, Jest/Vitest, Node), when unsure an API is current, or when an error suggests a deprecated API. Verifies against the official docs and the installed version so no outdated pattern ships.
---

# Fresh docs (anti-deprecation)

Training data goes stale; this project has a hard rule of **no deprecated or outdated APIs**. This skill makes Claude check reality before writing code.

## Procedure

1. **Read the installed version** from `package.json` / lockfile (`npm ls <pkg>`). The installed major decides which docs apply.
2. **Fetch the official doc page** for the exact API, and if available the machine-readable index:
   - Next.js — https://nextjs.org/docs (append `.md` or use `llms.txt` when offered)
   - React — https://react.dev/reference
   - NestJS — https://docs.nestjs.com
   - Prisma — https://www.prisma.io/docs (v7 docs live under `/orm/v7`; check `release-status`)
   - Zod — https://zod.dev (v4 API; changelog at https://zod.dev/v4/changelog)
   - Tailwind — https://tailwindcss.com/docs ; shadcn — https://ui.shadcn.com/docs
   - Playwright — https://playwright.dev/docs
   - Claude API / `@anthropic-ai/sdk` — https://docs.claude.com (model names, structured outputs, vision input, pricing change often: never hardcode from memory)
3. **Check the deprecation list below** and the framework's latest upgrade guide.
4. **Write the code**, and put a one-line comment or PR note citing the doc URL for any non-obvious API.
5. If docs and installed version disagree, STOP and tell the developer — don't silently pick one.

## Known-deprecated in this stack (do not use) — refresh this list via `compound`

### Next.js 16+
- `middleware.ts` / `export function middleware` → use `proxy.ts` / `export function proxy` (Node runtime).
- `experimental.ppr`, `unstable_cache`, route-segment `revalidate` gymnastics → `cacheComponents: true` + `'use cache'` + `cacheLife`/`cacheTag`; `updateTag` / `revalidateTag` / `refresh` for invalidation.
- Pages Router (`pages/`), `getServerSideProps`, `getStaticProps`, `next/head` → App Router, async Server Components, Metadata API (`generateMetadata`).
- `next lint` → run ESLint (or the project linter) directly.
- Fetching your own Route Handler from a Server Component → call the backend/data function directly.
- Synchronous `params`/`searchParams`/`cookies()`/`headers()` → they are async; `await` them.

### NestJS 12+
- `class-validator` DTO classes as the validation source → Zod 4 schemas via Standard Schema support (`@Body({ schema })` / standard-schema pipe). Verify exact API in docs.
- `@nestjs/config` Joi-only `validationSchema` options → Standard Schema (Zod) `validationSchema`.
- `nats` package → `@nats-io/transport-node`.
- Webpack builder → `--builder rspack` (or default tsc/swc).

### Zod 4
- `z.string().email()/.uuid()/.url()/.ip()` → `z.email()`, `z.uuid()`, `z.url()`, `z.ipv4()`/`z.ipv6()`.
- `.strict()` / `.passthrough()` → `z.strictObject()` / `z.looseObject()`.
- `.merge()` → `.extend()` (or spread `.shape`).
- `z.nativeEnum()` → `z.enum()` (accepts TS enums).
- `message:` / `required_error` / `invalid_type_error` / `errorMap` → unified `error:` param.
- `error.errors` / `.format()` / `.flatten()` → `error.issues`, `z.treeifyError()`, `z.prettifyError()`.
- `.nonempty()` on strings → `.min(1)`; single-arg `z.record(v)` → `z.record(z.string(), v)`.

### Prisma 7 (current GA; Prisma 8 is RC — don't adopt until GA)
- `url`/`directUrl` in `schema.prisma` datasource → `prisma.config.ts` `datasource.url`.
- `prisma-client-js` generator with implicit output → `provider = "prisma-client"` + explicit `output`.
- `new PrismaClient()` without adapter → pass a driver adapter (`@prisma/adapter-pg`).
- `$use()` middleware → Client Extensions (`$extends`).
- Implicit `.env` loading → load env explicitly (`dotenv/config` in config / Nest ConfigModule).
- Pin `prisma@7` and `@prisma/client@7` — plain `npm i prisma` installs the v8 RC.

### Tailwind 4
- `tailwind.config.js` theme as primary config → CSS-first `@theme` in the global stylesheet; `@import "tailwindcss"`.

## Rules
- "I remember it works like…" is not verification. Fetch the page.
- When you learn a new deprecation, add it to this list through the `compound` skill.
