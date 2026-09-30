# Test Requirements Quality Checklist: Authentication (Login, Register, Guest Mode)

**Purpose**: Validate that the requirements are written well enough to derive a >90% coverage test
suite across three levels — unit (a single function, method, or class in isolation), widget (isolated
widget rendering, layout, and UI interaction), and integration (complete end-to-end user flows on a
real device or emulator) — before breaking the work into tasks.

**Created**: 2026-09-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)

**Depth**: Standard — surface gaps to fix now; judgment calls permitted.
**Scope**: `lib/features/auth/` only. Shared and core surfaces this feature touches
(`ApiConstants.publicAuthPaths`, `RefreshTokenHelper`, `AppOtpField`, `RegistrationDraftStorage`,
splash routing, the blank home screen) are treated as already-covered infrastructure and are out of
scope for this checklist.
**Target artifact for fixes**: coverage targets and the three-level split belong in a new
**Testing Strategy** section of `plan.md`.

**Reminder**: every item below tests whether the *requirements are written correctly*, not whether the
code works. Items ask "is this specified?", never "does this behave?".

## Coverage Target Definition & Measurability

- [x] CHK001 Is a numeric coverage target stated anywhere in the artifacts? Neither `spec.md` nor `plan.md` currently names one. [Gap]
- [x] CHK002 Is the coverage *metric* defined (line, branch, or statement), so ">90%" has one unambiguous reading? [Ambiguity, Gap]
- [x] CHK003 Is the coverage *denominator* defined — specifically whether generated files (`router.g.dart`, `mocks.mocks.dart`) are excluded? Without this the same suite can report wildly different percentages. [Gap, Plan §Source Code]
- [x] CHK004 Are code paths that are untestable in a headless suite (provider SDK implementations, platform-channel calls) explicitly excluded from the target, or is 90% being asserted over code that cannot reach it? [Gap]
- [x] CHK005 Are per-level coverage expectations distinguished, or does one global 90% figure cover unit, widget, and integration together? [Clarity, Gap]
- [x] CHK006 Is it specified how the target is enforced — a local command, a CI gate, or reviewer judgment? [Gap]
- [x] CHK007 Is a requirements-to-test traceability obligation stated, so each FR maps to at least one named test? Line coverage alone cannot demonstrate that FR-041a or FR-046d are covered at all. [Traceability, Gap]

## Unit-Level Requirement Completeness

- [x] CHK008 Does the constitution's testing gate cover every unit this feature adds? It names use cases, repository implementations, and cubits — but not `*Params.toJson()` mappings, models' `fromJson`, or the sealed outcome parsing. [Completeness, Gap]
- [x] CHK009 Are the wire-name mappings for every `*Params.toJson()` specified precisely enough to assert field-by-field? [Completeness, Contracts §auth-api]
- [x] CHK010 Is the null-omission rule for `toJson()` stated as a requirement rather than only implied by the profile precedent? [Clarity, Contracts §auth-repository]
- [x] CHK011 Are the expected exception-to-failure mappings enumerated for each auth endpoint, so repository tests can assert the specific `Failure` type rather than merely `isLeft`? [Completeness, Contracts §auth-api]
- [x] CHK012 Is the expected cubit emission sequence specified for each operation, including whether a cancelled request emits nothing after loading? [Completeness, Plan §Constitution Check]
- [x] CHK013 Are both branches of every sealed outcome (`AuthOutcome`, `LoginOutcome`) given a specified expected result, so no branch can be left unasserted? [Coverage, Data-model §AuthOutcome]
- [x] CHK014 Are the local-only operations (`resolveVisitorState`, `continueAsGuest`, `readRegistrationDraft`) given specified expected behavior for the missing-value and unreadable-value cases? [Coverage, Data-model §Visitor state]

## Widget-Level Requirement Completeness

