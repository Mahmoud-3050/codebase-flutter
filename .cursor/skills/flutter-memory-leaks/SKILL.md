---
name: flutter-memory-leaks
description: Find, fix, and verify memory leaks in Flutter/Dart code — undisposed controllers, uncancelled StreamSubscriptions and Timers, BuildContext used after await, listeners never removed, and long-lived references that keep widgets or State objects alive. Use when the user reports rising RAM, jank that gets worse the longer the app runs, out-of-memory crashes, "setState() called after dispose()" or "emit was called after close" errors, or asks to audit disposal coverage, dispose/close correctness, or DevTools memory snapshots.
disable-model-invocation: true
---

# Flutter Memory Leaks

A leak here means: the screen is gone, the app no longer needs the object, but the
garbage collector cannot reclaim it because something still holds a reference. The
symptom is not an immediate crash — it is an app that is fast on launch, drops frames
after ten minutes of navigation, and eventually gets killed by the OS.

**The rule that prevents most of them: anything you open, close.** Every `Controller()`,
`.listen()`, `Timer()`, `addListener()`, and `FocusNode()` is an *acquire* that needs a
matching *release* in the same class's `dispose()` or `close()`.

## Non-goals

Do not treat every allocation as a leak. Steady-state memory that rises and then plateaus
is a cache, not a leak. Only call something a leak when the retained set **grows across
repeated identical navigation cycles** and does not return after garbage collection.

Do not "fix" a leak by nulling fields, wrapping callbacks in `try`, or silencing the
`setState() called after dispose()` exception. Those hide the retaining reference instead
of releasing it.

---

## Workflow

```
- [ ] Step 1: Scope the investigation
- [ ] Step 2: Static scan for missing releases
- [ ] Step 3: Classify each hit — real leak, benign, or needs runtime proof
- [ ] Step 4: Fix by releasing the reference at its owner
- [ ] Step 5: Verify with DevTools snapshot diff
- [ ] Step 6: Add a regression guard
```

### Step 1 — Scope

Ask for, or infer, one thing: **which navigation cycle grows memory?** A leak hunt without
a reproducible cycle ("open product detail, go back, repeat") is guesswork. If the user
only has "the app gets slow", pick the 2–3 most-visited screens and start there.

State the scope in one line and proceed. Use `AskQuestion` only when the choice changes
which files get read.

### Step 2 — Static scan

Run the bundled scanner before reading anything:

```bash
bash .cursor/skills/flutter-memory-leaks/scripts/scan_leaks.sh lib
```

It reports acquire/release imbalances per file: disposables declared without `dispose()`,
`.listen()` without `.cancel()`, `Timer` without `.cancel()`, `addListener` without
`removeListener`, cubits with subscriptions but no `close()` override, and `BuildContext`
used after an `await` with no `mounted` guard.

The output is **heuristic**. It finds candidates; it does not prove leaks. Every hit gets
read before it gets reported.

### Step 3 — Classify

For each hit, decide which bucket it falls in:

| Bucket | Meaning | Action |
|---|---|---|
| **Confirmed leak** | Object outlives its owner and is reachable — read the code and traced the reference | Fix now |
| **Latent leak** | Release is missing, but the widget is currently mounted for the app's lifetime | Fix — it becomes real the moment the screen is pushed twice |
| **Benign** | Framework-owned (e.g. a controller passed in via constructor and disposed by the caller) | Skip, and say why |
| **Needs runtime proof** | Growth suspected but no ownership violation visible | Escalate to Step 5 |

**Ownership decides who disposes.** A widget disposes only what it created. A controller
received through the constructor belongs to the caller — disposing it there is a
use-after-free bug, not a fix.

### Step 4 — Fix

Apply the pattern for the specific cause. The full catalog with before/after code is in
[patterns.md](patterns.md):

| Symptom | Cause | Fix |
|---|---|---|
| RAM climbs each time a screen is opened and closed | Controller / `FocusNode` created in `State` and never disposed | Release it in `dispose()`, `super.dispose()` last |
| `setState() called after dispose()` | `await` completed after the widget was unmounted | Guard with `if (!mounted) return;` after the `await` |
| `Looking up a deactivated widget's ancestor` | `BuildContext` used after an `await` | Guard with `if (!context.mounted) return;` before touching `context` |
| CPU stays busy after leaving a screen | `Timer.periodic` or `StreamSubscription` still running | `.cancel()` in `dispose()` / `close()` |
| `emit was called after close` | Cubit emits from a callback that outlived it | Cancel the subscription in `close()`; check `isClosed` |
| One screen's memory never drops | Widget, `State`, or `BuildContext` stored in a singleton or `GetIt` | Never store them; pass values, or scope the registration |
| Memory grows without any navigation | Unbounded static cache or growing list | Bound the cache; clear on lifecycle events |

