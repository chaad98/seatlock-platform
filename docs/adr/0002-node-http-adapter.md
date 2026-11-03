# 0002 · NodeAdapter for HTTP in the gateway
Status: accepted   Date: 2026-11-04

## Context
NestJS can serve HTTP through three adapters: Express (still the default), Fastify, and the Node adapter (`@nestjs/platform-node`). The docs say: "Starting with NestJS v12.3, we recommend the `NodeAdapter`". It runs directly on `node:http`, was the fastest in their benchmarks (about 50% more requests per second than Express), and becomes the default in NestJS 13. Source: https://docs.nestjs.com/techniques/performance

The gateway is the only HTTP service. Identity, ticketing and payments talk over NATS only.

## Decision
`seatlock-gateway` uses `NodeAdapter` from `@nestjs/platform-node`. Express is not installed.

## Consequences
- We start on what NestJS 13 will use by default, so there's no adapter migration later.
- The middleware we plan to use (`helmet`, `cookie-parser`) works with it, per the docs.
- Not available: `res.render()`, `res.download()`, `req.accepts()`, mounting Express apps. We don't need any of these.
- Routes are case-sensitive and match by specificity, not by registration order.
- A string returned from a handler is sent as `text/plain`. Our handlers return objects (JSON).
- Tests must create the app with `new NodeAdapter()`. Otherwise Nest looks for Express, which isn't installed.
- Behind a proxy (Oracle VM, later), `trustProxy` must be set as an adapter option to read `X-Forwarded-*` headers.

## Alternatives considered
- **Express:** most tutorials use it, but it's slower and stops being the default in v13.
- **Fastify:** fast, but has its own plugin system, so Express-style middleware doesn't plug in directly.