- [x] CHK015 Is a widget-test obligation stated at all? The constitution's testing gate lists only unit and bloc tests, so the widget level the request asks for is currently unrequired. [Gap]
- [x] CHK016 Is it specified which `ApiCallState` variants each auth screen must render? Without this, a widget test cannot know whether an `ApiCallEmpty` or `ApiCallRefresh` branch is expected or dead. [Completeness, Gap]
- [x] CHK017 Are per-field error display requirements specified for each form, so a widget test can assert the error lands on the right field rather than merely appearing? [Clarity, Spec §FR-007]
- [x] CHK018 Are the exact user-facing messages, or their string keys, specified for each failure named in SC-007? FR-049 requires an "actionable message" without saying which, so a widget test can only assert that *some* message rendered. [Clarity, Spec §FR-049, §SC-007]
- [x] CHK019 Is the observable effect of duplicate-submission prevention specified (one request emitted, control disabled, or both)? [Clarity, Spec §FR-048]
- [x] CHK020 Are the fields the social and phone-first completion forms must show as fixed and non-editable specified per source, so a widget test can assert the correct field is locked? [Completeness, Spec §FR-023, §FR-032]
- [x] CHK021 Is a requirement stated that auth screens be verified in both supported languages and both reading directions? SC-008 asserts the outcome but never assigns it to a test level. [Coverage, Spec §SC-008, §FR-050]
- [x] CHK022 Are accessibility requirements defined for the auth forms? None appear in the spec, so there is no a11y assertion a widget test could make. [Gap]

## Integration-Level Requirement Completeness

- [x] CHK023 Is an integration-test obligation stated, and is the harness identified? `pubspec.yaml` currently has no `integration_test` dependency, and `quickstart.md` documents only `flutter test`. [Gap, Quickstart §Tests]
- [x] CHK024 Is it specified which flows require end-to-end coverage — all six user stories plus password recovery, or a named subset? [Coverage, Gap]
- [x] CHK025 Does SC-013's "demonstrated independently" specify whether demonstration is automated or manual? As written it does not distinguish the two. [Ambiguity, Spec §SC-013]
- [x] CHK026 Are the measurement conditions for the timing criteria specified — device class, network profile, and cold versus warm start? Without them SC-001's 3 minutes, SC-002's 15 seconds, and SC-003's 5 seconds cannot become deterministic assertions. [Measurability, Spec §SC-001, §SC-002, §SC-003]
- [x] CHK027 Are the field metrics that no client test can observe (SC-004 code delivery rate, SC-005 first-attempt completion rate) marked as out of scope for the automated suite? Leaving them unmarked implies untestable obligations. [Clarity, Spec §SC-004, §SC-005]
- [x] CHK028 Is the interaction-count limit in SC-002 defined precisely enough to count — does focusing a field, or dismissing the keyboard, count as an interaction? [Measurability, Spec §SC-002]
- [x] CHK029 Is a requirement stated for asserting FR-045 and SC-010 during auth flows, so "no password or code in logs" is actually verified rather than assumed from the omit-log-body configuration? [Coverage, Spec §FR-045, §SC-010]

## Requirement Clarity & Quantification

- [x] CHK030 Is the wrong-attempt cap quantified? The spec says "a small number of wrong attempts", which no test can assert. [Ambiguity, Spec §Assumptions]
- [x] CHK031 Is the registration-draft token lifetime specified? `contracts/auth-api.md` calls it "short-lived", so the expired-token path in FR-026 and FR-036 has no assertable boundary. [Gap, Contracts §auth-api]
- [x] CHK032 Is the session lifetime quantified? SC-006 asserts persistence "for the full session lifetime" while the plan defers the duration to the backend, leaving nothing to assert. [Measurability, Spec §SC-006]
- [x] CHK033 Is the guest-gate trigger specified as a requirement? FR-039 requires the prompt, but with a deliberately blank home screen no concrete account-required action is defined for a test to exercise. [Gap, Spec §FR-039]
- [x] CHK034 Is the sign-out entry point specified? FR-043 requires sign-out to exist without stating where it is reachable from, so no widget or integration test has a target. [Gap, Spec §FR-043]
- [x] CHK035 Is the observable behavior of FR-051 defined? "MUST NOT lose an in-progress registration form" when backgrounded names no mechanism and no observable, so a test cannot distinguish pass from fail. [Clarity, Spec §FR-051]

## Requirement Consistency & Conflicts

