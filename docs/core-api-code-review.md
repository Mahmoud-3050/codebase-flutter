# Code review: `lib/core/api/`

**Date:** 2026-09-05 (re-review after H1 / H2)  
**Previous review:** 2026-09-02, overall **71 / 100**  
**Scope:** `dio_consumer.dart`, `api_interceptors.dart`, `refresh_token_helper.dart`, `dio_exception_mapper.dart`, `dio_http_adapter.dart`, `api_constants.dart`, `status_code.dart`, plus `test/core/api/` and the exception/failure mapping they feed.  
**Mindset:** bugs, behavioral regressions, security, unhandled cases, missing tests. Quality notes follow findings.  
**Review only — no code was changed in this pass.**

---

## Summary

The HTTP layer is a solid Dio wrapper: flavor-aware base URLs, typed status mapping, a refresh lock, retry that stamps the new Bearer token, multipart `Content-Type`, and a unit-test suite that now covers the session-failure paths that previously logged users out.

**H1 and H2 are fixed.** Transient refresh failures (5xx / 429 / cancel / timeout / unexpected) keep the access token. Public auth paths omit `Authorization` and do not trigger refresh. No High findings remain.

The leftover risk is **session product policy**, not basic HTTP: 422 `fieldErrors` never reach `Failure`, token clear is not a full logout, retry-still-401 can refresh again on the next tap, and the refresh client still uses a 360s receive timeout.

---

## Score

**Overall: 81 / 100 (B / Strong)**  
**Previous:** 71 / 100 (B−) → **+10** from H1 + H2 + their tests.

Safe to ship for authenticated profile traffic and for adding login/register on these paths. Follow-ups are Medium (forms, logout orchestration, timeouts, debug TLS/logs).

| Category | Weight | Score | Prev | Grade | Why this number |
| --- | ---: | ---: | ---: | --- | --- |
| Correctness / reliability | 30% | **82** | 64 | B | Happy-path refresh and the two former High bugs are tested. Remaining: retry-still-401 (M2), ignored `save == false` (M9), `transformTimeout` as offline (M10). |
| Security | 20% | **80** | 72 | B | Public auth no longer gets a leftover Bearer. Production TLS is correct. Deductions: debug body logs (M5), debug+dev trust-all (M6), authenticated redirects still forward `Authorization` (M7). |
| Test coverage | 20% | **84** | 78 | B | Refresh 500/429/cancel/403, login without Bearer, login 401 without refresh, and `isPublicAuthPath` are covered. Gaps: `save == false`, follow-up request after retry-401, 422 through `toFailure()`, redirect headers. |
| Code quality / architecture | 15% | **78** | 76 | B | `_isUnrecoverableRefreshFailure` and `ApiConstants.matchesPath` / `isPublicAuthPath` make the policy explicit. Still: GetIt inside singletons, magic timeouts, exceptions not sealed. |
| Case handling completeness | 15% | **76** | 67 | B− | Refresh 5xx and public-auth 401 are correct. Still open: CancelToken, 422 field errors on `Failure`, session notify on logout, persist-fail after refresh. |

**Weighted total:** `82×0.30 + 80×0.20 + 84×0.20 + 78×0.15 + 76×0.15` = **80.50 → 81**

### Scale

| Range | Meaning |
| ---: | --- |
| 90–100 | Production-hardened; remaining items are polish |
| **80–89** | **Strong; minor gaps, safe to ship with follow-ups (this review)** |
| 70–79 | Good structure; important edge cases remain |
| 60–69 | Acceptable skeleton; several user-facing bugs |
| &lt; 60 | Rework before relying on it |

### Finding load

| Severity | Count | vs previous |
| --- | ---: | --- |
| High | **0** | was 2 (H1, H2 resolved) |
| Medium | 12 | unchanged IDs; M7 slightly narrower |
| Low | 8 | unchanged |

### After remaining fixes

| If you land… | Expected overall |
| --- | ---: |
| M1 + M2/M3 | **~85** (B) |
| Full remaining recommended order | **~88** (B+) |

Distance to 90+ is still pinning, CancelToken, redacted logs, and a real logout callback — not more Dio wrappers.

