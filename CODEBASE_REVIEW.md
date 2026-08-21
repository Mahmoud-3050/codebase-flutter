# Flutter Codebase Review — `lib/` and `packages/`

**Date:** 2026-08-19  
**Reviewer:** Staff-level audit (flutter-codebase-review skill)  
**Scope:** `lib/` (109 Dart files) and `packages/` (24 Dart files: `either`, `field_validator`, `language`)  
**Depth:** Full audit — probed features: `profile` (7 operations), `theme`; entry point: `splash`

---

## 1. Verdict and Summary

> **Yes, but targeted fixes are needed before this ships — 66/100 (Needs improvement).** The one architectural pattern that exists (the `profile` feature) is genuinely clean and matches the project's own documented Clean Architecture rules exactly. But the codebase is early-stage: only two real features exist, the more complete one (`profile`) is fully built but **never wired into the running app**, there is a **production TLS certificate-validation bypass**, and `lib/` business logic has **zero automated test coverage**. None of this requires re-architecture — it's a short, concrete punch list.

---

## 2. Scorecard

| Category | Score | Weight | Points |
|---|---:|---:|---:|
| Architecture | 7 | 20% | 14.0 |
| Code quality | 7 | 15% | 10.5 |
| Flutter best practices | 6 | 15% | 9.0 |
| State management | 8 | 10% | 8.0 |
| Project structure | 8 | 10% | 8.0 |
| Maintainability | 7 | 10% | 7.0 |
| Reliability | 5 | 5% | 2.5 |
| Performance | 7 | 5% | 3.5 |
| Testing | 3 | 5% | 1.5 |
| Security | 2 | 3% | 0.6 |
| Localization & accessibility | 7 | 2% | 1.4 |
| **Overall** | | | **66.0 → Needs improvement** |

---

## 3. Strengths

- **Clean Architecture is real, not aspirational, in `profile`.** `Cubit → UseCase → Repository interface → DataSource`, `Either<Failure, T>` end-to-end, sealed `Initial/Loading/Success/Error` states, `f`-prefixed cubit actions. It matches `.cursor/rules/08-clean-architecture.mdc` exactly.
- **Cross-cutting concerns are properly extracted into independent packages**: `packages/either`, `packages/field_validator`, `packages/language` each ship real unit tests with fakes (`FakeAssetLoader`, `FakeHydratedStorage`).
- **Localization discipline is consistent**: user-facing strings run through `Strings.xxx.tr` rather than hardcoded literals.
- **DI convention is applied consistently**: `GetIt` with `registerFactory` for cubits and `registerLazySingleton` for everything else, in both `theme_injection.dart` and `profile_injection.dart`.
- **Widget reuse via named factories** (`AppTextFormField.emailTextField`, `.phoneTextField`, `.search`, …) instead of duplicating `TextFormField` configuration per screen.

---

## 4. Findings

### P0 — fix before next release

#### [Critical] [Security] TLS certificate validation disabled unconditionally

**Evidence:** `lib/core/api/dio_consumer.dart`, lines 64–76 — inside `DioConsumerImpl`'s constructor:

```dart
client.badCertificateCallback =
    (X509Certificate cert, String host, int port) => true;
```

This runs for every build, not gated by `kDebugMode` or an environment flag.

**Problem:** Any TLS certificate — expired, self-signed, or attacker-presented — is accepted for all API traffic, in every build configuration, including production (`ApiConstants.live`).

**Impact:** Trivial man-in-the-middle interception of all network traffic, including login credentials and access tokens, in production.

**Fix:** Remove the override. If self-signed certs are genuinely needed for a staging environment, gate the callback behind `assert(kDebugMode)` plus an explicit staging flag so it is structurally impossible to ship in a release build.

**Confidence:** Confirmed

---

#### [High] [Security] Access token stored in plaintext on iOS, encrypted on Android

**Evidence:** `lib/core/api/dio_consumer.dart` `_handleAccessTokenHeader()`:

```dart
if (deviceType == DeviceType.ios) {
  accessToken = await sharedPreferencesService.getAccessToken();
} else {
  accessToken = await secureStorageService.getAccessToken();
}
```

`lib/core/services/local_storage/shared_preferences_service.dart` confirms the iOS path reads from plain `SharedPreferences`.

**Problem:** The same secret uses two different storage backends depending on platform, and the iOS path is unencrypted.

**Impact:** On iOS, the access token is readable from the app's plist-backed preferences file by anything with sandbox file access (a misbehaving SDK, a jailbroken device, a backup extraction tool).

**Fix:** Use `secureStorageService` (flutter_secure_storage → iOS Keychain) uniformly for the access token on both platforms.

**Confidence:** Confirmed

---

