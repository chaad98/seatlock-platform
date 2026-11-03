# 0001 · ES modules and Vitest for every backend repo
Status: accepted   Date: 2026-11-03

## Context
NestJS 12 core packages ship as ES modules only. A CommonJS app can still load them through Node's `require(esm)` support, and Jest can load them only on Node 24.9 or later. The official starter (`nestjs/typescript-starter`) and `nest new` default to ESM with Vitest. Sources: https://docs.nestjs.com/migration-guide , https://docs.nestjs.com/first-steps

## Decision
- Every backend repo uses `"type": "module"` in `package.json`, with `"module": "nodenext"` and `"moduleResolution": "nodenext"` in `tsconfig.json`.
- Vitest for unit and e2e tests, instead of the Jest that was originally planned.
- Files are written by hand. The official starter is the reference for packages and scripts. `@nestjs/cli` is only used to build and watch, never to generate.

## Consequences
- Relative imports need a `.js` extension (`import { AppModule } from './app.module.js'`), even in `.ts` files.
- Use `import.meta.dirname` instead of `__dirname`.
- Test code uses `vi.fn()` / `vi.spyOn()` where Jest used `jest.fn()` / `jest.spyOn()`. `describe` / `it` / `expect` are the same.

## Alternatives considered
- **CommonJS + Jest:** works, but depends on the `require(esm)` bridge and goes against the NestJS 12 defaults.

## Stack versions checked on 2026-11-03 (npm `latest` unless noted)
| Package | Version | Note |
|---|---|---|
| Node.js | 26.13.0 LTS | Node 24 is in maintenance |
| @nestjs/core, common, microservices | 12.3.2 | |
| @nestjs/cqrs | 12.1.2 | |
| @nestjs/cli | 12.0.11 | Pins TypeScript ~6.0.2 |
| TypeScript | 6.0.3 | **Not 7.x**: the Nest CLI pins ~6.0.2, and 7.0.2 has a decorator-metadata regression that NestJS DI depends on (https://github.com/microsoft/TypeScript/issues/64889). Upgrade when `@nestjs/cli` and the starter move to 7 |
| prisma, @prisma/client | 7.10.1 (pinned) | npm `latest` for `prisma` is 8.0.0-rc.29, so always install `prisma@7` |
| zod | 4.6.7 | |
| @nats-io/transport-node | 3.4.0 | |
| vitest | 5.1.0 | The starter still uses ^4.1.2. Check compatibility when the first repo is set up |
| next / react | 16.4.4 / 19.3.1 | |
