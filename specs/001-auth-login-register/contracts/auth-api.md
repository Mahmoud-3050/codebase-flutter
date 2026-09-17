# Contract: Authentication HTTP API

**Feature**: `001-auth-login-register` | **Date**: 2026-09-17

The backend is the external interface this feature consumes. Endpoints marked **existing** are
already declared in `lib/core/api/api_constants.dart`; endpoints marked **new** must be added there
*and* to `ApiConstants.publicAuthPaths`, or the interceptor will attach a stale bearer token and
attempt a pointless refresh on 401 (research R6).

Base URL comes from `ApiConstants.baseUrl` (flavor-dependent).

---

## Envelope

Every response uses the app's existing envelope, which `ApiResponse.isSuccess` already understands:

```json
{ "status": "success", "message": "Human readable", "data": { } }
```

Failure handling, already implemented in `dio_exception_mapper.dart` and `api_response.dart`:

| HTTP | Body condition | Mapped exception | Error copy id |
|---|---|---|---|
| 200 | `status != "success"` | `ApiResponse.exceptionOf` → `ServerException` or `ValidationException` | matching field or generic row |
| 422, or 400 with `errors` | — | `ValidationException(fieldErrors)` | per-field messages via `FieldErrorsScope` |
| 401 | login | `UnauthorizedException` | `invalid_credentials` (FR-016) |
| 409 | register email taken | `ConflictException` | `email_taken` (FR-008) |
| 409 / 422 | complete-registration token expired or consumed | `ConflictException` / `ValidationException` | `draft_expired` (FR-026a) |
| 429 | — | `TooManyRequestsException` | `too_many_attempts` (FR-018, FR-018a, SC-009) |
| timeout / offline | — | `InternetConnectionException` | `no_internet` |

Field-error keys must be the wire field names (`full_name`, `email`, `dialing_code`, `phone`,
`password`, `code`, `avatar`) so `AppTextFormField`'s `fieldName` lookup resolves them. The lookup
already tries snake_case and camelCase variants.

---

## Endpoints

### 1. `POST /auth/register` — existing

Email-and-password registration. Multipart when an avatar is attached (FR-005, FR-009).

Request (`multipart/form-data`, or JSON when no avatar):

| Field | Type | Required |
|---|---|---|
| `full_name` | string | yes |
| `email` | string | yes |
| `dialing_code` | string (`+966`) | yes |
| `phone` | string (NSN) | yes |
| `password` | string | yes |
| `avatar` | file (JPEG/PNG, ≤ 2 MB) | no |

Response `data` — an OTP challenge, **not** a session. Registration does not sign the user in until
the email code is verified.

```json
{
  "purpose": "verify_email",
  "masked_destination": "j•••@mail.com",
  "expires_in_seconds": 600,
  "resend_available_in_seconds": 60
}
```

Errors: `409` when the email belongs to an account (FR-008); `422` for field validation.

---

### 2. `POST /auth/verify-email` — existing

Verifies the registration code, marks the email verified, and establishes the session (FR-011).

Request: `{ "email": "...", "code": "123456" }`

Response `data`: a session envelope (see **Session payload** below).

Errors: `422` with `code` field error for a wrong code (`invalid_code`); `410` or `422` for an expired code (`expired_code`) — either
must carry a message that explains how to get a new one (FR-013). A fifth consecutive wrong guess for the **current** code returns `429` (`too_many_attempts`, FR-018a). A code already used returns
`409` (FR-046d applies the same rule to reset codes).

---

### 3. `POST /auth/email-otp/request` — **new**

Sends or resends an email code. Serves both the initial send and the resend action, and is also the
throttling point for FR-012 and SC-009.

Request: `{ "email": "...", "purpose": "verify_email" }`

Response `data`: OTP challenge (same shape as endpoint 1).

Errors: `429` when inside the cooldown, with `resend_available_in_seconds` in `data` so the client
can re-seed its countdown rather than guess.

---

### 4. `POST /auth/login` — existing

Email-and-password sign-in. Never issues an email code (FR-015).

Request: `{ "email": "...", "password": "..." }`

Response `data`: session payload.

**Unverified-email case** (FR-017) — the backend must distinguish this from a bad password, because
the client has to route to code entry instead of showing an error:

```json
{
  "status": "success",
  "message": "Email verification required",
  "data": {
    "outcome": "email_verification_required",
    "purpose": "verify_email",
    "masked_destination": "j•••@mail.com",
    "expires_in_seconds": 600,
    "resend_available_in_seconds": 60
  }
}
```

Errors: `401` for both a wrong password and an unknown email, with the **same** message body so the
client cannot leak account existence (FR-016); `429` after repeated failures (FR-018).

---

### 5. `POST /auth/phone-otp/request` — **new**

Requests a sign-in code for a phone number. Required on every phone sign-in (FR-020).

Request: `{ "dialing_code": "+966", "phone": "501234567", "purpose": "phone_sign_in" }`

Response `data`: OTP challenge with `masked_destination` like `•••4567`.

Note: the response must be identical whether or not the number has an account, so the endpoint does
not become an account-existence oracle.

---

### 6. `POST /auth/verify-phone-number` — existing

Verifies a phone code. Returns **one of two outcomes** (research R12), discriminated by
`data.outcome`.

Request: `{ "dialing_code": "+966", "phone": "501234567", "code": "123456", "purpose": "phone_sign_in" }`

Outcome A — the number belongs to an account, or auto-links to one (FR-021, FR-041):

```json
{ "data": { "outcome": "session", "access_token": "…", "user": { } } }
```

Outcome B — no account yet, so registration must be completed (FR-022):

