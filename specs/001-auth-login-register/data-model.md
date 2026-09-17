# Phase 1 Data Model: Authentication (Login, Register, Guest Mode)

**Feature**: `001-auth-login-register` | **Date**: 2026-09-17

Domain entities live in `lib/features/auth/domain/entities/` as pure Dart — no Flutter, no Dio, no
JSON (Principle V). Each has a matching model in `lib/features/auth/data/models/` that extends it and
adds `fromJson`. Field names below are Dart names; the wire names are in `contracts/auth-api.md`.

---

## Enums

### `SocialProvider` (enhanced enum)

Carries its own wire name and platform rule so FR-029 has one place to ask (research R11).

| Value | `wireName` | Availability |
|---|---|---|
| `google` | `google` | Always |
| `apple` | `apple` | iOS and macOS only |

```dart
enum SocialProvider {
  google(wireName: 'google'),
  apple(wireName: 'apple');

  const SocialProvider({required this.wireName});
  final String wireName;

  bool get isAvailableOnThisPlatform =>
      this == SocialProvider.google || Platform.isIOS || Platform.isMacOS;
}
```

### `OtpPurpose` (enhanced enum)

One code type per purpose, so a code issued to verify an email can never be replayed to reset a
password (FR-046d, and the "single purpose" rule on the spec's One-Time Code entity).

| Value | `wireName` | Destination | Issued by |
|---|---|---|---|
| `verifyEmail` | `verify_email` | Email | Email-and-password registration |
| `phoneSignIn` | `phone_sign_in` | Phone | Phone sign-in, every attempt (FR-020) |
| `verifyPhone` | `verify_phone` | Phone | Social completion form (FR-033) |
| `resetPassword` | `reset_password` | Email | Forgotten-password recovery (FR-046) |

### `RegistrationSource` (enhanced enum)

Tells the completion form which fields to collect and which are already established.

| Value | Collects | Already verified / fixed |
|---|---|---|
| `phone` | full name, email, password, optional avatar | phone (verified, not editable) — FR-022, FR-023 |
| `google` | full name, phone, password, optional avatar | email (verified, not editable) — FR-031, FR-032 |
| `apple` | full name, phone, password, optional avatar | email (verified, not editable, may be a relay address) — FR-034 |

### Visitor state — reuse `UserType`, do not redefine

The spec's **Visitor State** entity is already `UserType` in `lib/core/utils/enums.dart`
(`firstOpen`, `loggedIn`, `guest`) with `isFirstOpen` / `isLoggedIn` / `isGuest` getters, persisted by
`UserTypeStorage` under the `userType` key. The auth feature reads and writes it; it introduces no
parallel enum (research R9).

| Spec concept | Existing value |
|---|---|
| First-time visitor | `UserType.firstOpen` |
| Guest | `UserType.guest` |
| Signed-in user | `UserType.loggedIn` |

---

## Entities

### `AuthUser` — the spec's **User Account**

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Server-assigned |
| `fullName` | `String` | Single field, per the spec's assumption |
| `email` | `String` | May be an Apple private relay address (FR-034) |
| `dialingCode` | `String` | `+966` form |
| `phone` | `String` | National significant number |
| `avatarUrl` | `String?` | Genuinely absent when the user provided none (FR-006c) |
| `isEmailVerified` | `bool` | False during email-and-password registration until the code is entered |
| `isPhoneVerified` | `bool` | False after email-and-password registration (FR-010); true on the phone-first and social paths |
| `createdAt` | `DateTime` | |

`avatarUrl` is the only nullable field: every other value is always present on a created account
(§5.1 — nullable means genuinely optional, not "unset").

### `AuthSession` — the spec's **Authentication Session**

| Field | Type | Notes |
|---|---|---|
| `accessToken` | `String` | Persisted to `AccessTokenStorage`; renewed by the existing `RefreshTokenHelper` |
| `user` | `AuthUser` | The account this session acts as |

There is no refresh token field: `RefreshTokenHelper` renews by presenting the current access token
to `/common/refresh-token` (research R6).

### `RegistrationDraft` — the spec's **Registration Draft**

| Field | Type | Notes |
|---|---|---|
| `registrationToken` | `String` | Short-lived server token authorizing completion; secret |
| `source` | `RegistrationSource` | Drives which fields the form collects |
| `verifiedEmail` | `String?` | Present for `google` / `apple`, absent for `phone` |
| `verifiedDialingCode` | `String?` | Present for `phone`, absent for social |
| `verifiedPhone` | `String?` | Present for `phone`, absent for social |
| `suggestedFullName` | `String?` | Apple/Google may supply a name; Apple only on first authorization |

Exactly one identifier group is populated, decided by `source`. Persisted as JSON in
`RegistrationDraftStorage` (secure storage) so a cold start can resume (FR-026, FR-036, FR-051).

### `AuthOutcome` (sealed) — the two-way result of verify and exchange

```dart
sealed class AuthOutcome {
  const AuthOutcome();
}

final class AuthSessionEstablished extends AuthOutcome {
  const AuthSessionEstablished(this.session);
  final AuthSession session;
}

final class AuthRegistrationRequired extends AuthOutcome {
  const AuthRegistrationRequired(this.draft);
  final RegistrationDraft draft;
}
```

Returned by phone-code verification and social exchange. Auto-linking an identifier to an existing
account (FR-041) simply yields `AuthSessionEstablished`, which is why FR-041b's "no completion form"
needs no extra flag.

### `OtpChallenge` — the client-visible half of the spec's **One-Time Code**

The code itself never reaches the client. What the client needs is what to display and when resend
becomes legal.

| Field | Type | Notes |
|---|---|---|
| `purpose` | `OtpPurpose` | |
| `maskedDestination` | `String` | e.g. `j•••@mail.com` — safe to display, satisfies FR-045 |
| `expiresInSeconds` | `int` | Drives the expiry message (FR-013) |
| `resendAvailableInSeconds` | `int` | Seeds `OtpCooldownCubit` (FR-012) |

### `Credential` and `Social Identity` — intentionally not client entities

The spec lists both. Neither is modeled on the client: a `Credential` is "never readable back to
anyone", and a `Social Identity` is a server-side link the client only ever influences by presenting a
provider token. Adding client classes for them would be data with no reader.

---

## Operation response entities

Following the existing convention (`GetStudentProfileResponse` wrapping `status` / `message` / `data`),
each repository method returns a `*Response` entity in `domain/entities/`:

| Response entity | `data` payload |
|---|---|
| `LoginResponse` | `AuthSession` |
| `RegisterResponse` | `OtpChallenge` (registration sends an email code; no session yet — FR-009) |
| `VerifyEmailResponse` | `AuthSession` (verification completes registration and signs in — FR-011) |
| `RequestOtpResponse` | `OtpChallenge` (shared by email resend and phone-code request) |
| `VerifyPhoneOtpResponse` | `AuthOutcome` |
| `SocialSignInResponse` | `AuthOutcome` |
| `CompleteRegistrationResponse` | `AuthSession` |
| `RequestPasswordResetResponse` | `OtpChallenge` |
| `ResetPasswordResponse` | `AuthSession` (reset signs the user in — FR-046c) |
| `LogoutResponse` | `void`-like: `status` and `message` only |

Local-only operations return plain values, not `*Response` wrappers, because there is no envelope:
`resolveVisitorState` returns `UserType`, `readRegistrationDraft` returns `RegistrationDraft?`.

---

## Validation rules

Enforced client-side for immediate feedback; the backend remains the authority.

| Field | Rule | Source |
|---|---|---|
| Full name | Required, non-empty | FR-006 |
| Email | Required, valid format | FR-006, FR-007 |
| Phone | Required, valid for its dialing code via `PhoneValidationService` | FR-007, FR-027 |
| Password | ≥ 8 characters, ≥ 1 letter, ≥ 1 digit; no case or symbol requirement | FR-007a, FR-007b |
| Avatar | Optional; JPEG or PNG; downscaled to ≤ 1024 px longest edge; ≤ 2 MB after downscale | FR-006a |
| One-time code | Required, exactly 6 digits | Spec assumption |

Every rule is applied through one `AuthValidators` holder so the same password rule literally cannot
differ between registration, the two completion forms, and password reset (FR-007b).

---

## State transitions

### Account lifecycle

```text
                  register (email+password)
none ────────────────────────────────────────▶ unverified email, unverified phone
                                                        │ verify email code
                                                        ▼
                                               verified email, unverified phone
                                                        │ later signs in by phone code
                                                        ▼ (FR-041a)
                                               verified email, verified phone

                  verify phone code (no account)
none ────────────────────────────────────────▶ RegistrationDraft(source: phone)
                                                        │ complete form
                                                        ▼
                                               verified phone, unverified email (FR-024)

                  social exchange (no account)
none ────────────────────────────────────────▶ RegistrationDraft(source: google|apple)
                                                        │ complete form + phone code (FR-033)
                                                        ▼
                                               verified email, verified phone
```

### Visitor state

```text
                 ┌──────────── sign out (FR-043) ───────────┐
                 │                                          │
                 │              session unrenewable (FR-044) │
                 ▼                                          │
firstOpen ──▶ guest ──── any completed auth path (FR-040) ──▶ loggedIn
    │                                                        ▲
    └────────────── any completed auth path ──────────────────┘
```

A returning guest whose stored value is missing or unreadable is treated as `firstOpen`, which is
already the behavior `UserType.fromString` provides via its `orElse` fallback — except that it falls
back to `guest`. The spec's edge case wants first-time-visitor treatment, so the auth repository maps
a **missing** value to `firstOpen` explicitly rather than relying on that fallback.

### One-time code

```text
issued ──▶ valid ──┬── correct entry ──▶ used (further entries rejected, FR-046d)
                   ├── wrong entry ×N ──▶ attempt cap reached, cooldown
                   ├── expiry elapsed ──▶ expired (FR-013)
                   └── newer code issued ─▶ superseded (FR-012)
```