Fix at the **owner** of the reference, not at the victim. Adding a `mounted` check to a
callback that should never have been retained treats the symptom.

### Step 5 — Verify with DevTools

Guessing by eye does not confirm a fix. Prove it:

1. Open Flutter DevTools → **Memory** tab, on a **profile** build (`flutter run --profile`).
   Debug builds carry allocation noise that distorts the numbers.
2. Navigate to the suspect screen and back once, to warm caches. Take **Snapshot A**.
3. Repeat the exact same navigation cycle **5 times**, ending in the same place.
4. Press **GC**, then take **Snapshot B**.
5. **Diff B against A.** A leak looks like the screen's `State` class, its cubit, or its
   controller with an instance count that grew by ~5.
6. Select the leaked class → **retaining path**. That path names the object still holding
   the reference. That object is where the fix goes.

Re-run the same cycle after fixing. Instance delta should be 0.

Detection tooling beyond DevTools — `leak_tracker`, `debugPrintScheduleBuildForStacks`,
memory tests in CI — is in [detection.md](detection.md).

### Step 6 — Regression guard

A fixed leak with no test comes back. Add whichever is cheapest:

- A widget test that pumps the screen, pumps `SizedBox.shrink()` to unmount it, and
  asserts no exception is thrown (catches emit/setState-after-dispose).
- `testWidgets(..., experimentalLeakTesting: LeakTesting.settings)` when
  `leak_tracker_flutter_testing` is available.
- At minimum, a `dispose()` override in the class, which is itself the guard.

---

## Project conventions

This codebase already has the right patterns. Reuse them instead of inventing new ones.

**Cubits cancel their in-flight requests.** `CubitRequestCanceller`
(`lib/core/presentation/cubit_request_canceller.dart`) owns a Dio `CancelToken`, cancels it
in `close()`, and exposes `shouldIgnoreFailure` which checks `isClosed`. Any cubit making
cancellable network calls should mix it in rather than hand-rolling an `isClosed` check.

**Cubit `close()` is the cubit's `dispose()`.** Cancel subscriptions and timers there, and
call `super.close()` **last** — the same acquire/release discipline as widget `dispose()`.

**Feature DI is scoped, not global.** `FeatureScope` (`lib/core/di/feature_scope.dart`)
pushes a named GetIt scope on enter and drops it in `dispose()`. Registering a
feature-lifetime object as a global `registerLazySingleton` keeps it — and everything it
captures — alive for the whole process. Per the project constitution, cubits are
`registerFactory`; never a singleton.

**The reference implementation for listener discipline** is
`lib/shared/pagination/pagination_widget.dart`: it creates its `ScrollController` in
`initState`, tears it down with `..removeListener(_onScroll)..dispose()`, and guards its
post-frame callback with `if (!mounted) return;`.

**Async work lives in cubits, not widgets** (rule 2.4). A widget that never `await`s cannot
use a stale `BuildContext`. Most `context`-after-`await` bugs disappear by moving the work
into a cubit and having the widget listen.

---

## Reporting

When reporting findings, one entry per leak:

```markdown
### `LeakedThing` in `lib/features/x/presentation/pages/x_page.dart`

**Severity**: High — grows by one instance per screen open
**Cause**: `AnimationController` created in `initState`, no `dispose()` override
**Retained by**: the `Ticker` registered with `SchedulerBinding`
**Fix**: dispose the controller in `dispose()` before `super.dispose()`
**Confidence**: Confirmed — DevTools snapshot diff, +5 instances over 5 cycles
```

Label confidence honestly: **Confirmed** (snapshot or retaining path proves it),
**Likely** (missing release, ownership is clear), **Potential** (suspicious, unverified).
Write "Not enough evidence to determine" rather than guessing — a fabricated leak sends
someone on a multi-hour hunt.

Rank by growth rate × visit frequency. A 2 KB leak on the home screen outranks a 400 KB
leak on a settings page nobody opens.

---

## Quality gate

Before finishing:

- [ ] Every reported leak names the retaining reference, not just the missing `dispose()`
- [ ] Ownership checked — nothing disposes an object it did not create
- [ ] `super.dispose()` / `super.close()` is the **last** statement in every override
- [ ] Every `await` followed by `context` or `setState` has a `mounted` guard
- [ ] Fixes verified by snapshot diff, or the report says verification was not run
- [ ] `flutter analyze` clean (project gate: 0 warnings, 0 errors)
- [ ] No leak was "fixed" by nulling a field or swallowing an exception

## Additional resources

- Leak patterns with before/after code: [patterns.md](patterns.md)
- DevTools, `leak_tracker`, and CI detection: [detection.md](detection.md)
- Heuristic scanner: `scripts/scan_leaks.sh`