#### [High] [Architecture] The profile feature is fully built but never reachable from the running app

**Evidence:**

- `lib/injection_container.dart` `ServiceLocator.init()` calls `initThemeFeatureInjection()` but never `initProfileFeatureInjection()` (defined in `lib/features/profile/profile_injection.dart`).
- `lib/app.dart` `MultiBlocProvider.providers` spreads `...themeBlocs` but not `...profileBlocs`.

**Problem:** All 7 profile cubits/use cases/repositories are registered nowhere GetIt can find them from the app's actual entry point.

**Impact:** `context.read<GetStudentProfileCubit>()` (or any of the other 6) throws immediately if called today. The feature has likely never been exercised end-to-end in a running app.

**Fix:** Add `await initProfileFeatureInjection();` next to the theme call in `ServiceLocator.init()`, and spread `...profileBlocs` into `app.dart`'s `MultiBlocProvider` — the exact pattern theme already demonstrates.

**Confidence:** Confirmed

---

### P1 — fix this cycle

#### [High] [Reliability] Repository layer only catches AppException — malformed API payload crashes instead of producing an error state

**Evidence:**

- `lib/features/profile/data/repositories/profile_repo_impl.dart` — all 7 methods use `on AppException catch (error)` with no trailing catch-all.
- `lib/features/profile/data/models/get_student_profile_model.dart` `StudentModel.fromJson` accesses `json['id']`, `json['city_id']`, etc. with no guard if `json` itself is null.
- `generate/features/files/project_files/repository_impl/repository_impl_request_buffers.dart:47` shows the code generator emits the identical `on AppException catch` for every future feature.

**Problem:** If the API returns `data: null`, or JSON parsing throws a `TypeError`/`NoSuchMethodError` for any other reason, that exception is not an `AppException`, so it is not caught here and never reaches the `Either` boundary.

**Impact:** The cubit's `fold()` is never invoked; the UI is stuck in `LoadingState` indefinitely instead of showing a retry/error state. This will be copy-pasted into every feature the generator scaffolds until the template is fixed.

