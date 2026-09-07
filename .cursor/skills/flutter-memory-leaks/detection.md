# Detecting Leaks

Static scanning finds missing releases. Only runtime evidence proves a leak. Use these in
order of cost.

---

## 1. DevTools memory snapshot diff

The primary tool. Run on a **profile** build — debug builds allocate extra objects and
skew both instance counts and retained sizes.

```bash
flutter run --profile
```

Procedure:

1. DevTools → **Memory** tab.
2. Navigate to the suspect screen and back **once** (warms lazy singletons, fonts, images
   so they do not pollute the diff). Take **Snapshot A**.
3. Run the exact same navigation cycle **5 times**, finishing where you started.
4. Press **GC**, then take **Snapshot B**.
5. Switch the snapshot view to **Diff** and sort by instance delta.

Reading the result:

| Observation | Meaning |
|---|---|
| Screen's `State` / cubit / controller grew by ~5 | Leak — one retained instance per cycle |
| Delta of 1–2 on shared infrastructure | Usually a cache; re-run with 10 cycles to confirm it does not scale |
| Delta 0, but the chart still climbs | Growth is in native memory (images, video, platform views), not the Dart heap |
| Everything drops after GC | No leak — the earlier growth was uncollected garbage |

Then select the leaked class → **retaining path**. It names the chain of references from a
GC root to the object. **The fix goes at the last object on that path that you own**, not
at the leaked object itself.

Common retaining paths and what they mean:

- `SchedulerBinding` → `Ticker` → `AnimationController` → `_State` — controller not disposed.
- `_BroadcastStreamController` → `_BroadcastSubscription` → closure → `_State` — subscription not cancelled.
- `GetIt` → singleton → closure → `_State` — a long-lived object captured the screen.
- `Timer` → closure → `_State` — timer not cancelled.

---

## 2. `leak_tracker` in widget tests

Automated, cheap, and runs in CI. Flutter's test framework integrates `leak_tracker`
through `leak_tracker_flutter_testing`.

```yaml
dev_dependencies:
  leak_tracker_flutter_testing: any
```

```dart
testWidgets(
  'ProfilePage disposes its controllers',
  experimentalLeakTesting: LeakTesting.settings.withTracked(allNotDisposed: true),
  (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    await tester.pumpWidget(const SizedBox.shrink());   // unmount
    await tester.pump();
  },
);
```

It reports two failure kinds:

- **notDisposed** — a disposable was garbage collected without `dispose()` being called.
- **notGCed** — `dispose()` ran, but something still holds the object.

Set it globally in `flutter_test_config.dart` to cover the whole suite at once.

---

## 3. The poor man's check (no tooling required)

Add a print to the lifecycle of a suspect class and run the navigation cycle:

```dart
@override
void initState() {
  super.initState();
  debugPrint('+ ${describeIdentity(this)}');
}

@override
void dispose() {
  debugPrint('- ${describeIdentity(this)}');
  super.dispose();
}
```

Five `+` and zero `-` means the widget is never disposed. Five of each means disposal runs
but something may still retain the object — go to the DevTools retaining path.

For cubits, the same in the constructor and `close()`.

---

## 4. Runtime signals that a leak already exists

Treat these as leak reports, not as errors to suppress:

| Message | What it proves |
|---|---|
| `setState() called after dispose()` | An async callback outlived the `State` |
| `Looking up a deactivated widget's ancestor` | A `BuildContext` was used after unmount |
| `emit was called after close was called` | A callback outlived its cubit |
| `A Ticker was disposed but was still active` | `AnimationController` not disposed |
| `dispose() called on a disposed ChangeNotifier` | Double ownership — two classes disposing one object |

The last one is the inverse bug: adding a `dispose()` where the object is owned elsewhere.
It is caused by the same missing question — *who owns this?*

---

## 5. Native memory growth

If the Dart heap is flat but the OS reports growth, the leak is outside the Dart heap.
Check, in order:

- **Image cache** — `PaintingBinding.instance.imageCache.currentSizeBytes`. Decode at
  display size with `cacheWidth`/`cacheHeight`; a 4000×3000 photo shown at 48 px costs
  roughly 48 MB decoded.
- **Video / audio players** — each needs an explicit `dispose()`; the native decoder is not
  reference-counted from Dart.
- **Platform views and WebViews** — dispose the controller, and confirm the view is removed
  from the tree.
- **Database and file handles** — `close()` on every opened connection.

DevTools' memory chart separates **Dart heap** from **RSS**; a widening gap between them
points here.

---

## 6. Project commands

```bash
flutter analyze                       # project gate: 0 warnings, 0 errors
flutter test                          # includes leak_tracker checks if configured
bash .cursor/skills/flutter-memory-leaks/scripts/scan_leaks.sh lib
```

If the Dart MCP server is connected, prefer its `analyze_files` and `get_runtime_errors`
tools over shelling out — `get_runtime_errors` surfaces the after-dispose exceptions from
section 4 directly from the running app.
