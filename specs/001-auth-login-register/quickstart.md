# Quickstart: Authentication (Login, Register, Guest Mode)

**Feature**: `001-auth-login-register` | **Date**: 2026-09-17

How to build, run, and verify this feature. Read `plan.md` first for the architecture.

---

## Prerequisites

```bash
flutter --version          # Dart SDK >= 3.10.0 per pubspec.yaml
flutter pub get
```

New dependencies this feature adds (research R1, R3):

```yaml
dependencies:
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^8.2.0
  # image_picker is already in pubspec.yaml — it was simply unused until now
```

---

## Platform configuration

Neither social provider works without native setup, and both fail at runtime rather than at compile
time, so do this before testing Stories 5 and 6.

**Android** (`android/app/src/main/res/values/strings.xml` and Gradle):
- Add the OAuth **web** client ID; `google_sign_in` 7.x takes it as `serverClientId`, and the backend
  needs the same value to validate the token.
- The debug and release SHA-1 fingerprints must both be registered in the Google Cloud console.

**iOS** (`ios/Runner/Info.plist` and Xcode):
- Add the reversed iOS client ID as a URL scheme.
- Enable the **Sign in with Apple** capability on the Runner target.
- Sign in with Apple requires a real device or a simulator signed into an Apple ID.

Firebase is already initialized (`init_app.dart`), but this feature does **not** use `firebase_auth`.

---

## Adding the new strings

Localized copy is generated, never hand-edited in `strings.dart`:

```bash
# 1. Add keys to generate/strings/lang.json as { "key": { "en": "...", "ar": "..." } }
# 2. Apply them to assets/lang/*.json and regenerate lib/config/language/strings.dart
dart generate/strings/main.dart
```

Many keys already exist and must be reused rather than duplicated: `login`, `sign_in`, `sign_up`,
`email`, `password`, `phone_number`, `forgot_password`, `reset_password`, `continue_as_a_guest`,
`guest`, `logout`, `resend`, `verify`, `verify_your_account`, `email_activation`,
`otp_sent_to_your_inbox`, `welcome_back`, `password_changed_successfully`,
`password_reset_successfully`.

At minimum these are new: `password_letter_requirement`, plus copy for the completion forms, the
guest gate dialog, avatar limits, and the throttle messages.

---

## Running

```bash
flutter run -t lib/main_dev.dart      # dev flavor → stage.back-mob-sa.co
flutter run -t lib/main_live.dart     # live flavor
```

Startup path: `main_dev.dart` → `initApp()` → `AppRouter.router` at `/splash` →
`ResolveVisitorStateCubit` → welcome, or home.

To retest the first-time-visitor path, clear app data (the `userType` key lives in
`SharedPreferences`; the access token lives in the Keychain/Keystore and survives a hot restart).

---

## Verifying each user story

Each story is independently demonstrable against the blank home screen (SC-013).

**Story 1 — register with email and password**
Fresh install → Welcome → Register → fill name, email, phone, password, optionally pick an avatar →
submit → email code screen → enter the code → home. Kill and relaunch: still home, still signed in.

**Story 2 — sign in with email and password**
Welcome → Sign in → correct credentials → home with no code prompt. Then verify a wrong password
returns the same message as an unknown email.

**Story 3 — guest**
Fresh install → Welcome → Continue as guest → home. Relaunch: straight back to home as a guest.
Trigger the protected action → the guest gate offers sign-in and register.

**Story 4 — phone code**
Welcome → Phone sign-in → known number → code → home. Repeat with an unused number → the completion
form appears with the phone fixed and no email code step. Abandon it, sign in with the same number
again → the completion form returns.

**Story 5 / 6 — Google and Apple**
Authorize with a linked account → home. Authorize with an unlinked one → completion form with the
email fixed and a phone code step. Cancel the provider sheet → back to the entry screen with no
partial account. On Android, confirm the Apple button is absent (FR-029).

**Password recovery**
Sign-in screen → Forgot password → email → code → new password → signed in on home.

---

## Tests

```bash
flutter analyze                                   # must be 0 issues before PR
flutter test                                      # whole suite
flutter test --coverage                           # writes coverage/lcov.info
flutter test test/features/auth                   # this feature's unit + widget tests
flutter test integration_test/auth                # end-to-end, needs a device or emulator
dart run build_runner build --delete-conflicting-outputs   # mockito mocks + go_router_builder
```

The integration level needs `integration_test` (Flutter SDK) added to `dev_dependencies`.

Codegen matters twice here: `router.g.dart` for the typed routes and `mocks.mocks.dart` for the
mockito doubles. Run `build_runner` after adding a route or a `@GenerateMocks` type.

Required coverage: ≥ 90% line coverage over `lib/features/auth/**`, split across unit, widget, and
integration levels. Test names must begin with the requirement id they exercise (`FR-016 …`) so
requirement coverage is searchable. The full definition — metric, denominator exclusions, per-level
floors, seams, and fixtures — is the Testing Strategy section of `plan.md`.

---

## Things that will bite you

1. **A new endpoint not added to `ApiConstants.publicAuthPaths`** gets a stale bearer token attached
   and triggers a refresh attempt on 401. It also gets its request body logged in debug, which
   violates FR-045. Add the path to both places when you add it.
2. **`google_sign_in` 7.x is not the API you remember.** `signIn()` is gone; call `initialize()` once
   and then `authenticate()`.
3. **Apple returns the email and name only on the first authorization** for a given Apple ID. Test the
   second authorization too, and revoke the app in iOS Settings to reset.
4. **Do not force `const`** on widgets sized with `.w` / `.h` / `.sp` or styled with
   `TextStyles.of(...)` — those are runtime values.
5. **`ScreenUtilInit` must be an ancestor** of anything using `.sp`, so `TextStyles.of` cannot be used
   in a cubit or a top-level constant.
6. **Dispose everything.** Every auth form owns several `TextEditingController`s and `FocusNode`s;
   `OtpCooldownCubit` must cancel its ticker subscription in `close()` before `super.close()`. The
   ticker is injected rather than a bare `Timer`, so the countdown can be driven synchronously in
   tests — see the Testing Strategy in `plan.md`.
7. **`FeatureScope` drops its GetIt scope on dispose**, so a cubit resolved in one route is gone when
   that route leaves. Pass data forward through route parameters or the persisted draft, not through a
   shared singleton cubit.
