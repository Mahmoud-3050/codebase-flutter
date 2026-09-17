# Implementation Plan: Authentication (Login, Register, Guest Mode)

**Branch**: `001-auth-login-register` | **Date**: 2026-09-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-auth-login-register/spec.md`

## Summary

Build a complete `lib/features/auth/` feature covering six ways in — email-and-password registration
with an emailed code, email-and-password sign-in, guest mode, phone one-time-code sign-in that
doubles as a registration route, and Google and Apple sign-in — plus forgotten-password recovery and
sign-out, all landing on a deliberately blank home screen that proves the entry-to-home cycle.

The technical approach leans hard on infrastructure that already exists and is already tested. The
backend session, refresh-on-401, retry, and session-expiry-to-guest behavior are fully implemented in
`RefreshTokenHelper` and `ApiInterceptor`, so this feature stores a token and a `UserType` and
otherwise stays out of the way. `ApiConstants` already declares `/auth/login`, `/auth/register`,
`/auth/verify-email`, `/auth/verify-phone-number`, `/auth/forgot-password`, and
`/auth/reset-password`; five endpoints are new. `UserType` already models exactly the spec's
first-time-visitor, guest, and signed-in states — the gap is that nothing reads it, because
`SplashScreen` is still a bare `Placeholder`. Phone normalization, field validation, form widgets,
toasts, and both languages are all in place.

Three genuinely new things: the provider SDK boundary (`google_sign_in` + `sign_in_with_apple`
exchanged for our own token, not `firebase_auth`), a one-time-code input widget, and a
server-authoritative registration draft that lets an interrupted phone-first or social signup resume.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter (SDK constraint `>=3.10.0 <4.0.0`)

**Primary Dependencies**: `flutter_bloc` 9.1.1, `get_it` 9.2.1, `dio` 5.11, `go_router` 17.3 with
`go_router_builder`, `flutter_secure_storage` 10.3, `shared_preferences` 2.5,
`phone_numbers_parser` 9.0 / `phone_form_field` 10.0, `image_picker` 1.2 (present but unused until
now); local packages `either`, `field_validator`, `language`, `themes`, `screen_util`.
**New**: `google_sign_in` ^7.2.0, `sign_in_with_apple` ^8.2.0 (research R1).

**Storage**: Access token in `FlutterSecureStorage` via the existing `AccessTokenStorage`; visitor
state in `SharedPreferences` via the existing `UserTypeStorage`; registration draft in
`FlutterSecureStorage` via a new `RegistrationDraftStorage` implementing the existing
`LocalStorageInterface`. No local database.

**Testing**: `flutter_test`, `bloc_test` 10.0, `mockito` 5.6 with `build_runner`; mirrors
`test/features/profile/`. **New**: `integration_test` (Flutter SDK) for the end-to-end level — see
Testing Strategy below.

**Target Platform**: Android and iOS (Apple sign-in offered on iOS/macOS only, per FR-029).

**Project Type**: Mobile app consuming an existing REST backend — a single Flutter project, no
frontend/backend split in this repo.

**Performance Goals**: 60 fps on all auth screens; reach the home screen as a guest within 5 s of a
single tap (SC-003) and within 15 s and ≤ 3 interactions for returning email sign-in (SC-002).

**Constraints**: No password or one-time code in any log, diagnostic, or crash report (FR-045,
SC-010) — satisfied by adding every new unauthenticated endpoint to `ApiConstants.publicAuthPaths`,
which `shouldOmitLogBody` derives from. Both supported languages and both reading directions
(FR-050). `flutter analyze` clean. Offline and throttled (429) paths must surface actionable retry
messages, never a dead end.

**Scale/Scope**: 14 cubits, 14 use cases, 15 repository methods (11 remote, 4 local), 11 endpoints
(6 existing, 5 new), roughly 10 screens plus a blank home screen, delivered in six independently
demonstrable story slices.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*
*Source: `.specify/memory/constitution.md` v2.0.0*

Initial evaluation: **PASS**. Post-design re-evaluation: **PASS** with three justified deviations
recorded in Complexity Tracking.

- **I Feature-first Clean Architecture**: PASS. Everything lives under `lib/features/auth/` mirroring
  `lib/features/profile/`, including `presentation/navigation/`. Domain holds only entities, the
  repository contract, use cases, and `*Params`; the provider SDKs are confined to a data-layer
  `SocialAuthService` behind an `abstract interface class`, so `google_sign_in` and
  `sign_in_with_apple` never appear in domain or presentation imports. One touch outside the feature
  is unavoidable and intended: `SplashScreen` must read visitor state to route, and it does so through
  an auth cubit provided at the splash route.
- **II Scoped DI**: PASS. No auth type is registered in `ServiceLocator.init()`. `auth_injection.dart`
  exposes ten granular `register*` functions and each route wraps its screen in `FeatureScope` with
  only what that route needs. Cubits are `registerFactory`; use cases, repositories, datasources, and
  the new storage are `registerLazySingleton`. Note the consequence: because `FeatureScope` drops its
  scope on dispose, cross-screen data (a verified phone, a draft token) travels by route parameter or
  the persisted draft, never a shared singleton cubit.
- **III Cubit/Bloc presentation**: PASS with one justified deviation. Thirteen of fourteen cubits
  `typedef` their state to `ApiCallState<T>`; `OtpCooldownCubit` uses its own sealed hierarchy, which
  Principle III explicitly permits and which Complexity Tracking justifies. Widgets only dispatch
  `context.read<Cubit>().f…()`. Two response shapes that genuinely branch the UI —
  phone-verify/social-exchange, and login-versus-needs-verification — are modeled as sealed
  `AuthOutcome` and `LoginOutcome` inside `ApiCallSuccess`, so no screen can forget a branch.
- **IV `Either<Failure, T>`**: PASS. Repository methods return `Either` from `package:either/either.dart`.
  Datasources throw `AppException` subtypes and never return `Either`; the repository impl uses the
  existing `RepositoryGuard.guard()` mixin, which already logs and maps via `toFailure()`. Provider
  cancellation becomes a `SocialSignInCancelledException` at the data boundary so no `GoogleSignInException`
  or `SignInWithAppleAuthorizationException` escapes past it.
- **V Entities vs models**: PASS. `fromJson` lives only on `data/models/` classes that extend pure
  domain entities. Each `*Params` sits in its use-case file with a `toJson()` that emits the wire
  names and omits nulls, exactly like `UpdateStudentProfileParams`. No mapper classes.
- **Quality & Flutter**: PASS. Reuses `either`, `field_validator`, `language`, `screen_util`,
  `themes`, and the existing `AppTextFormField` factories, `AppElevatedButton`, `showAppSnackBar`,
  `FieldErrorsScope`, `ApiCallWidget`, `PhoneValidationService`, and `CubitRequestCanceller` rather
  than adding equivalents. Fixed state sets are sealed classes or enhanced enums. The password rule is
  composed from existing validators in one `AuthValidators` holder so FR-007b holds structurally
  instead of by convention. Use-case, repository, and cubit tests are planned per the review gate.

## Project Structure

### Documentation (this feature)

```text
specs/001-auth-login-register/
├── plan.md                      # This file (/speckit-plan command output)
├── spec.md                      # Feature specification (clarified)
├── research.md                  # Phase 0 output — 13 resolved decisions
├── data-model.md                # Phase 1 output — entities, enums, transitions
├── quickstart.md                # Phase 1 output — build, run, verify
├── contracts/
│   ├── auth-api.md              # Backend HTTP contract (11 endpoints)
│   └── auth-repository.md       # Dart layer contract (repo, datasources, use cases, cubits, DI)
├── checklists/
│   └── requirements.md          # Spec quality checklist
└── tasks.md                     # Phase 2 output (/speckit-tasks — NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/auth/
├── auth_injection.dart                      # 10 granular register* functions
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart      # interface — 11 endpoint methods
│   │   ├── auth_remote_datasource_impl.dart # dioConsumer + ApiResponse + FormData for avatars
│   │   ├── auth_local_datasource.dart       # interface — session, visitor state, draft
│   │   ├── auth_local_datasource_impl.dart  # composes the three storages
│   │   ├── social_auth_service.dart         # interface — provider SDK boundary
│   │   ├── social_auth_service_impl.dart    # google_sign_in + sign_in_with_apple
│   │   ├── avatar_picker.dart               # interface — image_picker boundary (testability)
│   │   └── avatar_picker_impl.dart          # image_picker + downscale + size check
│   ├── models/                              # one *_model.dart per response, extends its entity
│   └── repositories/
│       └── auth_repo_impl.dart              # with RepositoryGuard
├── domain/
│   ├── entities/                            # AuthUser, AuthSession, AuthOutcome, LoginOutcome,
│   │                                        # RegistrationDraft, OtpChallenge, *Response
│   ├── enums/                               # SocialProvider, OtpPurpose, RegistrationSource
│   ├── repositories/
│   │   └── auth_repo.dart
│   └── usecases/                            # 14 use cases, each with co-located *Params
└── presentation/
    ├── controller/                          # one folder per operation, cubit + states part file
    │   ├── register/  verify_email/  request_email_otp/  login/
    │   ├── request_phone_otp/  verify_phone_otp/  social_sign_in/
    │   ├── complete_registration/  request_password_reset/  reset_password/
    │   ├── logout/  resolve_visitor_state/  guest_mode/  otp_cooldown/
    ├── navigation/
    │   ├── router.dart                      # typed routes + FeatureScope per route
    │   └── router.g.dart                    # go_router_builder output
    ├── pages/                               # welcome, login, register, verify_email,
    │                                        # phone_sign_in, phone_otp, complete_registration,
    │                                        # forgot_password, reset_password
    ├── validators/
    │   └── auth_validators.dart             # single source for the password/email/phone rules
    └── widgets/                             # forms, social buttons, avatar picker, guest gate

