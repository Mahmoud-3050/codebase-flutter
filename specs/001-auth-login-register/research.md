# Phase 0 Research: Authentication (Login, Register, Guest Mode)

**Feature**: `001-auth-login-register` | **Date**: 2026-09-17

**Purpose**: Resolve every unknown in the plan's Technical Context before design. Each entry
records the decision, why it was chosen, and what was rejected.

---

## R1. Social sign-in SDKs

**Decision**: Add `google_sign_in: ^7.2.0` and `sign_in_with_apple: ^8.2.0`. The app obtains a
provider identity token on-device and exchanges it with our own backend for an access token.
Do **not** add `firebase_auth`.

**Rationale**: The product already owns its identity system — `/auth/login`, `/auth/register`,
`AccessTokenStorage`, and `RefreshTokenHelper` all issue and renew our own bearer token. Adding
`firebase_auth` would create a second identity authority: the app would hold a Firebase user
plus our own account, and the backend would still have to verify a Firebase ID token to mint its
own session. The provider SDKs give us exactly one thing we cannot get otherwise — a signed
identity token — and leave session ownership with the existing backend.

**API shape confirmed on current versions** (both had breaking changes worth pinning to):

- `google_sign_in` 7.x replaced the old `signIn()` with an explicit lifecycle:
  `GoogleSignIn.instance.initialize(clientId:, serverClientId:)` once, then
  `authenticate()` which returns a `GoogleSignInAccount` exposing `authentication.idToken`.
  Cancellation surfaces as `GoogleSignInException` with code `canceled` — this is the signal
  FR-035 needs, and it must be mapped to a cancelled outcome rather than an error toast.
- `sign_in_with_apple` 8.x exposes `SignInWithApple.getAppleIDCredential(scopes: [email, fullName])`
  returning `identityToken`, `authorizationCode`, `email`, `givenName`, `familyName`, plus
  `SignInWithApple.isAvailable()`. Cancellation is `SignInWithAppleAuthorizationException`
  with `AuthorizationErrorCode.canceled`.
- Apple returns `email` and name **only on the very first authorization** for an Apple ID.
  Every later authorization omits them. The social completion form must therefore not depend on
  Apple re-sending the email; the backend stores it on first exchange (FR-034 relay case included).

**Alternatives rejected**:
- `firebase_auth` — duplicate identity authority, as above.
- `google_sign_in_all_platforms` / third-party Apple forks — unnecessary; the app targets iOS and
  Android only, where the first-party plugins are supported.

**Platform work required**: Android needs the OAuth web client ID as `serverClientId`; iOS needs the
reversed client ID URL scheme; Apple needs the Sign in with Apple capability. These are
configuration tasks, not code, and are called out in `tasks.md`.

---

## R2. Password rule: at least one letter and one digit

**Decision**: Compose the existing validators rather than changing the `field_validator` package:

```dart
FieldValidator.combine(<BaseValidator>[
  FieldValidator.password(minLength: 8, requireNumbers: true),
  FieldValidator.pattern(pattern: r'[A-Za-z]', errorMessage: Strings.passwordLetterRequirement),
]);
```

**Rationale**: `PasswordValidator` already offers `minLength` (default 8) and `requireNumbers`, but
its letter flags are `requireUppercase` and `requireLowercase` — either one alone would wrongly
reject a valid password (`requireLowercase` rejects `ABCD1234`, which FR-007a accepts). A
`pattern` validator for `[A-Za-z]` expresses "any letter" exactly, and `combine` returns the first
failing message so the user still learns which rule they missed.

Wrap this in one place — `AuthValidators.password` — so FR-007b's "identical rule everywhere"
is structurally true rather than repeated in four screens.

**Alternatives rejected**:
- Adding a `requireLetters` flag to `PasswordValidator`: a change to a shared package that every
  other feature would inherit, for a rule only this feature currently states. Reconsider if a
  second feature needs it.
- Passing `validator:` closures per screen: duplicates the rule and drifts (clean-code §1.5).

**Note**: `assets/lang/en.json` already has `password_number_requirement`,
`password_lowercase_requirement`, `password_uppercase_requirement`, and
`password_special_character_requirement`. A new `password_letter_requirement` key is needed.

