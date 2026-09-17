# Tasks: Authentication (Login, Register, Guest Mode)

**Input**: Design documents from `/specs/001-auth-login-register/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. Plan Testing Strategy requires ≥90% line coverage over `lib/features/auth/**` with unit, widget, and integration levels. Write the listed tests first and confirm they fail before implementing.

**Organization**: Setup → Foundational (blocks all stories) → user stories in spec priority → password recovery → polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks). Do **not** treat `[P]` as cross-story parallel when two tasks append the same file (`auth_repo_impl_test.dart`, `welcome_screen_test.dart`, `mocks.dart`).
- **[Story]**: Which user story this task belongs to (`US1`–`US6`, `US7` = password recovery)
- Every task includes an exact file path

## Path Conventions

- Feature: `lib/features/auth/{domain,data,presentation}/`
- DI: `lib/features/auth/auth_injection.dart`
- Routes: `lib/features/auth/presentation/navigation/router.dart`
- Tests: `test/features/auth/` mirroring layers; e2e in `integration_test/auth/`
- Test names MUST start with the `FR-0xx` they exercise (plan Testing Strategy)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, folders, route constants, and test scaffolding

- [X] T001 Create `lib/features/auth/` folder tree (`data/{datasources,models,repositories}`, `domain/{entities,enums,repositories,usecases}`, `presentation/{controller,navigation,pages,validators,widgets}`) plus `lib/features/home/` (`presentation/{pages,navigation}`) and `test/features/auth/{data/{models,repositories},domain/usecases,presentation/{controller,pages}}` and `integration_test/auth/`
- [X] T002 Add `google_sign_in: ^7.2.0`, `sign_in_with_apple: ^8.2.0` to `pubspec.yaml` dependencies and `integration_test` (SDK) to `dev_dependencies`, then run `flutter pub get`
- [X] T003 [P] Add new auth string keys for Error copy ids in spec.md (`invalid_credentials`, `invalid_code`, `expired_code`, `email_taken`, `social_failed`, `too_many_attempts`, `session_expired`, `no_internet`, `avatar_too_large`, `avatar_unsupported_type`, `draft_expired`, `password_letter_requirement`, plus completion-form, guest-gate, and avatar-limit copy) to `generate/strings/lang.json` and run `dart generate/strings/main.dart` to update `assets/lang/*.json` and `lib/config/language/strings.dart`
- [X] T004 [P] Add `emailOtpRequestPath`, `phoneOtpRequestPath`, `socialSignInPath`, `completeRegistrationPath`, and `logoutPath` in `lib/core/api/api_constants.dart`; put the first four on `publicAuthPaths`; leave `logoutPath` off the public list
- [X] T005 [P] Add welcome, login, register, verify-email, phone-sign-in, phone-otp, complete-registration, forgot-password, and reset-password path constants in `lib/config/routes/app_routes.dart` (`home` already exists)
- [X] T006 [P] Create `test/features/auth/fixtures.dart` with a verified `AuthUser`, an unverified account, valid/invalid 6-digit codes, session JSON, `registration_required` JSON per `RegistrationSource`, and a small PNG within JPEG/PNG and 2 MB limits
- [X] T007 Create `test/features/auth/mocks.dart` with `@GenerateMocks` for `AuthRemoteDataSource`, `AuthLocalDataSource`, `AuthRepository`, `SocialAuthService`, `AvatarPicker`, and `ResolveVisitorStateUseCase`; run `dart run build_runner build --delete-conflicting-outputs`. Each later story that adds a use case MUST append that type here and re-run `build_runner` before its tests (see T033, T048, T059, T069, T083, T105).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared domain, local session, validators, blank home, splash routing, welcome shell. No user story work begins until this phase is complete.

**⚠️ CRITICAL**: Blocks all user stories

### Tests (must fail first)

- [X] T008 [P] Unit tests for `AuthValidators` password/email/phone rules (FR-007, FR-007a, FR-007b) in `test/features/auth/presentation/validators/auth_validators_test.dart`
- [X] T009 [P] Widget tests for `AppOtpField` (6 digits, digit-only, RTL) in `test/shared/widgets/app_otp_field_test.dart`
- [X] T010 [P] Bloc tests for `OtpCooldownCubit` driven by an injected ticker (FR-012) in `test/features/auth/presentation/controller/otp_cooldown_cubit_test.dart`
- [X] T011 [P] Unit tests for `AuthLocalDataSourceImpl.readVisitorState` mapping missing and unreadable values to `UserType.firstOpen` (spec edge case) and never treating a draft-only store as `loggedIn` (FR-004) in `test/features/auth/data/datasources/auth_local_datasource_impl_test.dart`
- [X] T012 [P] Bloc tests for `ResolveVisitorStateCubit` success/error (FR-002) in `test/features/auth/presentation/controller/resolve_visitor_state_cubit_test.dart`. A stored draft without a session MUST NOT route as `loggedIn` (FR-004).

### Implementation

- [X] T013 [P] Create `SocialProvider` (wireName only, no `Platform`), `OtpPurpose`, and `RegistrationSource` in `lib/features/auth/domain/enums/social_provider.dart`, `otp_purpose.dart`, and `registration_source.dart`, plus `SocialProviderAvailability` in `lib/features/auth/presentation/social_provider_availability.dart` (FR-029; domain stays free of `dart:io`)
- [X] T014 [P] Create `AuthUser`, `AuthSession`, sealed `AuthOutcome`, sealed `LoginOutcome`, `RegistrationDraft`, and `OtpChallenge` in `lib/features/auth/domain/entities/`
- [X] T015 [P] Create `AuthValidators` combining `FieldValidator.password(minLength: 8, requireNumbers: true)` with a `[A-Za-z]` pattern in `lib/features/auth/presentation/validators/auth_validators.dart`
- [X] T016 [P] Create 6-digit `AppOtpField` in `lib/shared/widgets/app_otp_field.dart`
- [X] T017 [P] Create `RegistrationDraftStorage` implementing `LocalStorageInterface` in `lib/core/services/local_storage/impl/registration_draft_storage.dart`
- [X] T018 [P] Create `AvatarPicker` interface in `lib/features/auth/data/datasources/avatar_picker.dart` and `AvatarPickerImpl` (JPEG/PNG, `maxWidth`/`maxHeight` 1024, reject >2 MB) in `avatar_picker_impl.dart` (FR-006a)
- [X] T019 [P] Create `SocialAuthService` interface and `SocialCredential` in `lib/features/auth/data/datasources/social_auth_service.dart` plus `SocialSignInCancelledException` in `lib/core/error/exceptions.dart` (map to a `Failure` in `toFailure()`)
- [X] T020 Create `AuthRemoteDataSource` in `lib/features/auth/data/datasources/auth_remote_datasource.dart` and `AuthLocalDataSource` in `auth_local_datasource.dart` with the method signatures from `contracts/auth-repository.md`
- [X] T021 Create `AuthRepository` in `lib/features/auth/domain/repositories/auth_repo.dart` with every method from `contracts/auth-repository.md`
- [X] T022 Implement `AuthLocalDataSourceImpl` composing `AccessTokenStorage`, `UserTypeStorage`, and `RegistrationDraftStorage` in `lib/features/auth/data/datasources/auth_local_datasource_impl.dart`
- [X] T023 Implement `AuthRemoteDataSourceImpl` in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` with every method throwing `UnimplementedError` until the owning story fills it in (so the class compiles)
- [X] T024 Implement `AuthRepositoryImpl` with `RepositoryGuard` in `lib/features/auth/data/repositories/auth_repo_impl.dart` delegating all methods to remote/local
- [X] T025 Create `ResolveVisitorStateUseCase` in `lib/features/auth/domain/usecases/resolve_visitor_state_usecase.dart` and `ReadRegistrationDraftUseCase` in `read_registration_draft_usecase.dart`
- [X] T026 Create `OtpCooldownCubit` with injected `Stream<int> Function(int ticks) tick` and sealed `OtpCooldownIdle` / `OtpCooldownCounting` in `lib/features/auth/presentation/controller/otp_cooldown/`
- [X] T027 Create `ResolveVisitorStateCubit` in `lib/features/auth/presentation/controller/resolve_visitor_state/`
- [X] T028 Create `registerAuthDataLayer` and `registerVisitorState` in `lib/features/auth/auth_injection.dart` (cubits `registerFactory`, others `registerLazySingleton`; no types in `ServiceLocator.init()`)
- [X] T029 Create blank `HomeScreen` with a sign-out control and a guest "account required" control in `lib/features/home/presentation/pages/home_screen.dart` and `HomeRoute` in `lib/features/home/presentation/navigation/router.dart` (FR-003, FR-039, FR-043)
- [X] T030 Wire splash: wrap `SplashScreen` in `FeatureScope` + `ResolveVisitorStateCubit` in `lib/features/splash/presentation/navigation/router.dart` and route `firstOpen` → welcome, `loggedIn`/`guest` → home in `lib/features/splash/presentation/pages/splash_screen.dart` (FR-002). Incomplete drafts MUST NOT set `UserType.loggedIn` (FR-004). When `RefreshTokenHelper` invalidates the session, show `session_expired` copy after routing to guest home (FR-044).
- [X] T031 Create welcome/entry `WelcomeScreen` offering register, sign-in, phone, Google, Apple (hidden unless `SocialProviderAvailability.isOffered(SocialProvider.apple)`), and continue-as-guest in `lib/features/auth/presentation/pages/welcome_screen.dart` with stubs navigating to the constants from T005 (FR-001, FR-029). No role picker (FR-047).
- [X] T032 Create typed auth routes with `FeatureScope` in `lib/features/auth/presentation/navigation/router.dart`, then add `...auth.$appRoutes` and `...home.$appRoutes` to `lib/config/routes/app_router.dart` and run `build_runner` for `router.g.dart`

**Checkpoint**: App launches splash → welcome (first open) or home (guest/logged-in). Shared types, local session, validators, and DI compile. User stories can start.

---

## Phase 3: User Story 1 - Create an account with email and password (Priority: P1) 🎯 MVP

**Goal**: Register with avatar, full name, email, phone, password; verify emailed code; land signed in on home.

**Independent Test**: Fresh install → Welcome → Register → valid form → email code → home; session survives restart.

### Tests for User Story 1

- [X] T033 [P] [US1] Unit tests for `RegisterParams.toJson` wire names and null-omission of `avatarPath` in `test/features/auth/domain/usecases/register_usecase_test.dart`; append `RegisterUseCase`, `VerifyEmailUseCase`, `RequestEmailOtpUseCase` to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T034 [P] [US1] Unit tests for `RegisterModel`/`VerifyEmailModel`/`RequestOtpModel` `fromJson` in `test/features/auth/data/models/register_model_test.dart`
- [X] T035 [US1] Repository tests mapping `ServerException`/`ValidationException`/`ConflictException` to `Failure` for `register`/`verifyEmail`/`requestEmailOtp`, and asserting `register` never calls `persistSession` (FR-004), in `test/features/auth/data/repositories/auth_repo_impl_test.dart` (append-only; not parallel with other stories' edits to this file)
- [X] T036 [P] [US1] Bloc tests for `RegisterCubit`, `VerifyEmailCubit`, `RequestEmailOtpCubit` (Loading/Success/Error/fieldErrors/cancel) in `test/features/auth/presentation/controller/register_cubit_test.dart`, `verify_email_cubit_test.dart`, `request_email_otp_cubit_test.dart`
- [X] T037 [P] [US1] Widget tests for register and verify-email screens: holding/loading/success/error, field errors using Error copy ids, optional avatar, duplicate-submit, avatar reject keeps other fields (FR-006b), placeholder when skipped (FR-006c), no role control (FR-047), connectivity shows `no_internet` (FR-049), back from code screen still allows resend (edge case), form text still present after a simulated lifecycle pause without process kill (FR-051), labels present (FR-052) in `test/features/auth/presentation/pages/register_screen_test.dart` and `verify_email_screen_test.dart` (en LTR and ar RTL)

### Implementation for User Story 1

- [X] T038 [P] [US1] Create `RegisterResponse`, `VerifyEmailResponse`, `RequestOtpResponse` entities in `lib/features/auth/domain/entities/` and matching models with `fromJson` in `lib/features/auth/data/models/`
- [X] T039 [P] [US1] Create `RegisterUseCase` + `RegisterParams`, `VerifyEmailUseCase` + `VerifyEmailParams`, `RequestEmailOtpUseCase` + `RequestEmailOtpParams` in `lib/features/auth/domain/usecases/`
- [X] T040 [US1] Implement `register`, `verifyEmail`, and `requestEmailOtp` HTTP calls only in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` (multipart when avatar present). Do **not** write tokens or `UserType` here.
- [X] T041 [US1] After successful `verifyEmail`, call `AuthLocalDataSource.persistSession` from `lib/features/auth/data/repositories/auth_repo_impl.dart` only (FR-011, FR-042). Never persist a session for an unverified registration.
- [X] T042 [P] [US1] Create `RegisterCubit` in `lib/features/auth/presentation/controller/register/`, `VerifyEmailCubit` in `verify_email/`, `RequestEmailOtpCubit` in `request_email_otp/`
- [X] T043 [US1] Add `registerRegister` and `registerVerifyEmail` (includes request-otp + cooldown factories) in `lib/features/auth/auth_injection.dart`
- [X] T044 [US1] Build `RegisterScreen` with `AppTextFormField` name/email/`phoneWithCountryCode`/password, optional avatar via `AvatarPicker`, `FieldErrorsScope`, 409 → offer sign-in, keep fields on avatar reject, default placeholder when skipped, no role picker (FR-005–FR-010, FR-006b, FR-006c, FR-047, FR-052) in `lib/features/auth/presentation/pages/register_screen.dart` plus form widgets under `lib/features/auth/presentation/widgets/`
- [X] T045 [US1] Build `VerifyEmailScreen` using `AppOtpField` + `OtpCooldownCubit` seeded from `resendAvailableInSeconds` (never hardcode 60) in `lib/features/auth/presentation/pages/verify_email_screen.dart` (FR-012, FR-013)
- [X] T046 [US1] Wire `RegisterRoute` and `VerifyEmailRoute` `FeatureScope` + `BlocProvider`s in `lib/features/auth/presentation/navigation/router.dart` and navigate welcome → register → verify-email → home
- [X] T047 [US1] Integration test: register → verify email → home, session survives restart, in `integration_test/auth/us1_register_email_test.dart`

**Checkpoint**: Story 1 works independently against the blank home screen (SC-013)

---

## Phase 4: User Story 2 - Sign in with email and password (Priority: P2)

**Goal**: Returning users sign in with email and password, no email code. Unverified emails detour to code entry. Wrong credentials never disclose whether the email exists.

**Independent Test**: Sign in with a verified account → home with no code prompt; wrong password rejected with the same message as an unknown email.

### Tests for User Story 2

- [X] T048 [P] [US2] Unit tests for `LoginParams.toJson` and `LoginUseCase` pass-through in `test/features/auth/domain/usecases/login_usecase_test.dart`; append `LoginUseCase` to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T049 [P] [US2] Model tests for both `LoginOutcome` branches (`session` vs `email_verification_required`) in `test/features/auth/data/models/login_model_test.dart`
- [X] T050 [US2] Repository tests for 401 mapping to `invalid_credentials` (same body whether unknown email or wrong password) and throttle 429 / FR-018a five OTP guesses (FR-016, FR-018, FR-018a) in `test/features/auth/data/repositories/auth_repo_impl_test.dart`
- [X] T051 [P] [US2] Bloc tests for `LoginCubit` emitting `LoginSucceeded` vs `LoginNeedsEmailVerification` (FR-015, FR-017) in `test/features/auth/presentation/controller/login_cubit_test.dart`
- [X] T052 [P] [US2] Widget tests for login screen four `ApiCallState` branches, identical wrong-password/unknown-email copy (`invalid_credentials`), forgot-password link (FR-014, FR-046a), and `no_internet` (FR-049) in `test/features/auth/presentation/pages/login_screen_test.dart`

### Implementation for User Story 2

- [X] T053 [P] [US2] Create `LoginResponse` entity in `lib/features/auth/domain/entities/login_response.dart` and `LoginModel.fromJson` in `lib/features/auth/data/models/login_model.dart`
- [X] T054 [P] [US2] Create `LoginUseCase` + `LoginParams` in `lib/features/auth/domain/usecases/login_usecase.dart`
- [X] T055 [US2] Implement `login` in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` and persist session only on `LoginSucceeded` in `lib/features/auth/data/repositories/auth_repo_impl.dart`
- [X] T056 [US2] Create `LoginCubit` in `lib/features/auth/presentation/controller/login/` and `registerLogin` in `lib/features/auth/auth_injection.dart`
- [X] T057 [US2] Build `LoginScreen` (no OTP on this path) in `lib/features/auth/presentation/pages/login_screen.dart`; route unverified success to `VerifyEmailScreen`; add `LoginRoute` in `lib/features/auth/presentation/navigation/router.dart`
- [X] T058 [US2] Integration test: verified login → home with no code; unverified login → code screen, in `integration_test/auth/us2_login_email_test.dart`

**Checkpoint**: Stories 1 and 2 both work independently

---

## Phase 5: User Story 3 - Continue as a guest (Priority: P3)

**Goal**: Continue as guest to home; persist guest; gate account-required actions; sign-out returns to guest.

**Independent Test**: Fresh install → Continue as guest → home; relaunch still guest; protected control shows sign-in/register; sign-out from signed-in home returns to guest.

### Tests for User Story 3

- [X] T059 [P] [US3] Unit tests for `ContinueAsGuestUseCase` and `LogoutUseCase` in `test/features/auth/domain/usecases/continue_as_guest_usecase_test.dart` and `logout_usecase_test.dart`; append those use cases to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T060 [US3] Repository tests: `markGuest` / `clearSession` and logout still succeeding locally when remote fails (FR-043) in `test/features/auth/data/repositories/auth_repo_impl_test.dart`
- [X] T061 [P] [US3] Bloc tests for `GuestModeCubit` and `LogoutCubit` in `test/features/auth/presentation/controller/guest_mode_cubit_test.dart` and `logout_cubit_test.dart`
- [X] T062 [P] [US3] Widget tests for welcome guest action, `GuestGateDialog`, and home sign-out/guest-gate controls in `test/features/auth/presentation/pages/welcome_screen_test.dart`, `test/features/auth/presentation/widgets/guest_gate_dialog_test.dart`, and `test/features/home/presentation/pages/home_screen_test.dart`

### Implementation for User Story 3

- [X] T063 [P] [US3] Create `ContinueAsGuestUseCase` in `lib/features/auth/domain/usecases/continue_as_guest_usecase.dart` and `LogoutUseCase` in `logout_usecase.dart`; add `LogoutResponse` entity/model
- [X] T064 [US3] Implement `logout` in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` (authenticated, not on `publicAuthPaths`) and always `clearSession` locally in `lib/features/auth/data/repositories/auth_repo_impl.dart`
- [X] T065 [P] [US3] Create `GuestModeCubit` in `lib/features/auth/presentation/controller/guest_mode/` and `LogoutCubit` in `logout/`
- [X] T066 [US3] Add `registerLogout` in `lib/features/auth/auth_injection.dart`; provide `LogoutCubit` on `HomeRoute` in `lib/features/home/presentation/navigation/router.dart`
- [X] T067 [US3] Implement `GuestGateDialog` + `context.requireAccount()` in `lib/features/auth/presentation/widgets/guest_gate_dialog.dart` and wire welcome "continue as guest" plus home's two controls (FR-037–FR-040, FR-043)
- [X] T068 [US3] Integration test: guest → home → relaunch guest → gate offers sign-in/register; signed-in sign-out → guest; guest then completes register/login and stays on home signed-in with no extra welcome choice (SC-011, FR-040); session-expired path shows `session_expired` then guest (FR-044), in `integration_test/auth/us3_guest_mode_test.dart`

**Checkpoint**: Guest cycle and sign-out work without Stories 4–6

---

## Phase 6: User Story 4 - Sign in with a phone one-time code (Priority: P4)

**Goal**: Request/verify a phone code on every sign-in. Existing account → home. Unknown number → completion form (phone locked, no email OTP) with draft resume.

**Independent Test**: Known number → code → home. Unused number → completion form with phone fixed. Abandon and retry same number → completion form again.

### Tests for User Story 4

- [X] T069 [P] [US4] Unit tests for `RequestPhoneOtpParams`/`VerifyPhoneOtpParams`/`CompleteRegistrationParams.toJson` in `test/features/auth/domain/usecases/request_phone_otp_usecase_test.dart`, `verify_phone_otp_usecase_test.dart`, `complete_registration_usecase_test.dart`; append those use cases to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T070 [P] [US4] Model tests for both `AuthOutcome` branches and phone-source draft fields in `test/features/auth/data/models/verify_phone_otp_model_test.dart`
- [X] T071 [US4] Repository tests for auto-link session (FR-041, FR-041a, FR-041b) vs `registration_required`, draft persist, expired token → `draft_expired` (FR-026a), and fifth wrong OTP → throttle (FR-018a) in `test/features/auth/data/repositories/auth_repo_impl_test.dart`
- [X] T072 [P] [US4] Bloc tests for `RequestPhoneOtpCubit`, `VerifyPhoneOtpCubit`, `CompleteRegistrationCubit` in `test/features/auth/presentation/controller/request_phone_otp_cubit_test.dart`, `verify_phone_otp_cubit_test.dart`, `complete_registration_cubit_test.dart`
- [X] T073 [P] [US4] Widget tests: phone locked/non-editable on completion form; no email-code step (FR-023, FR-024); no role control (FR-047) in `test/features/auth/presentation/pages/phone_sign_in_screen_test.dart`, `phone_otp_screen_test.dart`, `complete_registration_screen_test.dart`

### Implementation for User Story 4

- [X] T074 [P] [US4] Create `VerifyPhoneOtpResponse` and `CompleteRegistrationResponse` entities/models in `lib/features/auth/domain/entities/` and `lib/features/auth/data/models/`
- [X] T075 [P] [US4] Create `RequestPhoneOtpUseCase`, `VerifyPhoneOtpUseCase`, `CompleteRegistrationUseCase` with params in `lib/features/auth/domain/usecases/`
- [X] T076 [US4] Implement `requestPhoneOtp`, `verifyPhoneOtp` (`purpose: phone_sign_in`), and `completeRegistration` HTTP in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`; save/clear draft and persist session only from `lib/features/auth/data/repositories/auth_repo_impl.dart` (FR-026, FR-025)
- [X] T077 [P] [US4] Create the three cubits in `lib/features/auth/presentation/controller/request_phone_otp/`, `verify_phone_otp/`, `complete_registration/`
- [X] T078 [US4] Add `registerPhoneSignIn` and `registerCompleteRegistration` in `lib/features/auth/auth_injection.dart`
- [X] T079 [US4] Build `PhoneSignInScreen` and `PhoneOtpScreen` in `lib/features/auth/presentation/pages/` using `PhoneValidationService` for `dialing_code` + NSN (FR-019–FR-021, FR-027)
- [X] T080 [US4] Build `CompleteRegistrationScreen` driven by `RegistrationSource` (phone source: collect name/email/password/avatar; phone display-only) in `lib/features/auth/presentation/pages/complete_registration_screen.dart`
- [X] T081 [US4] Wire phone and complete-registration routes in `lib/features/auth/presentation/navigation/router.dart`; resume draft on welcome/phone re-entry via `ReadRegistrationDraftUseCase` (FR-026). 409/expired token shows `draft_expired` and restarts the phone path (FR-026a). Social-source drafts of the same provider resume in T094 (FR-036).
- [X] T082 [US4] Integration test: existing phone → home; new phone → complete → home; abandon → resume, in `integration_test/auth/us4_phone_otp_test.dart`

**Checkpoint**: Phone path works with or without Stories 5–6

---

## Phase 7: User Story 5 - Sign in with Google (Priority: P5)

**Goal**: Google authorize → existing/linked account goes home; new account gets completion form with email locked and a required phone OTP.

**Independent Test**: Fake linked Google → home. Fake unlinked Google → completion (email locked) + phone code → home. Cancel → welcome, no partial account.

### Tests for User Story 5

- [X] T083 [P] [US5] Unit tests for `SocialSignInUseCase` passing `SocialProvider.google` in `test/features/auth/domain/usecases/social_sign_in_usecase_test.dart`; append `SocialSignInUseCase` to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T084 [P] [US5] Model tests for social `AuthOutcome` session vs google-source draft (FR-030–FR-032) in `test/features/auth/data/models/social_sign_in_model_test.dart`
- [X] T085 [US5] Repository tests: cancellation → `SocialSignInCancelledException` does not persist a draft (FR-035); other failures map to `social_failed` (FR-035a); auto-link by email (FR-041) in `test/features/auth/data/repositories/auth_repo_impl_test.dart`
- [X] T086 [P] [US5] Bloc tests for `SocialSignInCubit`: session, registration required, silent cancel (no error emit for cancel), surfaced `social_failed` in `test/features/auth/presentation/controller/social_sign_in_cubit_test.dart`
- [X] T087 [P] [US5] Widget tests: Google button on welcome; completion form email locked; phone OTP required before create (FR-031–FR-033); no role control (FR-047) in `test/features/auth/presentation/pages/welcome_screen_test.dart` and `complete_registration_screen_test.dart`

### Implementation for User Story 5

- [X] T088 [P] [US5] Create `SocialSignInResponse` entity/model in `lib/features/auth/domain/entities/social_sign_in_response.dart` and `lib/features/auth/data/models/social_sign_in_model.dart`
- [X] T089 [P] [US5] Create `SocialSignInUseCase` + `SocialSignInParams` in `lib/features/auth/domain/usecases/social_sign_in_usecase.dart`
- [X] T090 [US5] Implement `SocialAuthServiceImpl` Google path (`initialize` then `authenticate`, map canceled → `SocialSignInCancelledException`) in `lib/features/auth/data/datasources/social_auth_service_impl.dart`
- [X] T091 [US5] Implement `socialSignIn` and social-purpose `verifyPhoneOtp` (`purpose: verify_phone`) HTTP only in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`. Persist draft on `AuthRegistrationRequired` and persist session on `AuthSessionEstablished` only from `lib/features/auth/data/repositories/auth_repo_impl.dart`.
- [X] T092 [US5] Create `SocialSignInCubit` in `lib/features/auth/presentation/controller/social_sign_in/` and `registerSocialSignIn` in `lib/features/auth/auth_injection.dart`
- [X] T093 [US5] Extend `CompleteRegistrationScreen` for `RegistrationSource.google` (email locked, collect name/phone/password/avatar, phone OTP before submit) in `lib/features/auth/presentation/pages/complete_registration_screen.dart`
- [X] T094 [US5] Wire Google button on `WelcomeScreen` to `fSocialSignIn(SocialProvider.google)` in `lib/features/auth/presentation/pages/welcome_screen.dart` and provide cubit on `WelcomeRoute` in `lib/features/auth/presentation/navigation/router.dart`. A second Google sign-in with a stored google-source draft MUST open `CompleteRegistrationScreen` (FR-036).
- [X] T095 [US5] Integration test with fake `SocialAuthService`: linked → home; unlinked → complete + phone OTP → home; cancel → welcome with no snackbar; non-cancel failure → `social_failed`; abandon then same Google account → resume completion (FR-036), in `integration_test/auth/us5_google_sign_in_test.dart`

**Checkpoint**: Google path works; Apple button may still be a stub

---

## Phase 8: User Story 6 - Sign in with Apple (Priority: P6)

**Goal**: Same shape as Google. Hide Apple where unavailable. Accept private-relay emails. Never block registration when Apple withholds the real address.

**Independent Test**: Linked Apple → home. Unlinked with relay email → completion succeeds. Android welcome has no Apple button.

### Tests for User Story 6

- [X] T096 [P] [US6] Unit tests for `SocialProviderAvailability.isOffered` in `test/features/auth/presentation/social_provider_availability_test.dart` (not under `domain/`)
- [X] T097 [P] [US6] Model tests for apple-source draft with relay `verified_email` (FR-034) in `test/features/auth/data/models/social_sign_in_model_test.dart`
- [X] T098 [P] [US6] Bloc tests: `fSocialSignIn(SocialProvider.apple)` session vs draft vs cancel in `test/features/auth/presentation/controller/social_sign_in_cubit_test.dart`
- [X] T099 [P] [US6] Widget tests: Apple control absent when unavailable; present on iOS (FR-029) in `test/features/auth/presentation/pages/welcome_screen_test.dart`

### Implementation for User Story 6

- [X] T100 [US6] Implement Apple path in `lib/features/auth/data/datasources/social_auth_service_impl.dart` (`SignInWithApple.getAppleIDCredential`, canceled → `SocialSignInCancelledException`; send `authorization_code` + optional `full_name`). When Apple omits email on a later authorization, reuse draft/stored email (FR-034a).
- [X] T101 [US6] Extend `CompleteRegistrationScreen` for `RegistrationSource.apple` (email locked, including relay) in `lib/features/auth/presentation/pages/complete_registration_screen.dart` (FR-034)
- [X] T102 [US6] Show Apple button on `WelcomeScreen` only when `SocialProviderAvailability.isOffered(SocialProvider.apple)` in `lib/features/auth/presentation/pages/welcome_screen.dart` (FR-029)
- [X] T103 [US6] Document iOS Sign in with Apple capability and URL scheme in `specs/001-auth-login-register/quickstart.md` (already outlined; confirm steps match the impl)
- [X] T104 [US6] Integration test with fake Apple credential: linked → home; relay email → complete → home; second authorization omitting email still completes (FR-034a), in `integration_test/auth/us6_apple_sign_in_test.dart`

**Checkpoint**: All six entry paths independently demonstrable

---

## Phase 9: User Story 7 - Recover a forgotten password (Priority: P7)

**Goal**: From login, request an email reset code, verify it, set a new password meeting FR-007a, sign in to home. Same response for unknown emails and passwordless accounts.

**Independent Test**: Login → Forgot password → email → code → new password → home signed in (SC-012).

### Tests for User Story 7

- [X] T105 [P] [US7] Unit tests for `RequestPasswordResetParams`/`ResetPasswordParams.toJson` in `test/features/auth/domain/usecases/request_password_reset_usecase_test.dart` and `reset_password_usecase_test.dart`; append those use cases to `test/features/auth/mocks.dart` and re-run `build_runner`
- [X] T106 [US7] Repository tests: identical handling for unknown email vs no-password account; used-once code → conflict (FR-046b, FR-046d) in `test/features/auth/data/repositories/auth_repo_impl_test.dart`
- [X] T107 [P] [US7] Bloc tests for `RequestPasswordResetCubit` and `ResetPasswordCubit` in `test/features/auth/presentation/controller/request_password_reset_cubit_test.dart` and `reset_password_cubit_test.dart`
- [X] T108 [P] [US7] Widget tests for forgot-password and reset screens; new password uses `AuthValidators.password` (FR-007b, FR-046c) in `test/features/auth/presentation/pages/forgot_password_screen_test.dart` and `reset_password_screen_test.dart`

### Implementation for User Story 7

- [X] T109 [P] [US7] Create `RequestPasswordResetResponse`/`ResetPasswordResponse` entities/models in `lib/features/auth/domain/entities/` and `lib/features/auth/data/models/`
- [X] T110 [P] [US7] Create `RequestPasswordResetUseCase` and `ResetPasswordUseCase` with params in `lib/features/auth/domain/usecases/`
- [X] T111 [US7] Implement `requestPasswordReset` and `resetPassword` HTTP in `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`; persist session on reset only from `lib/features/auth/data/repositories/auth_repo_impl.dart`
- [X] T112 [P] [US7] Create cubits in `lib/features/auth/presentation/controller/request_password_reset/` and `reset_password/`
- [X] T113 [US7] Add `registerPasswordRecovery` in `lib/features/auth/auth_injection.dart`
- [X] T114 [US7] Build `ForgotPasswordScreen` and `ResetPasswordScreen` in `lib/features/auth/presentation/pages/` and link from `LoginScreen` (FR-046a)
- [X] T115 [US7] Wire recovery routes in `lib/features/auth/presentation/navigation/router.dart`
- [X] T116 [US7] Integration test: forgot → code → new password → home, in `integration_test/auth/us7_password_recovery_test.dart`

**Checkpoint**: Password recovery complete; login no longer has a dead end

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Coverage, logging, localization, and quickstart validation across all stories

- [X] T117 [P] Add tests that captured logs contain no password or OTP for every auth operation (FR-045, SC-010) in `test/features/auth/data/datasources/auth_remote_datasource_impl_log_test.dart`
- [X] T118 [P] Confirm every new unauthenticated path is on `publicAuthPaths` and covered by `test/core/api/api_constants_test.dart`
- [X] T119 [P] Widget-test remaining auth screens in both `en` LTR and `ar` RTL (FR-050, SC-008) under `test/features/auth/presentation/pages/`
- [X] T120 Assert `AuthValidators.password` is the only password rule used on register, phone complete, social complete, and reset (FR-007b) in `test/features/auth/presentation/validators/auth_validators_test.dart`
- [X] T121 Run `flutter analyze` (0 issues) and `flutter test --coverage`; confirm ≥90% line coverage of `lib/features/auth/**` excluding `*.g.dart`, `*.mocks.dart`, `social_auth_service_impl.dart`, and `avatar_picker_impl.dart` per plan Testing Strategy
- [X] T122 Execute `specs/001-auth-login-register/quickstart.md` verification steps for Stories 1–7 on a device or emulator
- [X] T123 [P] Search `test/features/auth/` and `integration_test/auth/` for every spec FR id (`FR-001`–`FR-052`, including `FR-006a`/`b`/`c`, `FR-007a`/`b`, `FR-018a`, `FR-026a`, `FR-034a`, `FR-035a`, `FR-041a`/`b`, `FR-046a`–`d`) and add any missing named tests

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**
- **US1 (Phase 3)**: After Foundational — MVP
- **US2 (Phase 4)**: After Foundational; reuses US1 verify-email screen for FR-017
- **US3 (Phase 5)**: After Foundational; independently testable; sign-out uses home from Phase 2
- **US4 (Phase 6)**: After Foundational; introduces completion form reused by US5/US6
- **US5 (Phase 7)**: After Foundational; should follow US4 so completion form already exists
- **US6 (Phase 8)**: After US5 (same cubit/service file)
- **US7 (Phase 9)**: After US2 (entered from login); reuses OTP cooldown/widget from US1
- **Polish (Phase 10)**: After the stories you intend to ship

### User Story Dependencies

- **US1**: After Phase 2 only
- **US2**: After Phase 2; shares `VerifyEmailScreen` with US1 (implement US1 first if staffing is serial)
- **US3**: After Phase 2 only
- **US4**: After Phase 2 only
- **US5**: After US4 recommended (shared `CompleteRegistrationScreen`)
- **US6**: After US5 (extends `SocialAuthServiceImpl` + welcome button)
- **US7**: After US2 recommended (forgot-password link on login)

### Within Each User Story

1. Tests first — confirm they fail
2. Entities/models/params
3. Datasource + repository
4. Cubit + DI
5. Screens + routes
6. Integration test last

### Parallel Opportunities

- Phase 1: T003, T004, T005, T006 in parallel after T001/T002
- Phase 2: T008–T012 tests in parallel; T013–T019 implementations in parallel
- After Phase 2, **US1, US3, and US4 can start in parallel** if staffed (different screens; watch `auth_repo_impl.dart` and `auth_injection.dart` conflicts)
- US2 can overlap US1 on different files except `verify_email` route
- US5/US6 must stay serial with each other

---

## Parallel Example: User Story 1

```bash
# Tests together:
Task: "T033 RegisterParams.toJson tests in test/features/auth/domain/usecases/register_usecase_test.dart"
Task: "T034 Register/VerifyEmail/RequestOtp fromJson tests in test/features/auth/data/models/register_model_test.dart"
Task: "T036 Register/VerifyEmail/RequestEmailOtp cubit tests in test/features/auth/presentation/controller/"

# Then implementation (params/entities in parallel, then datasource):
Task: "T038 RegisterResponse entities and models"
Task: "T039 Register/VerifyEmail/RequestEmailOtp use cases"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 Setup
2. Phase 2 Foundational
3. Phase 3 User Story 1
4. **STOP**: register → email code → home, session survives restart
5. Demo

### Incremental Delivery

1. Setup + Foundational → splash routing works
2. US1 → MVP (accounts exist)
3. US2 → returning users
4. US3 → guest + sign-out (full entry-to-home cycle)
5. US4 → phone
6. US5 then US6 → social
7. US7 → recovery
8. Polish → coverage gate

### Parallel Team Strategy

1. Team finishes Setup + Foundational together
2. Then:
   - Dev A: US1 → US2 → US7
   - Dev B: US3
   - Dev C: US4 → US5 → US6
3. Coordinate merges on `auth_repo_impl.dart`, `auth_injection.dart`, and `router.dart`

---

## Notes

- [P] = different files, no dependency on incomplete tasks
- Do not register auth types in `lib/injection_container.dart`
- Do not hardcode OTP expiry/cooldown literals; use `expiresInSeconds` / `resendAvailableInSeconds`
- Provider cancellation is silent (FR-035); real failures show `social_failed` (FR-035a)
- Session and draft persistence belong in the repository via `AuthLocalDataSource`, never in the remote datasource
- Domain `SocialProvider` has `wireName` only; `SocialProviderAvailability` lives in presentation
- Exclude `social_auth_service_impl.dart` and `avatar_picker_impl.dart` from the 90% denominator
- Commit after each task or logical group
- Stop at any checkpoint and validate the story independently
