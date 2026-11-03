# Learning log
One line per concept: date · concept · takeaway · official doc.

- 2026-11-03 · NestJS modules · `providers` live inside a module; `exports` are the subset other modules get when they import it · https://docs.nestjs.com/modules
- 2026-11-03 · Dependency injection · Modules are singletons: import the module that exports a provider, don't re-list the provider, or you get a second instance · https://docs.nestjs.com/modules
- 2026-11-03 · Request lifecycle · middleware → guards → interceptors → pipes → handler → interceptors → filters; guards run before validation, so they read only the token · https://docs.nestjs.com/faq/request-lifecycle
- 2026-11-03 · ESM vs CommonJS · NestJS 12 ships ESM-only; ESM needs `.js` extensions on relative imports · https://docs.nestjs.com/migration-guide
- 2026-11-04 · Invariant · A rule that must always be true, e.g. `held + sold <= capacity`; read `a <= b` as "a fits inside b" · [booking model](domain/booking/mvp.md)
- 2026-11-04 · Bounded context ownership · Whoever has the data needed to check a rule owns that rule; Booking owns capacity after publishing because only it knows held and sold · [context map](domain/context-map.md)
