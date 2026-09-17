# Contract: Auth Domain Interfaces

**Feature**: `001-auth-login-register` | **Date**: 2026-09-17

The Dart-level contract between layers. One repository method per operation, one use case per
repository method, one cubit per user-facing operation (Principle I).

---

## `AuthRepository` — `domain/repositories/auth_repo.dart`

```dart
abstract class AuthRepository {
  // Email and password
  Future<Either<Failure, RegisterResponse>> register({required Params params});
  Future<Either<Failure, LoginResponse>> login({required Params params});
  Future<Either<Failure, VerifyEmailResponse>> verifyEmail({required Params params});
  Future<Either<Failure, RequestOtpResponse>> requestEmailOtp({required Params params});

  // Phone one-time code
  Future<Either<Failure, RequestOtpResponse>> requestPhoneOtp({required Params params});
  Future<Either<Failure, VerifyPhoneOtpResponse>> verifyPhoneOtp({required Params params});

  // Social
  Future<Either<Failure, SocialSignInResponse>> socialSignIn({required Params params});

  // Shared completion for phone-first and social drafts
  Future<Either<Failure, CompleteRegistrationResponse>> completeRegistration({
    required Params params,
  });

  // Password recovery
  Future<Either<Failure, RequestPasswordResetResponse>> requestPasswordReset({
    required Params params,
  });
  Future<Either<Failure, ResetPasswordResponse>> resetPassword({required Params params});

  // Session and visitor state (local)
  Future<Either<Failure, LogoutResponse>> logout({required Params params});
  Future<Either<Failure, UserType>> resolveVisitorState({required Params params});
  Future<Either<Failure, void>> continueAsGuest({required Params params});
  Future<Either<Failure, RegistrationDraft?>> readRegistrationDraft({required Params params});
}
```

`Params` rather than concrete param types in the signature matches the existing `ProfileRepository`
convention. Every method returns `Either<Failure, T>` (Principle IV).

---

## Data sources

Two sources, split by responsibility (§3.1): one speaks HTTP, one speaks device storage.

### `AuthRemoteDataSource` — `data/datasources/auth_remote_datasource.dart`

One method per endpoint in `contracts/auth-api.md`, each returning a `*Model`. Throws
`AppException` on failure; never returns `Either`.

```dart
abstract class AuthRemoteDataSource {
  Future<RegisterModel> register({required Params params});
  Future<LoginModel> login({required Params params});
  Future<VerifyEmailModel> verifyEmail({required Params params});
  Future<RequestOtpModel> requestEmailOtp({required Params params});
  Future<RequestOtpModel> requestPhoneOtp({required Params params});
  Future<VerifyPhoneOtpModel> verifyPhoneOtp({required Params params});
  Future<SocialSignInModel> socialSignIn({required Params params});
  Future<CompleteRegistrationModel> completeRegistration({required Params params});
  Future<RequestPasswordResetModel> requestPasswordReset({required Params params});
  Future<ResetPasswordModel> resetPassword({required Params params});
  Future<LogoutModel> logout({required Params params});
}
```

Each implementation follows the profile datasource shape exactly: call `dioConsumer`, pass
`requestCancelToken(params.cancellation)`, check `ApiResponse.isSuccess`, return
`Model.fromJson(response)`, otherwise `throw ApiResponse.exceptionOf(response)`.

### `AuthLocalDataSource` — `data/datasources/auth_local_datasource.dart`

Owns the device side of a session. Throws `CacheException` on failure.

```dart
abstract class AuthLocalDataSource {
  Future<void> persistSession(AuthSession session);   // token + UserType.loggedIn
  Future<void> clearSession();                        // token cleared + UserType.guest
  Future<void> markGuest();
  Future<UserType> readVisitorState();                // missing value → firstOpen
  Future<void> saveRegistrationDraft(RegistrationDraft draft);
  Future<RegistrationDraft?> readRegistrationDraft();
  Future<void> clearRegistrationDraft();
}
```

Composes the already-registered `AccessTokenStorage` and `UserTypeStorage` plus the new
`RegistrationDraftStorage`. It does not create them — they are injected.

### `SocialAuthService` — `data/datasources/social_auth_service.dart`

The provider SDK boundary, behind an interface so tests never touch a real Google or Apple flow
(Principle II, §2.3).

```dart
abstract interface class SocialAuthService {
  Future<SocialCredential> authorize(SocialProvider provider);
}
```

`SocialCredential` is a data-layer record of `idToken`, optional `authorizationCode`, and optional
`fullName`. User cancellation throws a dedicated `SocialSignInCancelledException` (an `AppException`)
so the cubit can return the user to the entry screen silently rather than showing an error
(FR-035).

---

