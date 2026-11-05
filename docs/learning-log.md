# Learning log
One line per concept: date · concept · takeaway · official doc.

- 2026-11-03 · NestJS modules · `providers` live inside a module; `exports` are the subset other modules get when they import it · https://docs.nestjs.com/modules
- 2026-11-03 · Dependency injection · Modules are singletons: import the module that exports a provider, don't re-list the provider, or you get a second instance · https://docs.nestjs.com/modules
- 2026-11-03 · Request lifecycle · middleware → guards → interceptors → pipes → handler → interceptors → filters; guards run before validation, so they read only the token · https://docs.nestjs.com/faq/request-lifecycle
- 2026-11-03 · ESM vs CommonJS · NestJS 12 ships ESM-only; ESM needs `.js` extensions on relative imports · https://docs.nestjs.com/migration-guide
- 2026-11-04 · Invariant · A rule that must always be true, e.g. `held + sold <= capacity`; read `a <= b` as "a fits inside b" · [booking model](domain/booking/mvp.md)
- 2026-11-04 · Bounded context ownership · Whoever has the data needed to check a rule owns that rule; Booking owns capacity after publishing because only it knows held and sold · [context map](domain/context-map.md)
- 2026-11-04 · Feature modules · Each feature gets its own folder and module (`health/health.module.ts`), and `AppModule` only imports them; response shapes live in their own file and are imported with `import type` · https://docs.nestjs.com/modules
- 2026-11-04 · Tests and adapters · `createNestApplication()` defaults to Express, so tests pass `new NodeAdapter()` · https://docs.nestjs.com/techniques/performance
- 2026-11-04 · Secrets in `.env` · `.env` is git-ignored; commit only the files you meant to change (`git add package.json`), and keep a `.env.example` with names but no real values · https://docs.nestjs.com/techniques/configuration
- 2026-11-04 · Monitoring with NestJS Observe · `npx @nestjs/observe link` writes the keys to `.env` and adds `--env-file .env` to the start scripts; turn it off in tests with `enabled: process.env.NODE_ENV !== 'test'` · https://docs.nestjs.com/devtools/observe
- 2026-11-05 · Validate config at boot · `ConfigModule.forRoot({ validationSchema: envSchema })` takes a Zod schema; a bad value (`PORT=abc`) stops the app at startup with a clear message, instead of breaking later · https://docs.nestjs.com/techniques/configuration
- 2026-11-05 · Zod coercion · Env values are always text, so `z.coerce.number()` turns `'4000'` into `4000`; `'abc'` becomes `NaN` and fails · https://zod.dev/api#coercion
- 2026-11-05 · Typed config · `ConfigService<Env, true>` with `get('PORT', { infer: true })` returns a real `number`, and a typo in the key is a compile error · https://docs.nestjs.com/techniques/configuration
- 2026-11-05 · Red for the right reason · A new test must fail because the feature is missing, not because of a missing import or a path typo (`../stc/`); read the failure before writing code · https://vitest.dev/guide/
- 2026-11-05 · Security headers · `app.use(helmet())` adds headers like `X-Content-Type-Options: nosniff` to every response · https://docs.nestjs.com/security/helmet
- 2026-11-05 · CORS is enforced by the browser · With one allowed origin the server always replies `Access-Control-Allow-Origin: <that origin>`; the browser compares it with the page's origin and blocks a mismatch. CORS protects browser users, it doesn't block curl or other servers · https://docs.nestjs.com/security/cors
- 2026-11-05 · One shared setup function · `setupApp(app)` is called by both `main.ts` and the e2e tests, so tests check the same app that runs in production · https://docs.nestjs.com/fundamentals/testing
- 2026-11-05 · `it.only` · Runs only that test and silently skips the rest, so a run looks green with fewer tests; check the count ("4 passed"). In CI, Vitest fails on `.only` by default · https://vitest.dev/config/#allowonly