---

## R3. Avatar capture and upload

**Decision**: Use `image_picker` (already in `pubspec.yaml` at `^1.2.3`, currently unused) with
`maxWidth: 1024, maxHeight: 1024`, then read the file length and reject above 2 MB. Upload as
Dio `FormData` through the existing `DioConsumer.post(path, formData: ...)`, which already switches
the content type to multipart.

**Rationale**: `image_picker`'s `maxWidth`/`maxHeight` perform the downscale on-device that FR-006a
requires, which is what keeps the 2 MB ceiling from being hit in practice. `file_picker` is already
used by `FileOptionsDialog`, but it is a document picker (`FileType.custom` with a pdf/png/jpg
whitelist) and offers no camera source and no resizing — wrong tool for an avatar.

Restrict `imageQuality` to a named constant rather than a bare literal, and constrain the picker to
JPEG/PNG by checking the returned extension, since `image_picker` cannot filter by type on all
platforms.

**Alternatives rejected**:
- `file_picker`: no camera, no downscale.
- Uploading the original bytes and letting the backend resize: violates FR-006a's on-device
  downscale and makes the upload slow on poor connections, which SC-004 cares about.

---

## R4. One-time code entry widget

**Decision**: Build a small `AppOtpField` in `lib/shared/widgets/`. Do not add an OTP package.

**Rationale**: There is no OTP or PIN widget in the codebase and no dependency that provides one, so
something must be written or added. A 6-digit code field is a single `TextFormField` with
`maxLength`, digit-only formatters, and per-digit boxes painted underneath — well under the
complexity that justifies a dependency, and it inherits the app's `TextStyles`, theming, and RTL
behavior for free. `assets/lang/en.json` already carries `otp_sent_to_your_inbox`, `resend`, and
`verify`, so the surrounding copy exists.

**Alternatives rejected**: `pinput` and similar — a styling dependency for one widget, and it would
need its own theming bridge to match `themes`.

---

## R5. Interrupted registration: where the draft lives

**Decision**: The backend is the authority. When a verified phone number or provider identity has no
completed account, the verify/exchange response returns
`outcome: "registration_required"` plus a short-lived `registration_token` and whatever fields the
provider supplied. The client persists that token and the prefill in a new
`RegistrationDraftStorage` (backed by the already-registered `FlutterSecureStorage`) so the form can
be restored after a cold start.

**Rationale**: FR-026 and FR-036 require resuming rather than signing into a half-made account, and
only the backend knows whether an account is complete — a client-only draft would be wrong the
moment the user switches devices or clears the app. Storing the token client-side is still needed so
that FR-051 (survive backgrounding) and the cold-start case work without re-verifying. The token is
a bearer-grade secret and the prefill contains an email address, so secure storage is the right
home, matching how `AccessTokenStorage` already treats tokens. It implements the existing
`LocalStorageInterface` so it needs no new abstraction.

**Alternatives rejected**:
- `SharedPreferences`: plaintext on disk for a credential-equivalent token.
- Pure in-memory draft: loses the flow on cold start, failing FR-026.
- Client-only draft with no backend token: cannot distinguish "never registered" from
  "registration incomplete", so FR-026 becomes unimplementable.

---

## R6. Session establishment and the existing refresh machinery

**Decision**: A session is the existing access token in `AccessTokenStorage`, plus
`UserTypeStorage` holding the `UserType` name. Every successful auth path performs the same two
writes, and sign-out performs the inverse. Reuse `RefreshTokenHelper` untouched for renewal.

**Rationale**: `RefreshTokenHelper` already implements FR-042 and FR-044 end to end — it refreshes on
401, retries once, and on unrecoverable failure calls `invalidateSession()`, which clears the token,
writes `UserType.guest`, and fires the `onSessionExpired` callback that `init_app.dart` points at
splash. That is exactly the "return to guest state rather than a dead end" behavior FR-044 describes,
already built and already tested in `test/core/api/refresh_token_helper_test.dart`. Building a
parallel session concept would create two sources of truth for "am I signed in".

