# Code review: `lib/core/api/`

**Date:** 2026-09-02  
**Scope:** `dio_consumer.dart`, `api_interceptors.dart`, `refresh_token_helper.dart`, `dio_exception_mapper.dart`, `dio_http_adapter.dart`, `api_constants.dart`, `status_code.dart`, plus `test/core/api/`  
**Mindset:** bugs, behavioral regressions, security, unhandled cases, missing tests. Quality notes follow findings.

---

## Summary

Token refresh, 401 retry, and interceptor → `AppException` unwrapping work for the paths that are tested (public 401, 500, one refresh + retry, concurrent 401 coalescing, failed refresh clears storage).

The main risks are **wrong user-facing errors** (unknown Dio failures mapped as “no internet”), **retry using the same Dio instance** (easy to get interceptor re-entry / stale headers if `onRequest` is skipped), **debug TLS trust still on for any debug build**, and **large untested surface** (`DioConsumerImpl` verbs, refresh payload edge cases, 403/422/cancel).

---



## Findings (by severity)



### High


| ID  | Location                                                           | Finding                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| --- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| H1  | `dio_exception_mapper.dart:17–24`                                  | `DioExceptionType.unknown` **is mapped to** `InternetConnectionException`**.** `unknown` is Dio’s catch-all (parse errors, unexpected throws, some adapter failures). The UI will show “no internet” for failures that are not offline. Connection timeouts / `connectionError` belong here; `unknown` does not.                                                                                                                                                                                                                |
| H2  | `api_interceptors.dart:91–95` + `api_interceptors.dart:60`         | **Retry uses** `GetIt`**’s** `Dio`**, which is the same client that already has** `ApiInterceptor`**.** `fetch(retriedOptions)` re-enters interceptors. That is how the new Bearer token gets applied (`onRequest`). If retry is ever pointed at a Dio **without** this interceptor, the retried request keeps the **old** `Authorization` header (`retriedOptions` only copies `extra`). If interceptors are duplicated on that Dio (`DioConsumerImpl` always `interceptors.add`), refresh/retry can run twice.                |
| H3  | `refresh_token_helper.dart:88–110` + `api_interceptors.dart:80–88` | **Refresh failure typing is inconsistent.** `_performRefresh` throws `UnauthorizedException` (not `DioException`) when the stored token is empty or the body has no access token. The interceptor’s `on DioException` branch does not run; the generic `catch (_)` clears tokens and rejects the **original** 401. That is acceptable for logout, but a 200 refresh body with `{status: error}` and no token looks the same as a dead session — no distinct handling, and the original “expired” message is what the user sees. |




### Medium


| ID  | Location                                                                    | Finding                                                                                                                                                                                                                                                                                                                                                                           |
| --- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M1  | `dio_http_adapter.dart:11–14` + `:22–26`                                    | **Debug builds disable TLS authentication** (`badCertificateCallback => true`). Gating with `kDebugMode` is correct for store/release, but **profile is production-like** (certs validated) while **any debug APK/IPA** still accepts MITM. Debug logging (`PrettyDioLogger` with `requestHeader: true` in `dio_consumer.dart:67–74`) also prints `Authorization` to the console. |
| M2  | `dio_exception_mapper.dart:26`                                              | `cancel` **is mapped to** `ServerException`**.** User-initiated cancel (route pop, `CancelToken`) is not a server failure. Callers cannot distinguish abort from 500.                                                                                                                                                                                                             |
| M3  | `dio_exception_mapper.dart:30–43`                                           | **Status handling is incomplete vs** `StatusCode`**.** Only 401 and 301 are special-cased. `403`, `422`, `429`, `409` all become generic `ServerException`. `extractErrorMessage` does not unwrap validation maps (`errors: {email: [...]}`), so 422 UIs get a blunt `message` or `map.toString()`.                                                                               |
| M4  | `dio_consumer.dart:145–154`                                                 | `delete` **ignores** `formData` **and** `body` even though the sealed API advertises them. `get` on the impl accepts unused `formData`. Callers can pass a body that is silently dropped.                                                                                                                                                                                         |
| M5  | `dio_consumer.dart:57–65` + POST/PUT/PATCH                                  | **Global** `contentType: application/json`**.** Multipart `FormData` often still works because Dio sets a boundary, but this is a known footgun if a caller sends `FormData` and the server sees JSON content-type.                                                                                                                                                               |
| M6  | `refresh_token_helper.dart:117–119`                                         | `isRefreshPath` **uses** `contains`**.** Any path that *includes* `/common/refresh-token` as a substring skips refresh. Prefer exact match or `endsWith` only.                                                                                                                                                                                                                    |
| M7  | `refresh_token_helper.dart:160–178`                                         | `parseAccessToken` **accepts any non-null value via** `toString()`**.** A numeric or map `token` field would be persisted as a garbage string, then sent as `Bearer ...` until the next 401.                                                                                                                                                                                      |
| M8  | `api_constants.dart:2–4`                                                    | `staging` **is unused;** `baseUrl` **is hard-coded to** `live`**.** There is no debug/staging switch analogous to the TLS adapter. Debug builds still hit production unless someone changes this by hand.                                                                                                                                                                         |
| M9  | `dio_consumer.dart:15`                                                      | `sealed class DioConsumer` **lives in the app library.** Fakes in `test/` cannot `implements DioConsumer` (sealed). Tests go through `DioConsumerImpl` + scripted adapters, which is heavier and does not unit-test the consumer in isolation.                                                                                                                                    |
| M10 | `api_interceptors.dart` / `refresh_token_helper.dart` / `dio_consumer.dart` | `dart:io` **(**`HttpHeaders`**,** `SocketException`**,** `HttpClient`**).** This layer cannot compile for web. Fine if the app is mobile-only; it is an unhandled platform case.                                                                                                                                                                                                  |