- [x] CHK036 Do the one-time-code timing values agree between artifacts? The spec assumes a fixed 10-minute expiry and 60-second cooldown, while `contracts/auth-api.md` has the server return `expires_in_seconds` and `resend_available_in_seconds`. A test written against the fixed values contradicts one written against the server's. [Conflict, Spec §Assumptions, Contracts §auth-api]
- [x] CHK037 Do the spec and plan agree on cancelled social authorization? FR-035 treats "cancelled or fails" as one case, while the plan and research distinguish silent cancellation from a surfaced error. Which behavior is the assertion? [Conflict, Spec §FR-035, Plan §Constitution Check]
- [x] CHK038 Is the second-authorization Apple case covered by a requirement? Research notes that Apple returns the email and name only on the first authorization, but no FR states the expected behavior on subsequent ones. [Gap, Research §R1, Spec §FR-034]
- [x] CHK039 Are FR-041a's verification side effects specified observably enough to assert — that a previously unverified phone becomes verified after a phone-code sign-in? [Measurability, Spec §FR-041a]

## Test Seams, Determinism & Assumptions

- [x] CHK040 Is it stated as a requirement that no test may reach the real network or a real provider SDK, and that all three data-source interfaces are the substitution seams? [Assumption, Contracts §auth-repository]
- [x] CHK041 Is an injectable time source required for the resend countdown? `OtpCooldownCubit` owns a real `Timer`, which makes deterministic unit testing of the countdown impossible as designed. [Gap, Plan §Complexity Tracking]
- [x] CHK042 Are the platform-channel dependencies that widget tests must fake identified — image picking and secure storage in particular? [Gap, Research §R3, §R5]
- [x] CHK043 Is the required test fixture data specified — a canonical valid account, a valid and an invalid code, and a valid avatar file within the JPEG/PNG and 2 MB limits? [Completeness, Gap]
- [x] CHK044 Is the flakiness policy for the integration level stated (retries permitted or not, and how provider sign-in is handled without a human)? [Gap]

## Notes

- Check items off as completed: `[x]`
- An item passes when the *requirement* is complete, clear, and consistent — not when a test exists
- The largest single finding: three test levels are requested, but only the unit level was required
  anywhere in the artifacts (constitution testing gate). Widget and integration obligations, and every
  coverage number, were undefined — see CHK001, CHK015, CHK023
- Fixes for coverage targets, level split, exclusions, and enforcement land in a new **Testing
  Strategy** section of `plan.md`, per the scoping decision for this checklist

### Resolution pass 1 (2026-09-17)

38 of 44 items resolved by the new **Testing Strategy** section in [plan.md](../plan.md): coverage
target and metric, denominator exclusions, per-level floors and ownership, `FR-0xx` traceability
naming, seams and fixtures, the injected ticker that makes the cooldown assertable (CHK041), the
four-state rendering contract, both artifact conflicts, and the two product surfaces that had no test
target (sign-out location and the guest-gate trigger).

**At that time, 6 items remained open** because each needed a spec amendment rather than a testing decision (closed in Resolution pass 2 below):

| Item | Missing requirement | Impact if left open |
|---|---|---|
| CHK018 | Exact message text or string keys per failure in SC-007 | Widget tests can only assert *a* message rendered, not the right one |
| CHK022 | Any accessibility requirement | No a11y assertion is possible at any level |
| CHK030 | Quantified wrong-attempt cap | The attempt-cap path in SC-009 cannot be asserted |
| CHK031 | Registration-draft token lifetime | The expired-token branch of FR-026 and FR-036 is untestable |
| CHK035 | Observable definition for FR-051 | Pass and fail are indistinguishable |
| CHK038 | Apple second-authorization behavior | A known provider behavior has no specified expectation |

### Resolution pass 2 (2026-09-17)

All six leftover items are closed in spec.md, `contracts/auth-api.md`, and `tasks.md`:

| Item | Resolution |
|---|---|
| CHK018 | Spec **Error copy** table; widget tests assert those ids |
| CHK022 | FR-052 labels, field errors, text primary actions |
| CHK030 | FR-018a: **5** wrong OTP attempts then `too_many_attempts` |
| CHK031 | FR-026a / contract: `registration_token` valid **30 minutes** |
| CHK035 | FR-051: keep form text across process-alive backgrounding; draft-only after process death |
| CHK038 | FR-034a: reuse stored/draft email when Apple omits it on later authorization |

**0 items remain open.** The checklist no longer blocks `/speckit-implement`.
