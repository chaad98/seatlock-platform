---
name: security-review
description: Use when a change touches authentication, authorization, sessions/tokens, personal data (PDPA), file uploads, AI/LLM calls, payments, multi-tenant data, inter-service messaging, secrets, CORS/headers, or before any release. Performs a threat model and OWASP-based review of the diff and blocks merge on findings.
---

# Security review

"Secure, no loophole" is a process, not a feeling. This skill reviews the diff as an attacker would.

## Procedure

1. **Scope**: list changed endpoints, message handlers, Server Actions, pages, DB tables, and what personal data they touch.
2. **Threat model (STRIDE-lite)** for each entry point — one line each:
   Spoofing (who can call it?) · Tampering (can input change other tenants' data?) · Repudiation (is it audited?) · Information disclosure (what leaks in responses/errors/logs?) · Denial of service (unbounded query/upload/loop?) · Elevation of privilege (role check server-side?).
3. **Run the checklist** below against the diff. Mark each ✓ / ✗ / n-a with file:line evidence.
4. **Report findings** by severity (Critical / High / Medium / Low) with a concrete fix. Critical or High = merge blocked.
5. Add a regression test for every finding fixed.

## Checklist

### AuthN / sessions
- [ ] Passwords hashed with argon2id (or bcrypt cost ≥ 12); never logged.
- [ ] Tokens: short-lived access token + rotating refresh token; refresh reuse detection; revocation on logout.
- [ ] Browser sessions use `HttpOnly; Secure; SameSite=Lax/Strict` cookies — no tokens in `localStorage`.
- [ ] Login, reset, OTP endpoints rate-limited (`@nestjs/throttler`) and give generic errors (no user enumeration).

### AuthZ / multi-tenancy
- [ ] Every endpoint/handler has an explicit guard; default-deny global guard; `@Public()` opt-out is reviewed.
- [ ] Every query filters by `tenantId` derived from the verified token, never from the request body (prevents IDOR / BOLA).
- [ ] Ownership checked on update/delete; test for "user B cannot touch user A's record".
- [ ] Next.js: authorisation re-checked inside every Server Action and Route Handler — `proxy.ts` alone is not authorisation.

### Input / output
- [ ] All external input parsed with Zod 4 `z.strictObject` (unknown keys rejected); lengths & sizes bounded.
- [ ] No raw SQL string concatenation; `$queryRaw` only with tagged template parameters.
- [ ] Responses mapped through response schemas/DTOs — no password hashes, internal IDs, stack traces.
- [ ] File uploads: type sniffed (not trusted from extension), size-limited, stored outside web root/object storage, virus-scan hook if public.

### Transport / headers / config
- [ ] `helmet` (backend) and strict CSP / security headers in Next.js config; CORS allowlist exact origins (frontend URL), credentials only where needed.
- [ ] Secrets only from env/secret manager, validated at boot with Zod; `.env*` git-ignored; no secrets in `NEXT_PUBLIC_*`.
- [ ] Inter-service traffic not exposed publicly; service-to-service auth (shared secret/mTLS/JWT) on message bus and internal HTTP.

### Data & PDPA (Malaysia)
- [ ] Personal data minimised; sensitive fields (passport, IC, health) encrypted at rest at column level where feasible.
- [ ] Audit log for create/update/delete of personal data (who, when, what).
- [ ] Retention & erasure path exists; breach-relevant events logged so a breach can be assessed quickly.

### AI features
- [ ] AI provider key only in backend env; the browser never calls the provider directly.
- [ ] Model output parsed with a Zod 4 `strictObject` before it touches the database; failures flagged for a human, not auto-saved.
- [ ] A human confirms AI-extracted data before it's stored (no silent writes).
- [ ] Uploaded text/images treated as data, never as instructions; system prompt can't be overridden by document content (prompt injection).
- [ ] Per-tenant quotas and rate limits on AI calls (cost-based DoS); usage logged.
- [ ] Uploaded files deleted after processing; users informed an AI provider processes their data (PDPA); provider retention policy checked.

### Availability
- [ ] Every list endpoint paginated with a max page size; request body size limits; timeouts on outbound calls; idempotency keys on retried commands.

### Supply chain
- [ ] New dependency justified, maintained, `npm audit` clean; lockfile committed.

## Rules
- Assume the frontend is hostile: every rule is enforced on the backend.
- Never "fix" by hiding the error message only — fix the cause.
