# Identity: domain model (MVP)
Context: Identity → service `seatlock-identity`   Map: [context map](../context-map.md)

## Ubiquitous language
- **User**: a person with an account. Has one or more Roles.
- **Role**: `ATTENDEE` (everyone), `ORGANISER`, `ADMIN`.
- **Session**: one signed-in device. Owns a chain ("family") of refresh tokens.
- **Refresh token**: a long random secret, stored only as a hash, valid for one use.

## Aggregates
### User
- Entities / value objects: `UserId`, `Email`, `DisplayName`, `PasswordHash`, `Role[]`.
- Invariants (each becomes a unit test):
  - Always has `ATTENDEE`. Can't lose it.
  - Can't grant a role it already has, or revoke one it doesn't have.
  - Email is unique across users. That's a set rule the aggregate can't see, so it's enforced by a unique index on the normalised email. The handler turns a duplicate into `ExistingAccountRegistrationAttempted`.
- Commands → events: `RegisterUser` → `UserRegistered` | `ExistingAccountRegistrationAttempted` · `GrantOrganiserRole` → `OrganiserRoleGranted` · `RevokeOrganiserRole` → `OrganiserRoleRevoked`.

### Session
- Entities / value objects: `SessionId`, `UserId` (reference only), `RefreshTokenHash` (current), `ExpiresAt`, status `ACTIVE | REVOKED`, `version`.
- Invariants:
  - Only the **current** token can rotate. Presenting any earlier token revokes the session (reuse detection, criterion 5).
  - A revoked or expired session can't rotate.
  - Rotation replaces the hash and keeps `ExpiresAt` (the 7-day limit isn't extended forever).
- Commands → events: `SignIn` → `UserSignedIn` (new Session) · `RotateRefreshToken` → `RefreshTokenRotated` | `RefreshTokenReuseDetected` + `SessionRevoked` · `SignOut` → `UserSignedOut`.

## Value objects
| Name | Rules |
|---|---|
| `Email` | `z.email()`, trimmed, lower-cased, max 254 chars |
| `DisplayName` | 1–50 chars after trimming |
| `PlainPassword` | 12–128 chars. Exists only in memory during register and sign-in, never stored or logged |
| `PasswordHash` | argon2id output string. Compared through a `PasswordHasher` port |
| `RefreshTokenHash` | SHA-256 of a 256-bit random token. The raw token goes only into the cookie |

## Ports (application layer)
`PasswordHasher`, `TokenSigner` (signs the access JWT with a private key), `Clock`, `IdGenerator`, `Mailer`.

## Queries & read models
- `GetMe` (own profile) and `ListUsers` (admin only, keyset by `createdAt, id`). No read model needed.

## Domain events (internal)
All events above. `ExistingAccountRegistrationAttempted` → send the "you already have an account" email.

## Integration events
- Published: none in the MVP. Other services learn about the user from the JWT claims the gateway forwards: `sub`, `roles`, `email`.
- Consumed: none.

## Consistency notes
- Granting a role doesn't change access tokens that were already issued. The new role applies at the next refresh, within 15 minutes. That's acceptable and documented.
