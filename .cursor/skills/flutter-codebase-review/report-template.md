# Findings and Report Format

## Severity

| Severity | Criteria |
|---|---|
| **Critical** | Security exposure, data loss, auth or payment failure, or architectural instability that blocks safe delivery. |
| **High** | Significant reliability, maintainability, or performance problem in a real user flow. |
| **Medium** | Meaningful debt to schedule, not urgent. |
| **Low** | Minor improvement, including style and consistency. |
| **Info** | Observation or note with no defect attached. |

## Priority

Severity says how bad it is; priority says what to do first. Assign from this table —
avoid pseudo-formulas, which invite arithmetic that means nothing.

| Priority | Assign when |
|---|---|
| **P0** | Critical severity, or high severity in a flow that touches money, auth, or data integrity. Fix before the next release. |
| **P1** | High severity, or medium severity that recurs across many files. Fix this cycle. |
| **P2** | Medium severity, contained. Fix opportunistically alongside feature work in the area. |
| **P3** | Low severity. Fix when already editing the file. |

Two modifiers, applied after the table:

- **Reach** — a defect repeated in 12 files outranks an equally severe one-off.
- **Effort** — a one-line fix can be promoted a level; a multi-week refactor should be
  demoted unless it is P0, and then split into independently shippable steps.

## Finding format

```text
[Severity] [Category] Title

Evidence:   path/to/file.dart — ClassName.methodName(), plus occurrence count
Problem:    what is wrong, stated mechanically
Impact:     what it costs — bug class, delivery drag, or user-visible failure
Fix:        smallest incremental change that resolves it
Confidence: Confirmed | Likely | Potential
```

### Good finding

```text
[High] [Reliability] Profile cubits swallow non-AppException failures

Evidence:   lib/features/profile/data/repositories/profile_repo_impl.dart
            All 7 methods catch only `on AppException`. A JSON shape change
            raises TypeError, which propagates as an unhandled async error.
Problem:    The repository maps one exception family to Failure and lets
            everything else escape the Either contract.
Impact:     Malformed API payloads bypass the error state, so the UI holds a
            loading spinner indefinitely instead of showing a retry path.
Fix:        Add a trailing `on Object catch` in the repository that logs and
            returns a generic Failure, preserving the Either boundary.
Confidence: Confirmed
```

### Weak finding — do not produce this

```text
[High] [Architecture] Tight coupling

The code is tightly coupled and hard to maintain. Consider Clean Architecture.
```

No path, no mechanism, no impact, and a recommendation that is a whole-project rewrite
rather than a change anyone can start on Monday.

---

## Report skeleton

Include sections that carry content. Drop the rest rather than filling them.

### 1. Verdict and summary

Lead with the answer, then justify it:

> **Yes, with targeted improvements — 73/100 (Good).** Layering is consistent and
> error handling is uniform at the repository boundary. The material risks are
> untested payment logic and three cubits that bypass their use case. Both are
> contained and fixable without restructuring.

Choose one verdict:

- Yes — healthy codebase.
- Yes, with targeted improvements.
- Yes, but major technical debt should be addressed first.
- No — architectural or reliability problems need attention before further feature work.

### 2. Scorecard

Show scores, weights, and weighted points so the arithmetic is auditable.

```text
Category                        Score  Weight  Points
Architecture                      8      20%    16.0
Code quality                      7      15%    10.5
Flutter best practices            8      15%    12.0
State management                  7      10%     7.0
Project structure                 8      10%     8.0
Maintainability                   7      10%     7.0
Reliability                       6       5%     3.0
Performance                       8       5%     4.0
Testing                           4       5%     2.0
Security                          8       3%     2.4
Localization & accessibility      7       2%     1.4
--------------------------------------------------
Overall                                         73.3  → Good
```

Verify the column sums before publishing.

### 3. Strengths

Name the decisions worth preserving. This is not padding — it tells the team what not
to trade away during refactoring, and it calibrates the criticism that follows.

### 4. Findings

`P0` and `P1` first, in full format. Group `P2`/`P3` by category, one line each.

### 5. Architecture assessment

Describe the architecture as it is, then coupling, testability, and how it behaves as
the team and feature set grow.

### 6. Roadmap

Sequence work so each phase ships independently:

```text
Phase 1 — Critical reliability and security       (P0)
Phase 2 — Coupling in the worst-affected features (P1)
Phase 3 — Extract duplicated logic                (P1–P2)
Phase 4 — Tests around critical flows             (P1–P2)
Phase 5 — Performance and remaining debt          (P2–P3)
```

Attach a rough size to each phase — days, not story points — and state what is
verifiably better when it lands.

### 7. Not inspected

List what was skipped and why: features not probed, platform code, generated code,
anything needing a running app or backend access. State plainly which scores are
therefore provisional.