```json
{
  "data": {
    "outcome": "registration_required",
    "registration_token": "…",
    "source": "phone",
    "verified_dialing_code": "+966",
    "verified_phone": "501234567"
  }
}
```

`registration_token` is valid for **30 minutes** from issue (FR-026a). The client MUST NOT invent a
local TTL; treat 409/422 on complete-registration as `draft_expired` and restart the flow.

The same endpoint with `purpose: "verify_phone"` verifies the phone entered on the social completion
form (FR-033). In that case it returns neither outcome — it returns `status: success` with an empty
`data`, because the account is created by endpoint 8, not here. Wrong/expired codes and the five-guess
cap follow the same mapping as email verify (`invalid_code`, `expired_code`, `too_many_attempts`).

---

### 7. `POST /auth/social` — **new**

Exchanges a provider identity token for a session or a draft (FR-030, FR-031).

Request:

| Field | Type | Notes |
|---|---|---|
| `provider` | `"google"` or `"apple"` | From `SocialProvider.wireName` |
| `id_token` | string | Provider identity token |
| `authorization_code` | string | Apple only |
| `full_name` | string | Optional; Apple supplies it on first authorization only |

Returns the same two-outcome shape as endpoint 6. For a new user the draft carries the
provider-supplied email:

```json
{
  "data": {
    "outcome": "registration_required",
    "registration_token": "…",
    "source": "apple",
    "verified_email": "abc123@privaterelay.appleid.com",
    "suggested_full_name": "Sara N"
  }
}
```

A private relay address must be accepted exactly like a real one (FR-034). When Apple omits email on a later authorization, the backend still returns the stored email on the draft or session (FR-034a). When the provider email
matches an existing account, return `outcome: "session"` and link the provider to it (FR-041).

---

### 8. `POST /auth/complete-registration` — **new**

Finishes a draft from either the phone-first or the social path, creating the account and signing the
user in (FR-025, FR-031). Multipart when an avatar is attached.

Request (`multipart/form-data`):

| Field | Type | Required | Notes |
|---|---|---|---|
| `registration_token` | string | yes | From the draft |
| `full_name` | string | yes | |
| `password` | string | yes | |
| `email` | string | phone source only | Stored unverified — no email code (FR-024) |
| `dialing_code` | string | social source only | Must already be verified via endpoint 6 |
| `phone` | string | social source only | Must already be verified via endpoint 6 |
| `avatar` | file | no | |

Response `data`: session payload.

Errors: `409` or `422` when the token is expired (older than **30 minutes**) or already consumed — the client shows `draft_expired` and restarts the flow rather than a dead end. Submitting a social completion whose phone was not verified
must fail with a `phone` field error, so the client cannot skip FR-033.

---

### 9. `POST /auth/forgot-password` — existing

Requests a password reset code (FR-046, FR-046a).

Request: `{ "email": "..." }`

Response `data`: OTP challenge with `purpose: "reset_password"`.

**Must respond identically** for an unknown email and for an account with no password (social or
phone-first origin), so it does not disclose which case applies (FR-046b, and the spec's
"Password reset for an unknown or code-only account" edge case).

---

### 10. `POST /auth/reset-password` — existing

Verifies the reset code and sets the new password, then signs the user in (FR-046c).

Request: `{ "email": "...", "code": "123456", "password": "...", "password_confirmation": "..." }`

Response `data`: session payload.

Errors: `422` with a `code` field error for wrong or expired codes (`invalid_code` / `expired_code`); `429` after five wrong guesses (FR-018a); `409` when the code was already
used (FR-046d); `422` with a `password` field error when the new password fails the strength rule.

---

### 11. `POST /auth/logout` — **new, authenticated**

Revokes the current session server-side (FR-043). This is the one new endpoint that must **not** be
added to `publicAuthPaths`, because it requires the bearer token it is revoking.

Request: empty body. Response: `status` and `message` only.

The client clears local state regardless of the outcome — a failed logout call must never trap the
user in a signed-in state they asked to leave.

---

### 12. `POST /common/refresh-token` — existing, untouched

Already implemented by `RefreshTokenHelper`. This feature adds no code here.

---

## Session payload

Returned by endpoints 2, 4, 6 (outcome A), 7 (outcome A), 8, and 10.

```json
{
  "access_token": "…",
  "user": {
    "id": 1,
    "full_name": "Sara Nasser",
    "email": "sara@mail.com",
    "dialing_code": "+966",
    "phone": "501234567",
    "avatar_url": null,
    "email_verified": true,
    "phone_verified": false,
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

`RefreshTokenHelper.parseAccessToken` already reads `access_token`, `accessToken`, or `token` from
either the root or `data`, so this shape is compatible with the existing refresh flow without
changes.

---

## Client obligations

1. Add `emailOtpRequestPath`, `phoneOtpRequestPath`, `socialSignInPath`,
   `completeRegistrationPath`, and `logoutPath` to `ApiConstants`.
2. Add the first four to `publicAuthPaths`; leave `logoutPath` out of it.
3. Never log request bodies for these paths — `shouldOmitLogBody` derives from `publicAuthPaths`,
   so step 2 satisfies FR-045 and SC-010 for everything except logout, whose body is empty.
4. Send `dialing_code` and `phone` separately, normalized through `PhoneValidationService`
   (research R7).
5. Treat every `429` as a throttle with `too_many_attempts` copy, not a generic failure. OTP verify endpoints apply this after **5** wrong guesses for the current code (FR-018a).
6. Map every user-visible failure to the spec **Error copy** id; never show a raw HTTP or SDK message (FR-049).
