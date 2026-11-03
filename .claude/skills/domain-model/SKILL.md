---
name: domain-model
description: Use after a brief is approved and before planning code for any backend feature that adds or changes business rules, entities, aggregates, events, or a microservice boundary. Produces the DDD model (bounded context, aggregates, invariants, commands, queries, events) that CQRS code is generated from.
---

# Domain model (DDD design step)

Code follows the model, not the other way round. This skill turns an approved brief into a domain model the developer understands and agrees with.

## Inputs
- Approved brief in `docs/briefs/`.
- Existing context map at `docs/domain/context-map.md` (create it if missing).

## Procedure

1. **Event storming (lightweight).** List, in past tense, the domain events the feature produces, in time order: `SeatReserved`, `BookingConfirmed`, `ReservationExpired`. Ask the developer to correct names — these become code names.
2. **Find the commands** that cause each event (`ReserveSeat`) and the actor who issues them.
3. **Find the bounded context** each command belongs to. Ask: "Which team/vocabulary owns this word?" If a word means different things in two places (e.g. *Customer* in Identity vs *Attendee* in Booking), that's two contexts.
4. **Design aggregates.** For each aggregate write:
   - Aggregate root and its entities/value objects
   - **Invariants** it must protect in a single transaction (e.g. `reservedSeats <= event.capacity`)
   - Rule of thumb: small aggregates; reference other aggregates by ID only; one aggregate per transaction; cross-aggregate consistency is eventual (via events).
5. **Value objects** for every concept with rules: `Email`, `Money`, `DateRange`, `SeatNumber`, `Capacity`. Immutable, validated in the factory (Zod 4 inside, domain error outside).
6. **Queries & read models.** List what screens/APIs need to read. Design denormalised read models when a query would otherwise join across aggregates or services.
7. **Integration events** (crossing a service boundary) vs **domain events** (inside one service). Integration events are versioned contracts: `booking.seat-reserved.v1`.
8. **Write the model** to `docs/domain/<context>/<feature>.md` using the template. Update `context-map.md` if a boundary changed.

## Template

```markdown
# <Feature> — domain model
Context: <bounded context / microservice>

## Ubiquitous language (term → meaning)
## Aggregates
### <AggregateRoot>
- Entities / value objects:
- Invariants (each becomes a unit test):
- Commands it handles → events it emits:
## Value objects (name → validation rules)
## Queries & read models
## Domain events (internal)
## Integration events (published, versioned) / consumed
## Consistency notes (what is eventual, and the compensation if it fails)
```

## Microservice boundary checklist
Split into a separate service ONLY if most are true:
- Different ubiquitous language / owner
- Can be deployed and fail independently without breaking the other's core flow
- Owns its data (its own schema/database); no other service reads its tables
- Communicates by events or explicit API, never shared DB joins
If not, keep it a module inside an existing service (modular monolith first).

## Rules
- No framework or Prisma types in the domain layer — pure TypeScript.
- Every invariant listed here must have a unit test in `gates`.
