# Payments: domain model (MVP)
Context: Payments → service `seatlock-payments`   Map: [context map](../context-map.md)

## Ubiquitous language
- **Payment**: one attempt to take money for one order attempt. `REQUESTED → SUCCEEDED | DECLINED`, then `SUCCEEDED → REVERSED`.
- **Reversal**: giving money back automatically because the sale couldn't complete. This is not an attendee-requested refund, which is out of scope.
- **Simulation mode**: how the fake payment provider behaves: `SUCCEED`, `DECLINE` or `DELAY(ms)`.

## Aggregates
### Payment
- Entities / value objects: `PaymentId`, `OrderId` + `AttemptId` (references), `Money` amount, status, `ProviderReference`, `version`.
- Invariants (each becomes a unit test):
  - One payment per `(orderId, attemptId)`. Unique index, so a repeated request returns the existing payment.
  - Only a `REQUESTED` payment can succeed or be declined.
  - Only a `SUCCEEDED` payment can be reversed, and only once.
  - The amount is > 0 and can never change.
- Commands → events: `ChargePayment` → `PaymentSucceeded` | `PaymentDeclined` · `ReversePayment` → `PaymentReversed`.

## Value objects
| Name | Rules |
|---|---|
| `Money` | shared kernel: integer sen, `MYR` |
| `SimulationMode` | a `z.enum` of `SUCCEED`, `DECLINE`, `DELAY` plus delay 0–30,000 ms. Set by config locally, or per request in tests. Never accepted from the public API |

## Ports
`PaymentProvider` (the simulated provider in the MVP. A Stripe test-mode adapter can be added later without touching the domain), `Clock`, `IdGenerator`.

## Queries & read models
- None public in the MVP. `GetPayment(paymentId)` exists for tests and the admin view.

## Integration events
- Consumed: `booking.payment-requested.v1` → `ChargePayment`; `booking.payment-reversal-requested.v1` → `ReversePayment`. Both are idempotent through `processed_messages`.
- Published: `payments.payment-succeeded.v1`, `payments.payment-declined.v1`, `payments.payment-reversed.v1` (via the outbox).

## Consistency notes
- If the provider times out, the payment stays `REQUESTED` and a retry job asks the provider again. It never charges twice, because the provider call reuses the `PaymentId` as its idempotency key.