lib/features/home/                           # new: deliberately blank home screen + route
lib/features/splash/                         # modified: resolve visitor state and route
lib/shared/widgets/app_otp_field.dart        # new: 6-digit code input
lib/core/api/api_constants.dart              # modified: 5 new paths, 4 added to publicAuthPaths
lib/core/services/local_storage/impl/registration_draft_storage.dart   # new
lib/config/routes/app_routes.dart            # modified: new route constants
lib/config/routes/app_router.dart            # modified: register auth + home route lists

test/features/auth/
├── mocks.dart                               # @GenerateMocks
├── fixtures.dart                            # canonical account, codes, session JSON, avatar bytes
├── data/repositories/auth_repo_impl_test.dart
├── data/models/                             # fromJson tests, incl. both AuthOutcome branches
├── domain/usecases/                         # one test per use case
└── presentation/
    ├── controller/                          # one bloc_test per cubit
    └── pages/                               # one widget test per screen

integration_test/
└── auth/                                    # one file per user story + recovery
```

**Structure Decision**: Single Flutter project, feature-first. `lib/features/auth/` mirrors
`lib/features/profile/` file-for-file in shape, which Principle I names as the canonical layout. Two
new sibling features are created rather than folded into auth: `lib/features/home/` (the blank
destination — it is a product surface, not an auth concern) and the existing `lib/features/splash/`
gains routing logic. Shared UI that is not auth-specific (`AppOtpField`) goes in `lib/shared/widgets/`
alongside the other `App*` widgets, and the new token-adjacent storage goes with its siblings in
`lib/core/services/local_storage/impl/`.

### Delivery order

Slices follow the spec's story priorities, each independently demonstrable (SC-013):

1. **Foundation** — endpoints and `publicAuthPaths`, entities, repository, datasources, DI, routes,
   blank home screen, splash visitor-state routing, `AppOtpField`, `AuthValidators`.
2. **P1** Story 1 — email-and-password registration with the email code.
3. **P2** Story 2 — email-and-password sign-in, including the unverified-email detour.
4. **P3** Story 3 — guest mode, the guest gate, and sign-out.
5. **P4** Story 4 — phone code sign-in and phone-first registration with draft resume.
6. **P5/P6** Stories 5 and 6 — Google, then Apple, sharing one cubit and completion form.
7. **Recovery** — forgotten password, which reuses the code machinery from slice 2.

## Testing Strategy

Answers the questions raised by [checklists/test.md](./checklists/test.md). The constitution's review
gate requires use-case, repository, and cubit tests; this section adds the widget and integration
levels and the coverage definition that the gate leaves open.

### Coverage target and how it is measured

**Target**: ≥ 90% **line** coverage over `lib/features/auth/**`, measured by
`flutter test --coverage`, which writes `coverage/lcov.info`.

Line coverage, not branch coverage, because Flutter's built-in tooling reports only lines
(lcov `LF`/`LH`). Branch confidence is bought a different way: every sealed type in this feature
(`AuthOutcome`, `LoginOutcome`, `ApiCallState`) must have a test per variant, which the compiler's
exhaustiveness checking then keeps honest as variants are added.

**Excluded from the denominator** — a percentage over code that cannot be reached headlessly is a
false target:

| Excluded | Why |
|---|---|
| `**/*.g.dart` | `go_router_builder` output; asserting generated code tests the generator |
| `**/*.mocks.dart` | mockito output |
| `data/datasources/social_auth_service_impl.dart` | pure `google_sign_in` / `sign_in_with_apple` plumbing; needs a real provider account |
| `data/datasources/avatar_picker_impl.dart` | pure `image_picker` platform-channel plumbing |

Everything else counts, including `auth_local_datasource_impl.dart` — it composes injected storage
interfaces, so it is fully testable with mocks and must not be excluded.

**Per-level floors**:

| Level | Definition | Scope of responsibility | Floor |
|---|---|---|---|
| Unit | A single function, method, or class in isolation | `domain/` entirely, `data/` except the two excluded impls, and all 14 cubits | ≥ 95% of those files |
| Widget | Isolated widget rendering, layout, and UI interaction | Every screen in `presentation/pages/` and every form widget | Every screen: its 4 state branches plus field-error rendering |
| Integration | Complete end-to-end user flows on a real device or emulator | The 6 user stories plus password recovery | 7 flows, 1 file each |

The global ≥ 90% figure is the union of all three levels, not each in isolation.

### Requirement traceability

Line coverage cannot show that FR-041a or FR-046d were tested at all. So every test name must begin
with the requirement id it exercises:

```dart
test('FR-016 rejects invalid credentials without disclosing whether the email exists', ...);
blocTest('FR-017 emits LoginNeedsEmailVerification when the email is unverified', ...);
```

A requirement is covered when at least one test names it. The reviewer's check is a search for each
`FR-0xx` in `test/features/auth/` and `integration_test/auth/`, which is why the ids must appear
verbatim.

### What each level owns

**Unit**. The `*Params.toJson()` wire mappings field by field, including the null-omission rule;
models' `fromJson` including both `AuthOutcome` branches; each repository method's
exception-to-failure mapping asserted as a specific `Failure` subtype rather than merely `isLeft`;
each use case's delegation and pass-through of the `Either`; and each cubit's emission sequence.

The canonical cubit assertions, one per operation: `[Loading, Success]`, `[Loading, Error]` with a
server message, `[Loading, Error]` falling back to `Strings.pleaseTryAgainLater` when the failure
message is null, `[Loading, Error]` carrying `fieldErrors` from a `ValidationFailure`, and
`[Loading]` alone when the request was cancelled. `GetStudentProfileCubit`'s test file is the
template.

Local operations get their edge cases asserted explicitly: `resolveVisitorState` returns
`UserType.firstOpen` when the stored value is **missing** and when it is **unreadable** — note this
deliberately differs from `UserType.fromString`, whose `orElse` falls back to `guest`.

**Widget**. Each auth screen renders exactly four `ApiCallState` branches — `holding`, `loading`,
`success`, `error`. `empty`, `refresh`, and `pagination` are unused by this feature and must not
appear in any auth builder, so a widget test asserting four branches is complete rather than partial.
Widget tests also cover field-error placement (the error lands on the named field, via
`FieldErrorsScope`), the locked non-editable field on each completion form, and duplicate-submission
prevention observed as a single dispatched action while one is in flight.

Every screen is tested in both locales and both reading directions, satisfying FR-050 and giving
SC-008 an owner: pump the screen once under `en` (LTR) and once under `ar` (RTL) and assert it lays
out without overflow in both.

**Integration**. One file per story, run on a device or emulator, each asserting the story's
independent-test description from the spec and ending on the blank home screen. This is where SC-013's
"demonstrated independently" is discharged **automatically** rather than by hand.

### Test seams and determinism

No test may reach the real network, a real provider SDK, or a real platform channel. The substitution
points are all interfaces, which is why they exist:

| Seam | Replaces | Used by |
|---|---|---|
| `AuthRemoteDataSource` | all HTTP | unit, widget, integration |
| `AuthLocalDataSource` | token, visitor state, draft storage | unit, widget, integration |
| `SocialAuthService` | `google_sign_in`, `sign_in_with_apple` | all levels, including integration |
| `AvatarPicker` | `image_picker` | widget, integration |

Two consequences worth stating plainly:

1. **`AvatarPicker` exists for testability.** Calling `image_picker` directly from a widget would make
   every avatar path untestable, so picking, downscaling to 1024 px, and the 2 MB check sit behind an
   interface whose fake returns fixture bytes.
2. **`OtpCooldownCubit` must not own a bare `Timer`.** It takes an injected ticker
   (`Stream<int> tick(int ticks)`), so the countdown is driven synchronously in tests instead of
   waiting 60 real seconds. This is a correction to the design sketched in Complexity Tracking below,
   forced by checklist item CHK041.

Fixtures live in `test/features/auth/fixtures.dart`: one canonical verified account, one unverified
account, a valid and an invalid 6-digit code, a session payload matching
`contracts/auth-api.md`, a `registration_required` payload per source, and a small PNG within the
JPEG/PNG and 2 MB limits.

### Deliberately outside the automated suite

Stating these prevents chasing obligations no client test can meet:

- **SC-004** (95% of codes delivered within 60 s) and **SC-005** (95% first-attempt completion) are
  field metrics about the backend and real users. They are verified by production monitoring, not by
  this suite.
- **Real Google and Apple authorization** cannot be driven headlessly. Integration tests inject a fake
  `SocialAuthService`, covering everything from the exchange onward; the native provider sheet itself
  is verified manually per the checklist in `quickstart.md`.
- **SC-001, SC-002, SC-003 timings** are product targets measured manually on a mid-tier device over
  stable Wi-Fi with a warm start. Integration tests assert generous upper bounds only, because a
  debug-mode emulator cannot reproduce release-mode timings. Interaction counts for SC-002 count
  discrete user gestures, excluding keyboard focus and dismissal.
- **Session lifetime** (SC-006) is backend-owned, so the assertion is behavioral rather than temporal:
  a persisted session survives an app restart, and an unrenewable session returns the user to guest
  state. The duration itself is not asserted.

### Security assertions

FR-045 and SC-010 are verified, not assumed. One test per auth operation asserts that no password and
no one-time code appears in captured log output. The mechanism this relies on —
`ApiConstants.shouldOmitLogBody`, derived from `publicAuthPaths` — is existing core infrastructure, so
the test asserts the auth feature's outcome rather than re-testing the interceptor.

### Two conflicts resolved at plan level

The checklist surfaced two places where artifacts disagreed. Resolving them here so tests are written
once:

1. **Code expiry and resend cooldown come from the server.** The spec's assumed 10-minute expiry and
   60-second cooldown are documentation of typical values, not requirements. Tests drive
   `expires_in_seconds` and `resend_available_in_seconds` from the response and must never assert the
   literals 600 or 60.
2. **A cancelled provider authorization is silent.** FR-035 groups "cancelled or fails"; the split is
   that cancellation returns the user to the entry screen with no message, while a genuine failure
   shows an actionable error. `SocialSignInCancelledException` is what distinguishes them.

### Two product surfaces this feature must define to be testable

Both are this feature's own screens, so the plan decides them rather than deferring to the spec:

- **Sign-out** (FR-043) is reachable from the blank home screen. Without a stated location, no widget
  or integration test has a target.
- **The guest gate** (FR-039) is triggered by a single explicit "account required" control on the blank
  home screen, standing in for the real protected actions that arrive with later features.

### Commands and enforcement

```bash
flutter analyze                                        # 0 issues required
dart run build_runner build --delete-conflicting-outputs
flutter test --coverage                                # writes coverage/lcov.info
flutter test test/features/auth                        # this feature's unit + widget tests
flutter test integration_test/auth                     # on a connected device or emulator
```

The repository has **no CI configuration** (`.github/workflows` does not exist), so the target is
enforced by the author running the commands above and by the reviewer checking the reported percentage
and the `FR-0xx` traceability search. Adding a CI workflow that fails the build below 90% is a
worthwhile follow-up but is out of scope for this feature.

### Checklist items this section does not resolve

These need spec amendments, not a testing decision, and remain open in
[checklists/test.md](./checklists/test.md):

| Item | Missing requirement |
|---|---|
| CHK018 | Exact message text, or string keys, per failure named in SC-007 |
| CHK022 | Any accessibility requirement for the auth forms |
| CHK030 | A quantified wrong-attempt cap ("a small number" is unassertable) |
| CHK031 | Registration-draft token lifetime ("short-lived" has no boundary) |
| CHK035 | An observable definition of FR-051's "must not lose the form" on resume |
| CHK038 | Expected behavior when Apple omits the email on a second authorization |

## Complexity Tracking

> Deviations from the default patterns, each justified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `OtpCooldownCubit` uses its own sealed state instead of `ApiCallState<T>`, and takes an injected ticker rather than owning a `Timer` | A resend countdown is state changing over time, not a request with a result; `holding/loading/success/error` cannot express "43 seconds left" without abusing `ApiCallSuccess<int>`. The ticker is injected so tests drive it synchronously instead of waiting real seconds | Principle III permits a different sealed hierarchy when the operation needs one. A `Timer` in the screen's `State` was rejected as untestable and as async work in a widget; a bare `Timer` inside the cubit was rejected for the same testability reason (see Testing Strategy) |
| One `SocialSignInCubit` parameterized by `SocialProvider`, rather than one cubit per provider | Stories 5 and 6 are the same operation with a different identity source — the spec itself says Apple "follows the same shape as Google" | Two cubits would duplicate identical fold-and-emit logic and split one user-facing operation in two, which is what the one-cubit-per-operation rule exists to prevent |
| `AuthLocalDataSource` and `SocialAuthService` alongside `AuthRemoteDataSource` — three data sources for one feature | Device storage, provider SDKs, and HTTP are three different reasons to change (§3.1), and the SDK boundary must be an interface for tests to avoid launching a real Google or Apple flow | Folding them into the remote datasource would make one class own HTTP, Keychain, and two native SDKs. Folding them into the repository impl would put SDK types past the data boundary |

**Not** treated as deviations: 14 cubits and 15 repository methods is the expected decomposition for a
feature with six entry paths plus recovery, not over-engineering — §8.8 names "a new use case + cubit +
datasource method per distinct user action or API endpoint" as the correct unit.
