# Scoring Rubric

## Scale

Score each category as an **integer** 0–10.

| Band | Meaning |
|---:|---|
| 9–10 | Mature. Would hold up under team growth and feature pressure. |
| 7–8 | Solid, with known weaknesses that are contained. |
| 5–6 | Works, but debt is actively slowing delivery. |
| 3–4 | Weak. Changes in this area are risky. |
| 1–2 | Broken in practice. Needs intervention before further work. |
| 0 | Absent, or actively harmful. |

Reserve 10 for areas you would hold up as a reference example. Reserve 0–2 for evidence
of real breakage, not for absence of a pattern you happen to prefer.

If a category cannot be assessed, mark it **N/A**, redistribute its weight
proportionally across the remaining categories, and say so in the report.

## Weights

| Category | Weight |
|---|---:|
| Architecture & separation of concerns | 20% |
| Code quality | 15% |
| Flutter best practices | 15% |
| State management | 10% |
| Project structure | 10% |
| Reusability & maintainability | 10% |
| Error handling & reliability | 5% |
| Performance | 5% |
| Testing | 5% |
| Security | 3% |
| Localization & accessibility | 2% |

```text
weighted_points = score / 10 × weight
overall         = sum(weighted_points)      # out of 100
```

| Overall | Rating |
|---:|---|
| 90–100 | Excellent |
| 80–89 | Very good |
| 70–79 | Good |
| 60–69 | Needs improvement |
| 50–59 | Weak |
| 0–49 | Poor |

Recompute the sum before publishing and do not round upward.

---

## Calibration anchors

Anchors describe what a score *looks like* in code. Interpolate for odd values.

### Architecture & separation of concerns

| Score | Looks like |
|---:|---|
| 4 | Widgets call APIs directly. No consistent layering. Business rules are only reachable through the UI. |
| 6 | Layers exist and mostly hold, but leaks are routine — some cubits touch data sources, `core/` accumulates unrelated helpers. |
| 8 | Dependencies flow one direction. Occasional pragmatic shortcuts, documented or obvious. Logic is unit-testable without Flutter. |
| 10 | Boundaries hold under pressure. A new feature has one obvious shape. Domain has no framework imports. |

### Code quality

| Score | Looks like |
|---:|---|
| 4 | 300-line `build()` methods, copy-pasted validation, business constants inline as literals. |
| 6 | Readable, but recurring long methods and duplicated mapping or error handling. |
| 8 | Small focused units, intention-revealing names, duplication is deliberate rather than accidental. |
| 10 | Consistently clean; naming alone explains intent without comments. |

### Flutter best practices

| Score | Looks like |
|---:|---|
| 4 | Controllers never disposed, `setState` after `await` with no guard, non-lazy long lists. |
| 6 | Mostly correct; scattered missing disposal, over-broad rebuilds, `const` opportunities missed. |
| 8 | Lifecycle handled, rebuild scope narrowed deliberately, async/context safety observed. |
| 10 | Idiomatic throughout, including keys, semantics, and responsive behavior. |

### State management

| Score | Looks like |
|---:|---|
| 4 | Same state duplicated in several owners and manually synchronized. Side effects fire during build. |
| 6 | Single approach chosen, but state ownership is unclear and rebuilds are broader than necessary. |
| 8 | Clear ownership, explicit loading/success/error/empty modeling, narrow rebuild scope. |
| 10 | State is exhaustively modeled so invalid combinations are unrepresentable. |

### Project structure

| Score | Looks like |
|---:|---|
| 4 | Type-first folders (`models/`, `widgets/`) at root; unrelated code shares directories. |
| 6 | Feature-first, but boundaries are porous and shared code is a grab bag. |
| 8 | Consistent feature layout; a new file's location is unambiguous. |
| 10 | Structure communicates the domain; boundaries are enforced, not just conventional. |

### Reusability & maintainability

| Score | Looks like |
|---:|---|
| 4 | Changing shared behavior requires edits in many places, and misses are likely. |
| 6 | Some shared components, but forking is easier than extending. |
| 8 | Shared primitives are used consistently; copying an existing feature yields a correct one. |
| 10 | Extension points are obvious and cheap. |

### Error handling & reliability

| Score | Looks like |
|---:|---|
| 4 | Failures are swallowed or crash the UI. No timeout handling. Bare `catch`. |
| 6 | Errors handled, inconsistently — some flows show a message, others hang on a spinner. |
| 8 | Uniform failure model, specific exception types, user-facing recovery paths. |
| 10 | Failure is designed for: retries, offline behavior, double-submit protection. |

### Performance

| Score | Looks like |
|---:|---|
| 4 | Confirmed jank sources: unbounded lists, sync work in build, leaked subscriptions. |
| 6 | No confirmed problems, several likely risks under real data volume. |
| 8 | Rebuilds scoped, lists lazy, images cached, no leak evidence. |
| 10 | Measured and tuned, with evidence in the repo. |

### Testing

| Score | Looks like |
|---:|---|
| 4 | Tests exist but cover trivia; critical flows untested. |
| 6 | Meaningful unit coverage of some business logic; little widget or integration testing. |
| 8 | Critical flows, API mapping, and state transitions covered; tests are fast and reliable. |
| 10 | Coverage tracks risk, and the suite is trusted enough to gate releases. |

Judge value, not volume. Twenty tests over payments beat two hundred over getters.

### Security

| Score | Looks like |
|---:|---|
| 4 | Secrets or tokens in source or logs. Sensitive data in plain storage. |
| 6 | No hardcoded secrets, but weak validation or over-broad logging. |
| 8 | Secrets externalized, tokens stored securely, input validated at boundaries. |
| 10 | Defense in depth, including transport and platform-level protections. |

Do not treat public mobile configuration — Firebase app IDs, bundle identifiers,
publishable keys — as leaked secrets without evidence that they grant privileged access.

### Localization & accessibility

| Score | Looks like |
|---:|---|
| 4 | User-facing strings hardcoded. No RTL consideration. |
| 6 | Localization set up but bypassed in places; RTL and text scaling untested. |
| 8 | Strings externalized consistently; RTL and scaling handled. |
| 10 | Full parity across locales, plus semantics and tap-target compliance. |
