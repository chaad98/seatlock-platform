# Catalog: domain model (MVP)
Context: Catalog → module `catalog` in service `seatlock-ticketing`   Map: [context map](../context-map.md)

## Ubiquitous language
- **Event**: something people attend, described for the public. Lifecycle `DRAFT → PUBLISHED`.
- **Ticket type**: a named, priced category of an event, with a starting capacity.
- **Schedule**: when the event starts and ends.
- **Listing**: the public, read-only view of published upcoming events.

## Aggregates
### Event (root) with TicketType entities
- Entities / value objects: `EventId`, `OrganiserId` (a user ID, reference only), `EventTitle`, `Venue`, `Schedule`, `TicketType[]` (`TicketTypeId`, `TicketTypeName`, `Money` unit price, `Capacity`), status, `version`.
- Invariants (each becomes a unit test):
  - Only its organiser can change it. The handler checks this, and the aggregate keeps `OrganiserId` unchanged forever.
  - At most 10 ticket types. Names are unique within the event, ignoring case.
  - Publishing needs at least 1 ticket type and a start time in the future.
  - After publishing, ticket types can't be removed and prices can't change. Capacity changes go to Booking (`ChangeCapacity`).
  - A published event can't go back to draft.
- Commands → events: `DraftEvent` → `EventDrafted` · `AddTicketType` → `TicketTypeAdded` · `UpdateEventDetails` → `EventDetailsUpdated` · `PublishEvent` → `EventPublished`.

## Value objects
| Name | Rules |
|---|---|
| `EventTitle` | 3–120 chars after trimming |
| `Venue` | name 1–120 chars, address 1–300 chars |
| `Schedule` | `startsAt < endsAt`, both UTC. Maximum length 30 days |
| `Money` | integer sen ≥ 0, currency `MYR`. Shared kernel |
| `Capacity` | integer 1–100,000 |
| `TicketTypeName` | 1–50 chars |

## Queries & read models
- **`event_listing` read model** (justified: it combines Catalog data with Booking's remaining counts, so it would otherwise need a cross-context join). One row per published ticket type. It's rebuilt from `EventPublished` and `booking.availability-changed.v1`. Index: `(startsAt, eventId)` for keyset paging (criterion 10).
- `GetPublicEvent(eventId)`: reads the listing read model.
- `ListMyEvents(organiserId)`: reads the Event table, keyset by `(createdAt, id)`.

## Domain events (internal)
`EventDrafted`, `TicketTypeAdded`, `EventDetailsUpdated`, `EventPublished`.

## Integration events
- Published: `catalog.event-published.v1`, written to the outbox in the same transaction as `PublishEvent`.
- Consumed: `booking.availability-changed.v1` → update `event_listing.remaining`. The consumer is idempotent and ignores events with an older `occurredAt` than the stored row.

## Consistency notes
- Right after publishing, the listing shows `remaining = capacity` until Booking's first availability event arrives. That's correct, because nothing can be held before Booking opens the inventory.
