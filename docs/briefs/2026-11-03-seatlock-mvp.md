# SeatLock MVP (project brief)
Status: approved   Date: 2026-11-03   Repos: seatlock-web | seatlock-gateway | backend services (named by `domain-model`)

This is the project-level brief. Each feature later gets its own short brief that refines the criteria below.

## Problem
Organisers need to sell a fixed number of tickets for an event without ever selling more than exist, even when hundreds of people try to buy at the same moment. Attendees want to grab tickets quickly and know within minutes whether they got them. Tickets that are held but not paid for must go back on sale automatically.

## Ubiquitous language
| Term | Meaning |
|---|---|
| Event | Something people attend: title, venue, start/end time. Has one or more ticket types. |
| Ticket type | A priced category of an event ("General", "VIP") with a fixed capacity. |
| Hold | A temporary claim on N tickets (or specific seats) for 10 minutes while the attendee pays. |
| Order | The attendee's purchase of a hold. Pending → Confirmed or Failed. |
| Ticket | Proof of entry issued for a confirmed order, with a unique code. |
| Organiser | A user who creates and publishes events. |
| Attendee | A user who holds and buys tickets. |

## Actors & permissions
- **Visitor** (not signed in): browse published events and see availability.
- **Attendee**: everything a visitor can do, plus hold tickets, pay, and view **their own** orders and tickets.
- **Organiser**: create, edit and publish **their own** events, and view sales for **their own** events only.
- **Admin**: grant or revoke the Organiser role.
- **System**: expires holds, retries messages, sends emails.

## Acceptance criteria
### Phase 1: accounts and general admission
1. Given a visitor, when they register with an email and password, then an Attendee account is created and the password is stored with argon2id.
2. Given an email that is already registered, when someone registers with it, then the HTTP response is identical to a successful registration (no account enumeration), and the owner receives an "you already have an account" email.
3. Given a registered user, when they sign in, then they receive a 15-minute access token and a refresh token in an `HttpOnly`, `Secure`, `SameSite=Strict` cookie.
4. Given a valid refresh token, when it is used, then a new one is issued and the old one stops working (rotation).
5. Given a refresh token that was already rotated, when it is used again, then every refresh token in that login session is revoked (reuse detection).
6. Given more than 5 failed sign-ins in 1 minute for the same IP and email, when another attempt is made, then it is rejected with 429.
7. Given an Organiser, when they create an event with at least one ticket type (name, price in MYR, capacity), then it is saved as a Draft and is not visible publicly.
8. Given a Draft event whose start time is in the future, when its Organiser publishes it, then it appears in the public listing.
9. Given Organiser A, when they try to read or change Organiser B's event or sales, then they get 404 (the event's existence is not revealed).
10. Given published upcoming events, when a visitor opens the listing, then events are sorted by start time, 20 per page, using keyset (cursor) pagination, each showing remaining tickets per ticket type.
11. Given enough remaining tickets, when an Attendee holds 1–6 tickets of a ticket type, then a Hold expiring in 10 minutes is created and the remaining count drops immediately.
12. Given fewer remaining tickets than requested, when an Attendee tries to hold them, then the request fails with a "not enough tickets" error and nothing is held.
13. Given a Hold that is not paid within 10 minutes, when it expires, then its tickets go back on sale and the Hold is marked Expired.
14. Given an active Hold, when the simulated payment succeeds, then the Order is Confirmed, one Ticket with a unique unguessable code is issued per seat or place, and a confirmation email is sent.
15. Given an active Hold, when the simulated payment is declined, then the Order stays Pending and the Attendee can retry until the Hold expires.
16. Given a payment that succeeds after its Hold has already expired, when the result arrives, then the payment is automatically reversed (compensation), the Order is marked Failed, and the Attendee is emailed.
17. Given the same pay request sent twice with the same `Idempotency-Key`, when both are processed, then the Attendee is charged once.
18. Given 1,000 concurrent requests, each holding 1 ticket of a type with capacity 500, when they all finish, then exactly 500 succeed, 500 get "not enough tickets", 0 are oversold, and p95 hold latency is under 300 ms (k6, local machine).

### Phase 2: reserved seating
19. Given a ticket type, when its Organiser defines a seat grid (sections × rows × seats), then each seat can be held individually.
20. Given two Attendees holding the same seat at the same moment, when both requests finish, then exactly one succeeds.
21. Given a seat that was just held or released, when anyone views the seat map, then the change shows within 2 seconds (eventually consistent read model).

## Business rules & invariants
- Per ticket type: `held + sold <= capacity`, always.
- A seat has at most one active Hold or one sale.
- A Hold contains at most 6 tickets. An Attendee has at most one active Hold per event.
- Hold expiry uses the server clock only, never the client's.
- Money is integer sen (MYR minor units), never floating point.
- Capacity can be lowered only down to `held + sold`.
- Ticket sales close when the event starts.
- A Confirmed Order and its Tickets never change.

## Edge cases & failure modes
- Double-clicked "Hold" or "Pay" buttons: idempotency keys prevent duplicates.
- A Hold expires while its payment is in flight: rule 16 (compensation).
- The payment service is slow or down: the request times out, the Order stays Pending, and it retries until the Hold expires.
- The same NATS message is delivered twice: consumers are idempotent and record processed message IDs.
- A service crashes after saving but before publishing its event: the transactional outbox publishes it on restart.
- A user touches someone else's resource: 404. An unauthenticated request: 401. A user lacking the role: 403.
- An expired or stolen refresh token: criteria 4–5.

## Non-functional requirements
- **Security:** only the gateway is reachable from outside. Default-deny auth guard. Strict Zod validation on every input (HTTP and NATS). Rate limiting on auth routes. `helmet` and exact-origin CORS. No stack traces in responses. The owner is always taken from the verified token, never from the request body. Checked against the OWASP Top 10.
- **Personal data (PDPA):** store only email, display name and password hash. Logs never contain passwords, tokens or full card-like data.
- **Performance:** criterion 18. Public listing p95 under 200 ms for 10k events (local). Every new query is checked with `EXPLAIN ANALYZE`.
- **Frontend:** Lighthouse 100 in all four categories on home, event listing, event detail and sign-in pages, with zero axe violations on every page.
- **Observability:** a correlation ID travels from the browser through the gateway and NATS to every service, and appears in every log line.

## Out of scope (MVP)
Attendee-requested refunds, resale and transfers, waitlists, discount codes, multiple currencies, real email delivery (Mailpit locally), PDPA data export, account deletion (planned later), event cancellation, organiser payouts, drawing seat maps (grid only), native mobile app, translations.

## Assumptions (decided on the developer's behalf)
- Defaults chosen in clarify round 1: three roles (1a), general admission first then seats (2a), 10-minute hold with a simulated payment service (3a), load target as criterion 18 (4a), out-of-scope list confirmed (5).
- Single currency MYR. Times stored in UTC, shown in Asia/Kuala_Lumpur.
- Access token 15 minutes, refresh token 7 days.
- An Admin grants the Organiser role. The first Admin is created by a seed script.
- Email verification is not required to hold tickets in the MVP.
- The simulated payment service can be told to succeed, decline, or delay, so failures can be tested.

## Open questions
- None blocking. `domain-model` decides which bounded contexts become the 2–3 services.
