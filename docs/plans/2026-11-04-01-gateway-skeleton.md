# Plan: 01 · Gateway skeleton
Status: approved   Date: 2026-11-04   Repo: `seatlock-gateway` (new)
Brief: [SeatLock MVP](../briefs/2026-11-03-seatlock-mvp.md) (non-functional requirements: security, observability)   Model: none (no business rules in this feature)   ADRs: [0001](../adr/0001-esm-and-vitest.md), [0002](../adr/0002-node-http-adapter.md)

## Summary
Create `seatlock-gateway` by hand: a NestJS 12 app on port 4000 with a health endpoint, environment validated by Zod at boot, and a security baseline (helmet, exact-origin CORS, JSON errors without stack traces).
No auth, no NATS and no database yet. Those arrive in later features and build on this one.
Reference: the official `nestjs/typescript-starter` (commit `da4aab8`, 27 Oct 2026). Differences from it are listed below.

## Acceptance criteria (each becomes a test)
1. Given the app is running, when `GET /health` is called, then it returns `200` with `{"status":"ok"}`.
2. Given an invalid environment (for example `PORT=abc`), when the app starts, then it refuses to start and the error names `PORT`.
3. Given any response, then it includes helmet's security headers (for example `X-Content-Type-Options: nosniff`).
4. Given a request from `http://localhost:3000` (the `WEB_ORIGIN`), then the response allows that origin. Given a request from any other origin, then it doesn't.
5. Given an unknown route, then the response is a JSON `404` with no stack trace.
6. `npm run typecheck`, `lint`, `test`, `test:e2e` and `build` all pass, and `npm run start:prod` serves `/health`.

## Steps (each step = one small commit, test written before code)
1. [x] **Scaffold with the CLI.** `nest new seatlock-gateway` (global CLI 12.0.11), choosing ESM, npm, and Observe: yes. Commit the untouched scaffold as `chore: scaffold gateway with nest new`, so the next commit's diff shows exactly what we changed.
2. [x] **Shape the scaffold to the plan.** Remove the packages and files listed under "Differences from the starter", install our packages pinned with `--save-exact`, switch `main.ts` to `NodeAdapter`, adjust `tsconfig.json`, add the `typecheck` script and `engines.node >= 26`. Commit `chore: shape gateway scaffold for SeatLock`.
3. [x] **Health endpoint (criterion 1).** Test first: `test/health.e2e-spec.ts`. Then a `health` feature module: `health-status.ts` (response type), `health.controller.ts`, `health.module.ts`, imported by `AppModule`. The `nest new` samples (`AppController`, `AppService` and their tests) were removed. Commit `feat: add health endpoint`. `app.setup.ts` moved to step 5, the first step that has setup code to share.
   - [x] **Connect Observe** (extra step). `npx @nestjs/observe link` wrote the key pair to `.env` (git-ignored) and added `--env-file .env` to the `start`, `start:dev` and `start:debug` scripts. It also created an `AGENTS.md`, which we deleted: that note goes into the repo's `CLAUDE.md` in step 6. Verified: the dashboard shows `GET /health` requests. Commit `chore: connect gateway to Observe`.
