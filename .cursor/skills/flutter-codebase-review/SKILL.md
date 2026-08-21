---
name: flutter-codebase-review
description: Audit an existing Flutter/Dart codebase as a staff engineer — architecture, state management, reliability, performance, testing, security, localization — and produce evidence-based category scores, prioritized findings, and an incremental roadmap. Use when the user asks to review, audit, or assess the health of a Flutter or Dart project, asks where its technical debt is, or asks whether a codebase is safe to keep building on. Read-only; never modifies project code.
disable-model-invocation: true
---

# Flutter Codebase Review

Audit an existing Flutter/Dart codebase and report on its health. The deliverable is a
decision — *is this codebase safe to keep building on, and what should be fixed first* —
supported by verifiable evidence.

## Non-goals

Do not rewrite the project, migrate its state management, or impose a preferred
architecture. Judge whether the architecture that exists is consistent, testable, and
proportional to the project's size. A small app with `setState` and no repositories may
be correctly built; a large app with hand-rolled Clean Architecture may not be.

## Read-only contract

Do not call `Write`, `StrReplace`, `Delete`, or `EditNotebook` on anything under the
project. Do not run git commands that mutate state (`commit`, `checkout`, `stash`,
`reset`). Read-only shell commands (`flutter analyze`, `dart pub outdated`, `git log`,
`wc`) are expected and encouraged.

Deliver the report in chat. Only write it to a file if the user asks, and then only
outside source directories (`docs/`, repo root, or `/tmp`).

---

## Step 0 — Agree on scope

Before reading code, state the scope and get confirmation if anything is ambiguous:

- Which package or app, if the repo is a monorepo or has multiple entry points.
- Which 2–4 features to probe deeply (see Stage 3). Default to auth plus the primary
  revenue or business flow.
- Depth: **triage** (~30 min, discovery + scorecard + top findings) or **full audit**
  (all stages, detailed findings). Default to full audit.

Use `AskQuestion` when the choice materially changes the work. Otherwise state your
assumption in one line and proceed.

---

## Stage 1 — Discover

Establish ground truth from configuration and tooling before forming any opinion.

Read: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `AGENTS.md` or
`CLAUDE.md`, `.cursor/rules/*.mdc`, CI config, `lib/` tree, `test/`,
`integration_test/`.

Run what is available:

```bash
flutter --version
flutter analyze                 # or: dart analyze
dart pub outdated               # dependency drift
find lib -name '*.dart' | wc -l # rough size
```

If a Dart MCP server is connected, prefer `analyze_files` and `pub` over shelling out,
and use `pub_dev_search` to check whether an unfamiliar dependency is maintained.

**Audit against declared standards first.** If the project ships `AGENTS.md`, a
constitution, or `.cursor/rules/*.mdc`, those are the contract the team agreed to.
Violations of a project's own written rules are stronger, less arguable findings than
violations of generic best practice. Note both, but lead with the former.

Record: Flutter/Dart version, approximate size, state management, DI, navigation,
networking, storage, localization, and test strategy. **Do not score yet.**

---

## Stage 2 — Map

Trace one representative request end to end and write down where responsibilities
*actually* live, as opposed to where the folder names imply they live:

```text
UI → controller/cubit/viewmodel → repository/service → API/DB → model → state → UI
```

Then look for dependency-direction problems: business logic in widgets, network calls
from `build()`, god controllers, `core/` used as a dumping ground, cross-feature
imports, circular dependencies, global state standing in for parameter passing.

Judge responsibilities, never pattern names.

---

## Stage 3 — Probe

Read the 2–4 features chosen in Step 0 in depth rather than skimming everything. For
each, trace entry point → UI → state → business logic → data access → navigation, and
confirm all four UI states exist: **loading, success, empty, error**.

Then compare features against each other. Where two features solve the same problem
differently, decide whether the divergence is justified or is drift, and say which.

Apply these lenses. The **signal** column is what to actually go looking for; skip
anything the codebase gives no evidence about.

| Lens | Signal that changes the score |
|---|---|
| Architecture | Responsibility leaks across layers, coupling between features, dependency direction, whether logic is reachable by a test |
| Code quality | Oversized methods and widgets, deep nesting, duplicated business rules, magic values that carry business meaning |
| Flutter practice | `build()` doing work, missing disposal, `BuildContext` used after `await`, `ListView` without a builder, missing keys on reorderable lists |
| State management | State ownership, rebuild scope, duplicated or desynchronized state, side effects fired from build |
| Project structure | Feature boundaries, shared-code cohesion, whether a new feature has an obvious home |
| Maintainability | Can a new engineer add a feature by copying an existing one without inheriting a bug |
| Reliability | Behavior on network failure, null/empty payloads, timeout, expired auth, double submit |
| Performance | Rebuild scope, unbounded lists, sync work on the main isolate, image and cache strategy, leaked subscriptions |
| Testing | Coverage of critical flows and API mapping, not raw percentage; whether logic is testable at all |
| Security | Hardcoded secrets, tokens in logs, insecure storage, unsafe WebView, weak validation |
| L10n / a11y | Hardcoded user-facing strings, RTL handling, text-scale overflow, semantic labels |

Do not flag every missing `const` as an architectural problem. Style preferences are
`Low` severity at most.

---

## Stage 4 — Score and report

Score the 11 weighted categories and assemble the report.

- Scale anchors, weights, and calibration examples: [rubric.md](rubric.md)
- Finding format, report skeleton, and a worked scorecard: [report-template.md](report-template.md)

Use **integer** scores. A `7` you can defend beats a `7.4` you cannot.

---

## Evidence discipline

Every finding above `Low` cites a path, and a class or function name where one applies.
Count occurrences when the count is the argument ("6 of 9 cubits", not "many cubits").

Label confidence explicitly, and keep the categories distinct:

- **Confirmed** — read the code, or a tool reported it.
- **Likely** — strong pattern evidence, no direct proof of the failure.
- **Potential** — plausible risk worth a look, not yet substantiated.

When something cannot be verified, write **"Not enough evidence to determine"** and move
on. An honest gap is worth more than a confident guess, and a fabricated finding
discredits the whole report.

---

## Judgment rules

1. Understand the architecture before scoring it.
2. Cite evidence for every score and every significant finding.
3. Scale expectations to project size, domain, and team size.
4. Separate confirmed issues from potential risks, in wording and in severity.
5. Distinguish technical debt from a deliberate, documented trade-off.
6. Recommend incremental change. Reserve "rewrite" or "migrate off X" for cases where
   evidence makes the alternative untenable, and say what that evidence is.
7. Rank by business impact, not by how much the code offends you.
8. Disclose what was not inspected. Never imply full coverage of a codebase you sampled.

Prefer *"presentation and data layers are increasingly coupled in checkout and orders"*
over *"the architecture is wrong."* The first is actionable and falsifiable; the second
is neither.

---

## Quality gate

Before delivering, confirm:

- [ ] Scope, depth, and probed features stated
- [ ] Architecture and state management identified from code, not from folder names
- [ ] Findings cite paths; confidence labeled
- [ ] Weighted total recomputed and arithmetically checked
- [ ] Verdict appears in the executive summary, not only at the end
- [ ] Roadmap is incremental and ordered by impact
- [ ] "Not inspected" section present
- [ ] No project file was modified

Report length should track the number of real findings. A healthy small codebase
deserves a short report; padding it to look thorough is its own failure.