### Low


| ID  | Location                                                                  | Finding                                                                                                                                                                                                          |
| --- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| L1  | `dio_consumer.dart:63–65`                                                 | Timeouts are extreme (`send` 120s, `receive` 360s) vs refresh client (30s). Hung calls occupy the isolate and the refresh lock is unrelated, but UX can spin for minutes.                                        |
| L2  | `dio_consumer.dart:66`                                                    | Constructor **always appends** an interceptor. Safe with GetIt lazy-singleton; unsafe if `DioConsumerImpl` is constructed more than once on the same `Dio`.                                                      |
| L3  | `test/core/api/api_interceptor_test.dart` vs `api_interceptors_test.dart` | **Duplicate test files** (same cases, different formatting). CI pays twice; edits will drift.                                                                                                                    |
| L4  | `status_code.dart`                                                        | Many constants are unused by the mapper. Harmless, but implies 4xx/5xx policy was never finished.                                                                                                                |
| L5  | `ApiInterceptor` / `RefreshTokenHelper` singletons                        | Production never calls `init()`. That is OK (GetIt / `Language.instance` fallbacks), but a request before `ServiceLocator.init()` / `Language.init()` throws from GetIt or reads an uninitialized language code. |
| L6  | `extractErrorMessage`                                                     | Non-map data uses `toString()`; map without `message` uses the whole map `toString()`. Snackbars can show `{status: error, data: ...}`.                                                                          |


---



## Case handling matrix