## Use cases and params

Each extends `UseCase<Type, Params>`, delegates to one repository method, and co-locates its
`*Params` with `toJson()` in the same file.

| Use case | Params fields (Dart names) |
|---|---|
| `RegisterUseCase` | `fullName`, `email`, `dialingCode`, `phone`, `password`, `avatarPath?` |
| `LoginUseCase` | `email`, `password` |
| `VerifyEmailUseCase` | `email`, `code` |
| `RequestEmailOtpUseCase` | `email`, `purpose` |
| `RequestPhoneOtpUseCase` | `dialingCode`, `phone` |
| `VerifyPhoneOtpUseCase` | `dialingCode`, `phone`, `code`, `purpose` |
| `SocialSignInUseCase` | `provider` |
| `CompleteRegistrationUseCase` | `registrationToken`, `source`, `fullName`, `password`, `email?`, `dialingCode?`, `phone?`, `avatarPath?` |
| `RequestPasswordResetUseCase` | `email` |
| `ResetPasswordUseCase` | `email`, `code`, `password` |
| `LogoutUseCase` | `NoParams` |
| `ResolveVisitorStateUseCase` | `NoParams` |
| `ContinueAsGuestUseCase` | `NoParams` |
| `ReadRegistrationDraftUseCase` | `NoParams` |

`toJson()` maps to the wire names in `contracts/auth-api.md` and omits null values, matching
`UpdateStudentProfileParams`. `avatarPath` is not part of `toJson()` — the datasource turns it into a
`MultipartFile` when building `FormData`.

---

## Cubits

One per user-facing operation. States are `typedef`s of `ApiCallState<T>` in a `part` file, except
`OtpCooldownCubit` (research R8).

| Cubit | Action | State type |
|---|---|---|
| `RegisterCubit` | `fRegister(...)` | `ApiCallState<OtpChallenge>` |
| `VerifyEmailCubit` | `fVerifyEmail(...)` | `ApiCallState<AuthSession>` |
| `RequestEmailOtpCubit` | `fRequestEmailOtp(...)` | `ApiCallState<OtpChallenge>` |
| `LoginCubit` | `fLogin(...)` | `ApiCallState<LoginOutcome>` |
| `RequestPhoneOtpCubit` | `fRequestPhoneOtp(...)` | `ApiCallState<OtpChallenge>` |
| `VerifyPhoneOtpCubit` | `fVerifyPhoneOtp(...)` | `ApiCallState<AuthOutcome>` |
| `SocialSignInCubit` | `fSocialSignIn(SocialProvider)` | `ApiCallState<AuthOutcome>` |
| `CompleteRegistrationCubit` | `fCompleteRegistration(...)` | `ApiCallState<AuthSession>` |
| `RequestPasswordResetCubit` | `fRequestPasswordReset(...)` | `ApiCallState<OtpChallenge>` |
| `ResetPasswordCubit` | `fResetPassword(...)` | `ApiCallState<AuthSession>` |
| `LogoutCubit` | `fLogout()` | `ApiCallState<void>` |
| `ResolveVisitorStateCubit` | `fResolveVisitorState()` | `ApiCallState<UserType>` |
| `GuestModeCubit` | `fContinueAsGuest()` | `ApiCallState<void>` |
| `OtpCooldownCubit` | `fStart(int seconds)` | sealed `OtpCooldownState` |

`LoginOutcome` is a sealed type with `LoginSucceeded(session)` and `LoginNeedsEmailVerification(challenge)`
variants, mirroring endpoint 4's two success shapes so FR-017's routing is compiler-checked.

Every cubit mixes in `CubitRequestCanceller`, emits `ApiCallLoading` first, and folds into either
`ApiCallError.fromFailure(failure, fallbackMessage: Strings.pleaseTryAgainLater)` or a success
state — the exact pattern in `GetStudentProfileCubit`.

---

## DI registration — `auth_injection.dart`

Granular `register*` functions, bound per route by `FeatureScope` (Principle II).

```dart
void registerAuthDataLayer(GetIt sl);        // storages, datasources, social service, repository
void registerRegister(GetIt sl);
void registerLogin(GetIt sl);
void registerVerifyEmail(GetIt sl);          // + RequestEmailOtpCubit + OtpCooldownCubit
void registerPhoneSignIn(GetIt sl);          // request + verify
void registerSocialSignIn(GetIt sl);
void registerCompleteRegistration(GetIt sl);
void registerPasswordRecovery(GetIt sl);     // request reset + reset
void registerVisitorState(GetIt sl);         // resolve + guest mode
void registerLogout(GetIt sl);
```

Cubits use `registerFactory`; use cases, repositories, datasources, and storages use
`registerLazySingleton`.