---

## Resolved since 2026-09-02

| ID | Fix |
| --- | --- |
| **H1** | `_mapFailedRefresh` / `_isUnrecoverableRefreshFailure`: logout only on refresh **401/403**. 200 with no token still clears via `UnauthorizedException`. 5xx, 429, cancel, timeout, and unexpected errors keep tokens. Tests in `api_interceptors_test.dart`. |
| **H2** | `_attachHeaders` strips Bearer on `ApiConstants.publicAuthPaths`. `shouldRefresh` returns false for those paths even if a leftover header exists. Tests for login omit-header and login 401 without refresh. |

---

## Findings (by severity)

### High

*None.*

### Medium

| ID | Location | Finding |
| --- | --- | --- |
| **M1** | `exceptions.dart` `ValidationException.toFailure()` (124–128) | **Field-level 422 errors are dropped at the domain boundary.** The mapper builds `fieldErrors`, but `toFailure()` returns `ServerFailure` with only `message`. Repositories only expose `Failure`. Forms cannot bind per-field errors. `ForbiddenException` / `ConflictException` / `TooManyRequestsException` collapse to `ServerFailure` (recoverable via `statusCode`; `fieldErrors` are not). |
| **M2** | interceptor retry-still-401; asserted in tests | **Refresh success + retry 401 does not clear the session.** The new token is kept. The next user action is a new request (no `retriedRequestExtraKey`), so `shouldRefresh` is true again. If the resource keeps returning 401 while refresh still returns a token, each tap hits `/common/refresh-token` again. |
| **M3** | `clearAuthTokens()` only | **Clearing the access token is not a logout.** `UserType`, in-memory profile, and navigation are untouched. After a true session kill (refresh 401/403 / empty token body) the user can remain on authenticated screens until the next call fails. No callback / event from this layer. |
| **M4** | `dio_consumer.dart` 61–63; `refresh_token_helper.dart` 164–166 | **`receiveTimeout` is 360s** on both the main client **and** the refresh client. A hung refresh holds `_refreshLock`; concurrent 401s wait the same interval. Send timeout is 120s. Unnamed magic numbers (§1.3). |
| **M5** | `dio_consumer.dart` 83–88 | **Debug `PrettyDioLogger` logs request bodies.** Headers are not logged by default, but login/reset bodies still include passwords in the debug console. `kDebugMode` only. |
| **M6** | `dio_http_adapter.dart` 13–28 | **Debug + `AppFlavor.dev` disables TLS authentication.** Live debug, profile, and release validate certificates. Debug **dev** APK/IPA still accepts MITM. Staging is a real host; if its cert is valid, the bypass is unnecessary. |
| **M7** | Dio `BaseOptions` defaults | **Redirects are followed with the original headers.** Authenticated calls can forward `Authorization` to another host on 301/302. Public auth paths no longer attach a token (H2), so this no longer applies to login/register. |
| **M8** | `DioConsumer` methods | **No `CancelToken` on the public API.** `RequestCancelledException` is mapped, but callers cannot abort on dispose. Worst case: wait up to 360s after leaving the screen. |
| **M9** | `refresh_token_helper.dart` `_performRefresh` save | **`tokenStorage.save` returning `false` is ignored.** Refresh looks successful; `retriedOptions` reads the old token; retry 401s with the retry flag and stops. Disk and in-memory session can diverge. |
| **M10** | `dio_exception_mapper.dart` 32–38 | **`transformTimeout` is treated as offline.** UI copy will say “no internet” after a parse/transform stall. |
| **M11** | `api_interceptors.dart` 92–101 | **Non-`DioException` failures during retry reject the original 401**, not the retry error. Production `AccessTokenStorage.read` swallows errors, so this is mostly a test-double / future-impl concern. |
| **M12** | `extractErrorMessage` | **Non-JSON string bodies become the user-facing message.** An HTML 502 page can surface in a snackbar. Maps without `message` / `errors` yield `null` (good). |

### Low