**Consequence**: sign-out (FR-043) should call `clearAuthTokens()` and write `UserType.guest`, not
`invalidateSession()`, because sign-out is a deliberate action that should route to the entry screen
rather than re-enter the session-expired path.

**Critical integration detail**: `ApiInterceptor` attaches a bearer token and enables refresh for any
path not listed in `ApiConstants.publicAuthPaths`. The new unauthenticated endpoints (email-code
request, phone-code request, social exchange, complete-registration) **must** be added to that list,
or a stale token from a previous session will be attached and a 401 will trigger a pointless refresh
attempt. `ApiConstants.shouldOmitLogBody` keys off the same list, which is also what satisfies
FR-045 and SC-010 for the new endpoints.

---

## R7. Phone number normalization

**Decision**: Normalize with the existing `PhoneValidationService`, then send `dialing_code` (as
`+966`) and `phone` (the national significant number) as separate fields, matching the convention
already used by `UpdateStudentProfileParams`. Keep the E.164 `fullNumber` for local comparison and
display.

**Rationale**: `PhoneValidationService.validatePhoneNumber` already wraps `phone_numbers_parser`,
returns `isValidPhone`, `nsn`, `countryCode`, and an E.164 `fullNumber`, and is covered by
`test/core/services/phone_validation_service_test.dart`. That gives FR-027's "same real number
resolves to one account regardless of spacing, punctuation, or country-code formatting" for free.
Splitting the fields on the wire matches the existing backend contract rather than inventing a
second shape for the same data.

**Alternatives rejected**: sending raw user input (fails FR-027); hand-rolled regex normalization
(re-implements a solved, tested problem).

---

## R8. Resend cooldown countdown

**Decision**: A dedicated `OtpCooldownCubit` with its own sealed state
(`OtpCooldownIdle` / `OtpCooldownCounting(secondsRemaining)`), driven by an **injected ticker**
(`Stream<int> tick(int ticks)`) whose subscription is cancelled in `close()` before `super.close()`.

**Rationale**: A visible countdown is a stream of state over time, not a request with a result, so
`ApiCallState<T>`'s holding/loading/success/error vocabulary does not describe it. Principle III
explicitly permits a different sealed hierarchy when the operation genuinely needs one, and this is
that case. Keeping it in a Cubit rather than a `StatefulWidget` timer keeps the ticking testable and
honors "no async work in widgets".

**Alternatives rejected**:
- Encoding the countdown in `ApiCallState`: would abuse `ApiCallSuccess<int>` to mean "seconds left".
- `Timer` inside the screen's `State`: untestable and drifts from the Cubit discipline.
- A bare `Timer.periodic` inside the cubit: still untestable, since a unit test would have to wait 60
  real seconds to observe the countdown reaching zero. Injecting the ticker is what makes the
  countdown assertable synchronously.

---

## R9. Startup routing and visitor state

**Decision**: `SplashScreen` (currently a bare `Placeholder`) gains a `ResolveVisitorStateCubit`
that reads `UserTypeStorage` through the auth repository and routes to welcome, or home. Register
`AppRoutes.home` — the constant already exists but no route is declared for it.

**Rationale**: The `UserType` enum already models exactly the three states the spec's Visitor State
entity describes, with comments that name the intended destinations (`firstOpen` → WelcomeScreen,
`loggedIn` → HomeScreen, `guest` → HomeScreen). No new concept is needed; the gap is purely that
nothing reads it. `GoRouter.redirect` is currently a no-op placeholder.

**Decision on where the branch lives**: in splash, not in `GoRouter.redirect`. Reading secure
storage is asynchronous, and a redirect callback that awaits storage on every navigation would
either block routing or need a synchronous cache. Splash already exists as the initial location for
exactly this purpose.

**Alternatives rejected**: a new `VisitorState` enum (duplicates `UserType`); auth-guard logic in
`redirect` (async storage read on every navigation).

---

## R10. Guest gate for account-required actions

**Decision**: One shared `GuestGateDialog` plus a `context.requireAccount()` helper in the auth
feature's presentation layer, returning whether the caller may proceed.

**Rationale**: FR-039 requires a consistent "explain why, then offer sign-in and registration"
prompt. Centralizing it means the wording and the two navigation targets exist once. It lives in the
auth feature because it is auth's concern, and other features depend on auth's presentation layer
only through this one entry point.