4. [ ] **Validate the environment at boot (criterion 2).** Test first: `src/config/env.schema.spec.ts` (defaults apply; `PORT` text becomes a number; `PORT=abc` fails and names `PORT`). Then `src/config/env.schema.ts` (`NODE_ENV`, `HOST` default `127.0.0.1`, `PORT` default `4000`) and `ConfigModule.forRoot({ validationSchema, ignoreEnvFile: true, isGlobal: true })`. `ignoreEnvFile` because Node's `--env-file` already loads `.env`, so there's one loader, not two. `main.ts` reads `HOST` and `PORT` from `ConfigService`. Add `.env.example`. Commit `feat: validate environment with Zod at boot`.
5. [ ] **Security baseline (criteria 3, 4, 5).** Tests first in `test/security.e2e-spec.ts`. Then create `src/app.setup.ts`, shared by `main.ts` and the e2e tests: `helmet()`, `enableCors({ origin: WEB_ORIGIN })`, `enableShutdownHooks()`. Add `WEB_ORIGIN` to the env schema. Commit `feat: add security headers and CORS`.
6. [ ] **Repo docs.** `CLAUDE.md` (the pack's backend template, adapted for one-service-per-repo), `README.md` (how to run and test). Commit `docs: add gateway CLAUDE.md and README`.
7. [ ] **Gates and walkthrough (criterion 6).** Run every check, then `npm run build` and `npm run start:prod`. Write `docs/walkthroughs/01-gateway-skeleton.md` (gateway repo) and `docs/roadmap.md` (platform repo). Commit in each repo.

## Packages (checked on npm, 2026-11-04)
| Package | Version | Why |
|---|---|---|
| `@nestjs/common`, `@nestjs/core` | 12.3.2 | NestJS itself |
| `@nestjs/platform-node` | 12.3.2 | HTTP adapter (ADR 0002) |
| `@nestjs/observe` | 0.3.22 | Monitoring dashboard (the CLI installed 0.1.10, upgraded in step 2) |
| `@nestjs/config` | 12.0.1 | Loads `.env` and validates it with a Standard Schema (Zod) |
| `zod` | 4.6.7 | Validation |
| `helmet` | 8.3.0 | Security headers |
| `reflect-metadata` | 0.2.2 | Needed by NestJS dependency injection |
| `rxjs` | 7.8.2 | Needed by NestJS |
| dev: `typescript` | 6.0.3 | ADR 0001 |
| dev: `@nestjs/cli` | 12.0.11 | Build and watch only (`nest build`, `nest start --watch`) |
| dev: `@nestjs/testing` | 12.3.2 | Builds test apps |
| dev: `vitest`, `@vitest/coverage-v8` | 4.1.12 | Same major version as the starter. Vitest 5 is out, but the starter hasn't moved yet |
| dev: `supertest`, `@types/supertest` | 7.3.1, 7.2.1 | HTTP calls in e2e tests |
| dev: `@types/node` | 26.6.6 | Matches Node 26 |
| dev: `oxlint` | 1.91.0 | Linter used by the starter |
| dev: `prettier` | 3.9.10 | Formatter |

## Differences from the starter, and why
- **Removed** `@nestjs/platform-express` and `@types/express`: we use `NodeAdapter` (ADR 0002).
- **Kept** `@nestjs/observe` (developer's choice, to learn it): hosted NestJS monitoring with a free tier. Needs an account; `OBSERVE_APP_KEY` and `OBSERVE_APP_SECRET` go in `.env` (never committed) and are validated by the env schema. Check in step 2 that it works with `NodeAdapter`.
- **Removed** `@nestjs/mau`: NestJS's hosted deployment platform. We deploy to Oracle Cloud and Vercel instead.
- **Removed** `@nestjs/schematics`: it's only used to generate files, and we write files by hand.
- **Removed** `vite-tsconfig-paths`: it's only needed for path aliases, and we don't use any.
- **Removed** `importHelpers` from tsconfig and the `tslib` package. With `importHelpers`, the compiled code needs `tslib` at runtime, but the starter lists it only as a dev dependency, which breaks a production install. Without it, there's one less package.
- **Removed** `source-map-support`: Node has this built in (`node --enable-source-maps`).
- **Added** stricter TypeScript checks: `noUncheckedIndexedAccess`, `noImplicitOverride`.
- **Added** `typecheck` script, `engines.node`, and exact version pinning.

## Contracts
- `GET /health` → `200 {"status":"ok"}`. Public. No request body.
- No NATS messages yet.

## Data-access strategy
None in this feature (no database).

## Test list
| Criterion | Test type | File |
|---|---|---|
| 1 | e2e | `test/health.e2e-spec.ts` |
| 2 | unit | `src/config/env.schema.spec.ts` |
| 3, 4, 5 | e2e | `test/security.e2e-spec.ts` |
| 6 | gates | all scripts |

## Security notes
- The app listens on `HOST` (default `127.0.0.1`), so it's not reachable from your Wi-Fi during development.
- `/health` is public by design. It reveals nothing except "ok".
- The default-deny auth guard and rate limiting come with the auth feature. Until then, the gateway exposes nothing except `/health`.

## Risks
- **Vitest and decorator metadata.** NestJS DI needs `emitDecoratorMetadata`. The starter's Vitest config has no special plugin, so its transformer must handle it. Step 3 is the first test with DI and will prove it either way. If it fails, we add the SWC plugin and record why.
- **NodeAdapter in tests.** `createNestApplication()` defaults to Express. Every test must pass `new NodeAdapter()`. We avoid repeating this by sharing one `app.setup.ts` between `main.ts` and the tests.

## ADRs created
- [0002 · NodeAdapter for HTTP in the gateway](../adr/0002-node-http-adapter.md)