| ID | Location | Finding |
| --- | --- | --- |
| **L1** | `AppException.toString()` | `'$message'` becomes the literal `"null"` when `message` is null. Cubits using `failure.message ?? fallback` are fine. |
| **L2** | `get(..., body:)` | GET still accepts a JSON `body`. Unusual; datasources do not need it. |
| **L3** | `dart:io` | Cannot compile for web. App is android/ios today — accepted constraint. |
| **L4** | `status_code.dart` vs mapper | `400` / `404` / `408` unused; they correctly become `ServerException`. |
| **L5** | Interceptor / helper / mapper `init()` | Production never calls `init()`. Fallbacks work after `ServiceLocator.init()` + `Language.init()`. Latent if HTTP runs earlier. |
| **L6** | `_addInterceptorOnce` | `contains` is identity. Safe for the singleton interceptor. |
| **L7** | GetIt `Dio` | Unconfigured until `DioConsumerImpl` mutates it. Retry uses that same instance. Works because the consumer is the first resolver. |
| **L8** | `AppException` / `Failure` | Not `sealed`; cubits cannot exhaustively switch (§4.2). |

---

## Case handling matrix

| Case | Handled? | Where | Notes |
| --- | --- | --- | --- |
| 2xx success, return `response.data` | Yes | `DioConsumerImpl._send` | `204` → `null`. Datasources that do `response['status']` will throw. |
| GET/POST/PUT/PATCH/DELETE JSON | Yes | `DioConsumerImpl` | DELETE body forwarded. GET-with-body forwarded (L2). |
| POST/PUT/PATCH/DELETE `FormData` | Yes | `_optionsFor` | Multipart content-type override. `formData` wins over `body`. |
| 401 public (no `Authorization`) | Yes | `shouldRefresh` | Covered. |
| 401 with token, refresh 200 + token, retry | Yes | interceptor + helper | Covered. |
| Concurrent 401s, one refresh | Yes | `Completer` lock | Covered. |
| Already retried | Yes | `retriedRequestExtraKey` | Covered; does **not** logout (M2). |
| 401 on refresh path | Yes | `isRefreshPath` | Covered. |
| Refresh HTTP 401 / 403 | Yes | `_mapFailedRefresh` | Clears token; user sees original 401. Covered (401 + 403). |
| Refresh HTTP 200, no access token | Yes | `UnauthorizedException` | Clears token; user sees refresh `message`. Covered. |
| Refresh timeout / connectionError | Yes | `_mapFailedRefresh` | Keeps tokens. Covered. |
| Refresh HTTP 5xx / 429 / cancel | Yes | `_isUnrecoverableRefreshFailure` | **Keeps tokens.** Covered. |
| Unexpected error during refresh | Yes | generic `catch` | Keeps tokens; original 401. Covered. |
| Empty / missing stored token + 401 | Yes | `shouldRefresh` | Covered. |
| 401 on `/auth/login` with leftover token | Yes | public auth paths | No Bearer, no refresh, token kept. Covered. |
| 403 / 409 / 422 / 429 on normal APIs | Partial | mapper | Distinct exceptions. 422 `fieldErrors` lost in `toFailure()` (M1). |
| 400 / 404 / 5xx | Weak | mapper default | `ServerException` + `statusCode`. |
| 301 | Yes | `preferDataField` | Covered. |
| Cancelled request | Mapped | mapper | Callers cannot trigger cancel (M8). |
| TLS (release / live debug) | Yes | default adapter | Trust-all only debug+dev. |
| TLS (debug + dev) | Intentional | adapter | MITM possible (M6). |
| Token persist failure after refresh | **No** | `_performRefresh` | `save == false` ignored (M9). |
| Web / `dart:io` | N/A | L3 | Mobile-only. |

---

## Security

| Topic | Assessment |
| --- | --- |
| Access token storage | `FlutterSecureStorage`. Read fails closed (no header). Write fail after refresh is fail-open (M9). |
| Refresh model | Same access token is sent to `/common/refresh-token`. No separate refresh credential. Matches current API shape. |
| Token on public auth routes | **Fixed (H2).** Other authenticated routes still send Bearer (correct). |
| TLS | Production / live-debug validate. Debug+dev trust-all (M6). No pinning. |
| Debug logs | Request bodies in debug (M5). Headers not logged by default. |
| Redirects | Authenticated `Authorization` can follow 301/302 (M7). |
| Logout completeness | Token delete only (M3). No revoke call, no navigation. |