**Note**: With a blank home screen there is no real protected action to gate yet, so this ships with
the dialog and a demonstration trigger, as the spec's assumption about guest limitations anticipates.

---

## R11. Two providers, one operation

**Decision**: A single `SocialSignInCubit` whose action takes the provider as a parameter, backed by
one `SocialSignInUseCase` and a `SocialProvider` enhanced enum that carries the provider's wire
name and availability rule.

**Rationale**: Stories 5 and 6 describe the same operation with a different identity source — the
spec itself says Apple "follows the same shape as Google". Two cubits would duplicate identical
fold-and-emit logic, contradicting "one Cubit per user-facing operation" by splitting one operation
in two. The enhanced enum is where `isAvailableOnThisPlatform` belongs (modern Dart §4.1), which is
what FR-029 needs to hide the Apple button.

**Alternatives rejected**: `GoogleSignInCubit` + `AppleSignInCubit` (duplicated logic); a string
`provider` argument (stringly-typed, §4.1).

---

## R12. Verify/exchange returns one of two outcomes

**Decision**: Model the phone-verify and social-exchange results as a sealed
`AuthOutcome` with `AuthSessionEstablished` and `AuthRegistrationRequired` variants, carried inside
`ApiCallSuccess<AuthOutcome>`. The backend discriminates with a `data.outcome` field.

**Rationale**: Story 4 scenario 2 versus 4, and Story 5 scenario 1 versus 2, are genuinely two
different next screens from one request. A sealed type forces the UI to handle both (§4.2), where a
nullable `registrationToken` on a single response class would let a missing branch compile. This
also expresses FR-041b cleanly: auto-linking simply returns the session variant.

**Alternatives rejected**: nullable fields on one response class; two separate endpoints (the client
cannot know in advance which case it is in — that is precisely what it is asking).

---

## R13. Testing approach

**Decision**: Follow the profile feature's existing pattern exactly — `mockito` `@GenerateMocks` in
`test/features/auth/mocks.dart`, repository tests that assert exception-to-failure mapping, and
`bloc_test` cubit tests covering success, error, validation-field errors, and cancellation.
`provideDummy` is required for every `Either<Failure, T>` the mocks return.

**Rationale**: The pattern is established, the constitution's review gate requires use-case and
cubit coverage, and `test/features/profile/` already demonstrates every needed idiom including the
`CubitRequestCanceller` close-cancellation test.

**Gap noted**: the repository has no example of a use-case unit test (profile only tests the
repository impl and one cubit). Since the constitution requires use-case tests, this feature
establishes that pattern: assert the use case delegates to the repository with the exact params and
passes the `Either` through untouched.

---

## Resolved unknowns summary

| Unknown | Resolution |
|---|---|
| Social SDK choice | `google_sign_in` 7.2.0 + `sign_in_with_apple` 8.2.0, backend token exchange (R1) |
| "Letter and digit" password rule | `FieldValidator.combine` of `password` + `pattern` (R2) |
| Avatar pick/resize/upload | `image_picker` with 1024 px cap, 2 MB check, Dio `FormData` (R3) |
| OTP input | New `AppOtpField` shared widget (R4) |
| Draft persistence | Backend `registration_token` cached in secure storage (R5) |
| Session model | Existing `AccessTokenStorage` + `UserTypeStorage` + `RefreshTokenHelper` (R6) |
| Phone normalization | Existing `PhoneValidationService`, `dialing_code` + `phone` on the wire (R7) |
| Resend countdown | `OtpCooldownCubit` with its own sealed state (R8) |
| Startup destination | `ResolveVisitorStateCubit` in splash over existing `UserType` (R9) |
| Guest gate | Shared `GuestGateDialog` + `context.requireAccount()` (R10) |
| Google vs Apple structure | One cubit, `SocialProvider` enhanced enum (R11) |
| Two-outcome responses | Sealed `AuthOutcome` inside `ApiCallSuccess` (R12) |
| Test strategy | Profile's mockito + `bloc_test` pattern, plus new use-case test pattern (R13) |
