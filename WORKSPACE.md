# SeatLock workspace

SeatLock is an event ticketing platform built as a **personal learning project**: production-grade full-stack engineering with Next.js, NestJS microservices, DDD, CQRS and secure APIs.

## Repos (polyrepo: each folder is its own git repo; the parent `SeatLock/` folder is not a repo)
| Repo | What it is | Local port | Status |
|---|---|---|---|
| `seatlock-platform` | Local infra (docker compose) and project-wide docs | - | ✅ created |
| `seatlock-gateway` | NestJS API gateway, the only public service | 4000 | 🚧 feature 01 in progress (step 4 of 7) |
| `seatlock-identity` | NestJS service: users, sessions, roles | NATS only | planned |
| `seatlock-ticketing` | NestJS service: Catalog + Booking modules | NATS only | planned |
| `seatlock-payments` | NestJS service: simulated payments | NATS only | planned |
| `seatlock-contracts` | npm package: versioned Zod 4 message schemas | - | planned |
| `seatlock-web` | Next.js 16 frontend | 3000 | planned |

## Local infrastructure (`seatlock-platform/docker-compose.yml`)
Start it with `docker compose up -d` from `seatlock-platform`. All ports listen on `127.0.0.1` only.

| Service | Image | Host port | Notes |
|---|---|---|---|
| Postgres | `postgres:18.6` | **5433** (5432 is taken by another Postgres on this PC) | One database and user per service, created by `postgres/init/01-create-service-databases.sql` |
| NATS | `nats:2.15.2-alpine` | 4222 (clients), 8222 (monitoring) | JetStream on, stored in `/data` |
| Mailpit | `axllent/mailpit:v1.33.0` | 1025 (SMTP), 8025 (web inbox) | Fake inbox for local emails |

| Database | User | Connection string (local only) |
|---|---|---|
| `identity` | `identity_app` | `postgresql://identity_app:identity_local_only@127.0.0.1:5433/identity` |
| `ticketing` | `ticketing_app` | `postgresql://ticketing_app:ticketing_local_only@127.0.0.1:5433/ticketing` |
| `payments` | `payments_app` | `postgresql://payments_app:payments_local_only@127.0.0.1:5433/payments` |

Init scripts run only on an empty volume. To re-run them: `docker compose down -v` (deletes all local data), then `docker compose up -d`.

## Key docs (in `seatlock-platform/docs`)
- Brief: `briefs/2026-11-03-seatlock-mvp.md` (approved)
- Domain model: `domain/context-map.md` (approved) and `domain/<context>/mvp.md`
- Decisions: `adr/` (0001: ESM + Vitest, with checked stack versions)
- Learning log: `learning-log.md`

## Workflow
clarify → domain-model → deep-plan → build (tests first) → security-review → gates → walkthrough → compound.
Run `fresh-docs` before using any framework API, and `teach` whenever the developer wants to understand something or write it themselves.
The skills live in `seatlock-platform/.claude/skills/<name>/SKILL.md`. Read the matching SKILL.md before each workflow step. Where a skill conflicts with "Working with the developer" below, the rules below win (for example, `teach` asks a check question, but this developer doesn't want quizzes).

## Stack decisions so far
- Node.js 26 LTS (via nvm-windows). TypeScript 6.0.x, **not 7**.
- Backend: NestJS 12, ESM (`"type": "module"`, `.js` extensions on relative imports), Vitest. Each repo is scaffolded with `nest new`, then shaped to the plan (see ADR 0001 update). Feature code (modules, controllers, DDD and CQRS classes) is written by hand, never generated with `nest g`.
- HTTP: `NodeAdapter` from `@nestjs/platform-node`, not Express (ADR 0002). Tests create apps with `new NodeAdapter()`.
- Monitoring: NestJS Observe (`@nestjs/observe`). Keys live in each repo's git-ignored `.env`, written by `npx @nestjs/observe link`. Never commit them.
- Prisma pinned to 7.x (npm `latest` is the 8.0 release candidate). Zod 4.

## Working with the developer
- They are a beginner at architecture with a year of NestJS CRUD experience. Explain basics briefly when they come up, in simple English with a small concrete example.
- **They write the code and run the commands themselves.** Give one small step at a time with exact commands, then wait for them to confirm (usually with a screenshot).
- Commands are for **Windows PowerShell 5.1**: one command per code block, never chain with `&&`.
- Say where a file goes (which repo, which folder) and how to create the folder.
- **Never use the long dash character** (em dash) in messages or files. Use a plain `-`.
- **No quiz or check-your-understanding questions** unless they ask for one.
- Git: small single-topic commits in Conventional Commits format (`docs:`, `chore:`, `feat:`, `fix:`, `test:`). Commit now, push later (no GitHub remotes yet).
- Ignore git's "LF will be replaced by CRLF" messages. There is no `.gitattributes`, so never mount a `.sh` script into a Linux container (Windows line endings break it). Use `.sql` or other formats instead.