**Fix:** Add a trailing `on Object catch (error)` in the repository (and in `repository_impl_request_buffers.dart`'s generated template) that logs and returns a generic `Failure`, preserving the `Either` boundary.

**Confidence:** Confirmed

---

#### [High] [Flutter practice] AppTextFormField allocates a new, undisposed FocusNode on every build

**Evidence:** `lib/core/widgets/app_text_form_field.dart`, line 82:

```dart
FocusNode focusNode = this.focusNode ?? FocusNode();
```

inside `build()`. 5 of 6 named factories do not require callers to pass a `FocusNode`.

**Problem:** This is a `StatelessWidget`; nothing survives across rebuilds. Every rebuild allocates a fresh `FocusNode`, disconnected from whatever had focus before, and the previous one is never disposed.

**Impact:** Users can lose focus/keyboard mid-typing on any parent-state change (e.g., sibling `BlocBuilder` rebuild), and the discarded `FocusNode`s leak until GC.

**Fix:** Convert to a `StatefulWidget` owning `late final FocusNode _focusNode = widget.focusNode ?? FocusNode();` in `initState`, disposing it only if it was not supplied by the caller.

**Confidence:** Confirmed

---

#### [Medium] [Reliability] Network timeouts configured at 30 minutes

**Evidence:** `lib/core/api/dio_consumer.dart` — `sendTimeout` and `receiveTimeout` both `Duration(minutes: 30)`; `connectTimeout` `Duration(seconds: 120)`.

**Problem:** A stalled request on a degraded connection leaves the UI loading for up to 30 minutes before Dio raises a timeout.

**Impact:** No timely error state is possible for slow-network users within the existing `AppException`/`Failure` model.

**Fix:** Lower to conventional mobile values (10–30s connect, 15–30s receive/send) so the existing error-state pipeline can do its job.

**Confidence:** Confirmed

---

#### [Medium] [Security] Full request bodies — including password fields — are logged unconditionally

**Evidence:** `lib/core/api/dio_consumer.dart` — every verb method logs `body: ${body.toString()}` before sending (e.g., line 149 in `post()`), with no field redaction. Applies to `ChangeStudentPasswordParams`, `UpdateStudentProfileParams`, etc.

**Problem:** Credential and PII fields are serialized into the log stream verbatim, unconditionally.

**Impact:** If the logger's filter is ever reconfigured, or any log sink captures these lines (crash-reporter breadcrumbs, on-device log files), credentials leak.

**Fix:** Redact known-sensitive keys (`password`, `password_confirmation`, tokens) before logging, or drop `body` from the log line and log only endpoint + field count.

**Confidence:** Likely — the logging call itself is confirmed and unconditional; actual release-build exposure depends on `logger`'s default filter.

---

#### [Medium] [Testing] Zero automated coverage for `lib/` business logic

**Evidence:** `find test -name '*.dart'` → only `test/widget_test.dart`, whose entire body is `expect(true, isTrue)`. None of the 7 profile cubits, use cases, or the repository has a corresponding `*_test.dart`, despite `bloc_test` being a dev dependency and a cubit-test generator template existing at `generate/features/files/request_files/cubit_test/`.

**Problem:** The tooling and convention for testing cubits exist; no test has been produced for any real feature.

**Impact:** Regressions in state transitions, `Either` folding, or param serialization are only caught by manual QA.

**Fix:** Start with the two highest-risk untested seams: repository exception mapping and one cubit's loading/success/error transitions, using the project's own `bloc_test` generator template.

**Confidence:** Confirmed

---

### P2 / P3 — grouped

| Severity | Category | Finding | Confidence |
|---|---|---|---|
| Low | Code quality | `DateTimeExtension` (`lib/core/utils/extensions.dart`) duplicates zero-pad month/day logic three times. Extract a private `_pad(int)` helper. | Confirmed |
| Low | Reliability | `SharedPreferencesServiceImpl.getAccessToken()` returns `''` when absent; `SecureStorageServiceImpl.getAccessToken()` returns `null` for the same case. Inconsistent "no token" sentinel. | Confirmed |
| Low | Performance | `SecureStorageServiceImpl.getAccessToken()`/`getDeviceToken()` call `instance.readAll()` on every authenticated Android request. Currently only 2 keys stored, so low cost today. | Confirmed pattern |
| Info | Flutter practice | `SplashScreen` renders `const Placeholder()` with no auth check or navigation logic — expected for this stage. | Confirmed |
| Info | Scope | `generate/` and `.specify/` were out of requested scope; read only to confirm finding #4 propagates to future generated features (it does). | Confirmed |

---

## 5. Architecture Assessment

The codebase is small and early-stage: 109 files in `lib/`, two features with real domain/data/presentation layers (`profile`, `theme`), and a `splash` entry point that is currently a placeholder with no wiring to either. The one substantial pattern — `profile` — is well-designed and internally consistent: dependencies flow inward, the domain layer has no Flutter/Dio imports, and the repository/use-case/cubit split is followed without shortcuts.

The caveat is that this pattern is **unproven at scale and unproven at runtime**. It has been implemented exactly once, and that one implementation is not currently reachable from the app. Before treating `profile` as the template for the next five features, close the wiring gap and confirm the pattern survives contact with a real screen consuming `BlocConsumer<GetStudentProfileCubit, ...>`.

The more consequential risk to scalability isn't the architecture itself — it's that the **code generator reproduces the repository's exception-handling gap** by template. That means the "add a feature" workflow will multiply a reliability bug across every future feature until `repository_impl_request_buffers.dart` is fixed once, upstream.

---

## 6. Roadmap

| Phase | Priority | Work | Est. effort |
|---|---|---|---|
| 1 | P0 | TLS bypass, token storage asymmetry, wire profile into the app | 1–2 days |
| 2 | P1 | Fix repository catch-all in `profile_repo_impl.dart` **and** in the generator template | ~0.5 day |
| 3 | P1 | `FocusNode` lifecycle fix in `AppTextFormField`; lower Dio timeouts; redact logged request bodies | ~0.5 day |
| 4 | P1 | Add `bloc_test` coverage for profile cubits and repository error-mapping paths | 2–3 days |
| 5 | P2–P3 | Low-severity cleanup (extensions duplication, token sentinel consistency, secure-storage `readAll()`) | Opportunistic |

Nothing here calls for restructuring the architecture or replacing Bloc/Cubit — the pattern in place is sound; it needs to be finished, connected, and hardened.

---

## 7. Not Inspected

- **`generate/`** (code-gen CLI) — read only narrowly to confirm the repository exception-handling template. Its own code quality was not otherwise assessed.
- **`android/`, `ios/`** platform code — checked only for flavor/entry-point context; not part of the requested scope.
- **CI/CD** — no `.github/workflows` or equivalent found in the repo; cannot assess automated build/test/release gating.
- **`theme` feature** — traced at the same depth as `profile` for the Map stage, but not probed as one of the deep-dive features.
- Runtime behavior (actual TLS handshake, actual log output in a release build) was not executed — all findings above are static-evidence based, labeled with confidence accordingly.

---

## 8. Final Recommendation

**Yes, but major technical debt should be addressed first.**

The architectural foundation is sound and well-documented in project rules. The P0 security items (TLS bypass, token storage) and the profile wiring gap should be resolved before feature development accelerates. After that, the codebase is safe to build on incrementally.
