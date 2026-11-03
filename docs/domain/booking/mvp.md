# Booking: domain model (MVP)
Context: Booking → module `booking` in service `seatlock-ticketing`   Map: [context map](../context-map.md)

## Ubiquitous language
- **Inventory**: the sellable stock of one ticket type: `capacity`, `held`, `sold`.
- **Hold**: a 10-minute claim on 1–6 tickets. `ACTIVE → CONVERTED | EXPIRED`.
- **Order**: an attendee's attempt to pay for a hold. `PENDING → CONFIRMED | FAILED`.
- **Ticket**: proof of entry, issued only for a confirmed order.
- **Sold out**: `held + sold = capacity`.

## Aggregates
### Inventory (root, one per ticket type) with Hold entities
Why Hold lives inside Inventory: the rule "`held` equals the sum of active holds" ties them together, so they share one consistency boundary. The aggregate loads **counters plus the one hold being changed**, never every hold.
- Entities / value objects: `TicketTypeId`, `EventId`, `OrganiserId`, `Capacity`, `held`, `sold`, `Money` unit price (copied at publish), `salesCloseAt`, `version`; `Hold` (`HoldId`, `AttendeeId`, `Quantity`, `ExpiresAt`, status).
- Invariants (each becomes a unit test):
  - `held + sold <= capacity`, always (criteria 11, 12, 18).
  - `hold()` is rejected after `salesCloseAt`.
  - `Quantity` is 1–6.
  - Only an `ACTIVE`, unexpired hold can be converted, and only an `ACTIVE` hold can expire. Exactly one of those can happen.
  - `changeCapacity(n)` requires `n >= held + sold`.
  - One active hold per attendee per event. That's a set rule across ticket types, so it's enforced by a partial unique index on `(attendee_id, event_id) WHERE status = 'ACTIVE'`.
- Commands → events: `OpenInventory` → `InventoryOpened` · `HoldTickets` → `TicketsHeld` · `ExpireHolds` → `HoldExpired` (per hold, batched) · `ConvertHold` → `HoldConverted` | `HoldConversionRejected` · `ChangeCapacity` → `CapacityChanged` · `CloseSales` → `SalesClosed`. Any change to `remaining` also writes `booking.availability-changed.v1` to the outbox.

### Order (root) with Ticket entities
- Entities / value objects: `OrderId`, `HoldId` (reference), `AttendeeId`, `ContactEmail` (copied from the JWT at purchase), `Money` total, `IdempotencyKey`, status, `PaymentAttempt[]`, `Ticket[]` (`TicketId`, `TicketCode`), `version`.
- Invariants:
  - `total = quantity × unit price` at the time the order is placed.
  - At most one `PENDING` payment attempt at a time.
  - Tickets are issued exactly once, only on confirm. One ticket per held place.
  - `CONFIRMED` and `FAILED` are final. Nothing changes after that.
  - `(attendee_id, idempotency_key)` is unique, so a repeated `PayForHold` returns the existing order (criterion 17).
- Commands → events: `PayForHold` → `OrderPlaced` (+ outbox `booking.payment-requested.v1`) · `RetryPayment` → new attempt (criterion 15) · `ConfirmOrder` → `OrderConfirmed` + `TicketsIssued` · `FailOrder` → `OrderFailed` (+ outbox `booking.payment-reversal-requested.v1` if money moved).

## Value objects
| Name | Rules |
|---|---|
| `Quantity` | integer 1–6 |
| `HoldExpiry` | created from the `Clock` port: now + 10 minutes. Never from client input |
| `TicketCode` | 128-bit random value, base32, 26 chars |
| `IdempotencyKey` | `z.uuid()` from the `Idempotency-Key` header |
| `ContactEmail` | same rules as Identity's `Email`. A copy, not a link |
| `SeatId` (phase 2) | section 1–20 chars, row 1–5 chars, number 1–9999 |

## Ports
`Clock`, `IdGenerator`, `TicketCodeGenerator`, `Mailer`.

## Queries & read models
- `GetHold(holdId)`: the attendee's countdown page. Read straight from tables.
- `ListMyOrders(attendeeId)`: keyset by `(createdAt, id)`, includes tickets in one query (no N+1).
- `GetEventSales(eventId, organiserId)`: counts from Inventory. Returns 404 if `organiserId` doesn't match (criterion 9).
- Phase 2: a **`seat_map` read model** per ticket type, updated from hold and seat events within 2 s (criterion 21).

## Domain events (internal)
`InventoryOpened`, `TicketsHeld`, `HoldExpired`, `HoldConverted`, `HoldConversionRejected`, `CapacityChanged`, `SalesClosed`, `OrderPlaced`, `OrderConfirmed`, `TicketsIssued`, `OrderFailed`.

## Integration events
- Published: `booking.availability-changed.v1`, `booking.payment-requested.v1`, `booking.payment-reversal-requested.v1`.
- Consumed: `catalog.event-published.v1` → `OpenInventory`; `payments.payment-succeeded.v1` → `ConvertHold` → `ConfirmOrder` or `FailOrder`; `payments.payment-declined.v1` → record the failed attempt (order stays `PENDING`); `payments.payment-reversed.v1` → record it on the failed order.
- Every consumer stores the `messageId` in `processed_messages` in the same transaction as its change, so duplicates are skipped.

## Consistency notes
- **Payment after expiry** (criterion 16): `ConvertHold` is rejected → `FailOrder` → reversal requested. That's the compensation.
- **Hold expiry**: a scheduled job runs every 15 s and expires due holds in batches of 500, using a partial index on `expires_at WHERE status = 'ACTIVE'`.
- **Hot counter** (criterion 18): optimistic lock with retry vs conditional `UPDATE`. Decided in ADR 0003 after measuring both.