| Case                                       | Handled?    | Where                         | Notes                                                                                         |
| ------------------------------------------ | ----------- | ----------------------------- | --------------------------------------------------------------------------------------------- |
| 2xx success, return `response.data`        | Yes         | `DioConsumerImpl._send`       | Includes `204` → `null` data; callers must tolerate null.                                     |
| GET/POST/PUT/PATCH with JSON body          | Yes         | `DioConsumerImpl`             | GET-with-body is unusual but forwarded.                                                       |
| POST/PUT/PATCH `FormData`                  | Partial     | `formData ?? body`            | JSON content-type still set on the client.                                                    |
| DELETE with body / FormData                | **No**      | `delete`                      | Parameters ignored.                                                                           |
| 401 public (no `Authorization`)            | Yes         | `shouldRefresh` + mapper      | Covered by tests.                                                                             |
| 401 with token, refresh succeeds, retry    | Yes         | interceptor + helper          | Covered; retry depends on `onRequest` rewriting the header.                                   |
| Concurrent 401s, one refresh               | Yes         | `Completer` lock              | Covered.                                                                                      |
| Already retried (`retriedRequestExtraKey`) | Yes         | `shouldRefresh`               | Covered.                                                                                      |
| 401 on refresh path                        | Yes         | `isRefreshPath`               | Covered; `contains` is broader than needed.                                                   |
| Refresh HTTP 401                           | Yes         | interceptor `on DioException` | Clears token; user sees original 401 mapping.                                                 |
| Refresh HTTP 200, no token in body         | Partial     | `_performRefresh`             | Throws `UnauthorizedException`; interceptor generic catch; original 401 message. **No test.** |
| Refresh network timeout                    | Yes         | `_mapFailedRefresh`           | Does **not** clear tokens (good). **No dedicated test.**                                      |
| Empty / missing stored token + 401         | Yes         | `shouldRefresh` / `_hasValue` | No refresh. **No unit test** for empty string token.                                          |
| 403 / 422 / 429 / 409                      | Weak        | mapper                        | All `ServerException`. No field-level 422 parse.                                              |
| 301                                        | Yes         | mapper `preferDataField`      | Tested.                                                                                       |
| Cancelled request                          | Weak        | mapper                        | Treated as server error.                                                                      |
| TLS bad certificate (release)              | Yes         | default Dio adapter           | Trust-all only in `kDebugMode`.                                                               |
| TLS bad certificate (debug)                | Intentional | `dio_http_adapter.dart`       | MITM possible.                                                                                |
| SocketException bypassing Dio              | Partial     | `_send`                       | Mapped to offline. Rare if Dio wraps it first.                                                |
| Interceptor `onRequest` throws             | Yes         | reject `DioException`         | Then `_send` may wrap as `ServerException` if `error` is not `AppException`.                  |
| Language / token header attach             | Yes         | `_attachHeaders`              | Tested.                                                                                       |
| Staging vs live base URL                   | **No**      | `ApiConstants.baseUrl`        | Always live.                                                                                  |


---



## Test coverage

**Present (useful):**

- Mapper: timeouts → offline, 401 message, 301 `data`, other status → `ServerException`, `extractErrorMessage` null/string/map.
- Helper: parse camelCase/snake_case/missing token, `shouldRefresh` for 500 / already-retried / refresh path / happy 401.
- Interceptor + consumer: headers, public 401, 500, refresh+retry, concurrent 401, failed refresh clears storage.

**Missing (highest value first):**

1. Refresh **200** body without `access_token` / `accessToken` / `token`.
2. Refresh **timeout / connectionError** does not clear storage; user can retry.
3. `shouldRefresh` with **no Authorization header** and with **empty stored token**.
4. Retry **after** refresh still 401 (`retriedRequestExtraKey`) — no second refresh, token left as the new value.
5. `DioConsumerImpl.delete` does not send body (or document and drop the params).
6. Mapper: `unknown` should **not** be offline; `cancel` should **not** be `ServerException` (once behavior is defined).
7. `DioConsumerImpl` constructed twice on one `Dio` — interceptor duplication (or assert interceptors are not re-added).
8. Drop duplicate `api_interceptor_test.dart` / `api_interceptors_test.dart`.

There are **no** tests for `applyHttpAdapter`, `ApiConstants.baseUrl`, or `StatusCode` usage beyond 401/301/500/429.

---



## What is in good shape

- Refresh lock + `whenComplete` clearing `_refreshLock` is the right concurrency pattern.
- Failed refresh vs offline refresh is distinguished (`InternetConnectionException` does not log the user out).
- Interceptor unwraps `AppException` already on `DioException.error`, so `_send` can rethrow typed errors.
- Release TLS validation is the Dio default (only debug opts out).
- `PrettyDioLogger` is debug-only.

---



## Recommended order of work

1. Stop mapping `DioExceptionType.unknown` (and probably `cancel`) to offline/server catch-alls — define real types or fall back to `ServerException` / ignore cancel.
2. Make retry token-safe without depending on interceptor re-entry: set `Authorization` from `tokenStorage` inside `retriedOptions` (or a dedicated retry Dio that still runs `onRequest` once).
3. Align `ApiConstants.baseUrl` with the same debug/production split as the HTTP adapter (or flavor/env).
4. Add the missing refresh/retry tests listed above; delete the duplicate interceptor test file.
5. Either send DELETE bodies or remove those parameters from `DioConsumer`.
6. Narrow `parseAccessToken` to non-empty `String` values only.

---

*Review only — no code was changed.*