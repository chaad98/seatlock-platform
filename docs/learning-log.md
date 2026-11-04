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