---

## Test coverage

**Present (useful):**

- Mapper: connection-class → offline; `unknown` / `badCertificate` → `ServerException`; cancel; 401/403/409/422/429/301/500; `extractErrorMessage` / `extractFieldErrors`.
- Helper: token parse (string-only); `shouldRefresh` for 500, already-retried, refresh path, **public auth paths**, missing header, empty token, happy 401; `retriedOptions`; persist; 200-without-token; coalescing; lazy client base URL.
- Interceptor + consumer: headers on/off; **public auth omits Bearer**; public 401; 500; refresh + retry; concurrent 401; refresh 401 clears; 200 without token; timeout / **500 / 429 / cancel keep token**; **refresh 403 clears**; **login 401 does not refresh**; retry-still-401; unexpected refresh keeps token; FormData; DELETE body; 204; flavor `baseUrl`; interceptor-once.
- Constants: flavor URLs, auth paths, **`isPublicAuthPath` / `matchesPath`**, `StatusCode` values.

**Missing (highest value first):**

1. Retry-still-401 policy: logout vs keep; a **follow-up** request must not hammer refresh if you choose logout (M2).
2. `tokenStorage.save` → `false` after a successful refresh body (M9).
3. `ValidationException.toFailure()` preserves `fieldErrors` (M1) — once `ValidationFailure` exists.
4. Interceptor path for 403/422/429 on **normal** APIs (mapper-only today).
5. `applyHttpAdapter` actually sets `badCertificateCallback` (test only checks `createHttpClient != null`).
6. Redirect: `Authorization` not forwarded to another host (M7).
7. `transformTimeout` / HTML string body messaging (M10, M12).
8. `DioConsumer` cancel — not testable until `CancelToken` is on the interface (M8).

---

## Code quality (structure / SOLID)

| Rule | Observation |
| --- | --- |
| §1.1 / §3.1 | `_isUnrecoverableRefreshFailure` is the logout policy. `onError` still orchestrates refresh + retry + mapping; that is acceptable now that the keep-vs-clear branch is named. |
| §1.3 | Timeouts (30 / 120 / 360) and `'Bearer '` remain raw literals. |
| §1.5 | Path matching is shared via `ApiConstants.matchesPath`. Bearer attach is still duplicated in `_attachHeaders`, `retriedOptions`, and refresh `Options` (intentional for retry safety). |
| §2.3 / §3.5 | Retry client and token storage still default to GetIt concrete types. Tests inject via `init()`. |
| §4.2 | `AppException` / `Failure` are not sealed. |
| §5.1 | `AppException.toString()` should not print `"null"` (L1). |

**What is in good shape**

- Refresh lock + `identical(_refreshLock, completer)` + `whenComplete`.
- Logout only on unrecoverable refresh auth failures; connectivity and 5xx keep the session.
- Public auth paths never send or refresh a leftover token.
- `retriedOptions` sets `Authorization` from storage.
- `parseAccessToken` accepts only non-empty strings.
- Interceptor unwraps `AppException` on `DioException.error`.
- Flavor `baseUrl`; debug-only logger; TLS bypass not applied to live/profile/release.

---

## Recommended order of work

1. **M1** — Add `ValidationFailure` (with `fieldErrors`) and map `ValidationException` to it.
2. **M3 / M2** — After a true session kill, notify the app (user-type + navigation). Decide whether retry-still-401 is a session kill.
3. **M4** — Lower refresh `receiveTimeout` (e.g. 30s) independently of large uploads; name the constants.
4. **M5 / M6 / M7** — Redact auth bodies in the logger; keep TLS bypass behind an explicit local flag; do not follow cross-origin redirects with `Authorization`.
5. **M8 / M9** — Plumb `CancelToken`; treat failed `save` after refresh as refresh failure.

---

*Files reviewed: `lib/core/api/*`, `lib/core/error/exceptions.dart`, `lib/core/error/failures.dart`, `test/core/api/*`, `lib/injection_container.dart` (Dio wiring only).*
