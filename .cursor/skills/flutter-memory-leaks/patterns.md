# Leak Patterns

Each pattern: what retains the object, the broken code, the fix. Ordered roughly by how
often it appears in real Flutter codebases.

---

## 1. `BuildContext` after `await`

**Retained by**: the closure holding `context`, which holds the `Element`, which holds the
whole subtree. Also the top cause of `Looking up a deactivated widget's ancestor` and
`setState() called after dispose()`.

```dart
// ❌ BAD: the widget may be gone by the time the request returns
Future<void> _submit() async {
  final result = await _repository.save(_form);
  Navigator.of(context).pop(result);            // stale context
  ScaffoldMessenger.of(context).showSnackBar(   // may throw, or leak the element
    const SnackBar(content: Text('Saved')),
  );
}

// ✅ GOOD: the null case is a decision, not a crash
Future<void> _submit() async {
  final result = await _repository.save(_form);
  if (!context.mounted) return;
  Navigator.of(context).pop(result);
}
```

Rules:

- `context.mounted` before using `context` after an `await`. `mounted` (the `State` field)
  before `setState`.
- Capture what you need **before** the `await` when it is context-derived and cheap:
  `final navigator = Navigator.of(context);` then `await ...; navigator.pop();`.
- Never store a `BuildContext` in a field, a singleton, a service, or a cubit.
- Best fix of all: move the `await` into a cubit so the widget never holds one (project
  rule 2.4).

---

## 2. Controllers and nodes never disposed

**Retained by**: `AnimationController` → its `Ticker` → `SchedulerBinding` (a root). Text
and scroll controllers → their `ChangeNotifier` listener lists.

Types that always need `dispose()`: `AnimationController`, `TextEditingController`,
`ScrollController`, `PageController`, `TabController`, `FocusNode`, `OverlayEntry`,
`ValueNotifier`, `ChangeNotifier`, `TransformationController`.

```dart
// ❌ BAD: every push of this screen leaks a controller and a ticker
class _EditorState extends State<Editor> with SingleTickerProviderStateMixin {
  final TextEditingController _title = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  late final AnimationController _fade =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  @override
  Widget build(BuildContext context) => const SizedBox();
}

// ✅ GOOD: everything acquired is released, super.dispose() last
class _EditorState extends State<Editor> with SingleTickerProviderStateMixin {
  final TextEditingController _title = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  late final AnimationController _fade =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    _fade.dispose();
    super.dispose();
  }
}
```

**Ownership caveat**: if the controller arrives via `widget.controller`, the parent owns
it. Disposing it here breaks the parent. Dispose only what this class constructed — and if
the widget supports both, track it: `final _ownsController = widget.controller == null;`.

---

## 3. `StreamSubscription` never cancelled

**Retained by**: the stream, which holds the callback, which captures `this`.

```dart
// ❌ BAD: subscription outlives the cubit; emit throws after close
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _connectivity.onStatusChange.listen((status) => emit(status.isOnline));
  }
  final ConnectivityService _connectivity;
}

// ✅ GOOD: held, then cancelled in close(), super.close() last
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _statusSub = _connectivity.onStatusChange.listen(_onStatus);
  }

  final ConnectivityService _connectivity;
  late final StreamSubscription<ConnectivityStatus> _statusSub;

  void _onStatus(ConnectivityStatus status) {
    if (isClosed) return;
    emit(status.isOnline);
  }

  @override
  Future<void> close() {
    _statusSub.cancel();
    return super.close();
  }
}
```

The `isClosed` check is a safety net for the in-flight event, not a substitute for
`cancel()`. Both are required.

`StreamController` you create also needs `.close()` — cancelling subscribers is not enough.

---

## 4. `Timer` / `Timer.periodic` never cancelled

**Retained by**: the event loop. A periodic timer also keeps burning CPU after the screen
is gone, which is a battery bug on top of a leak.

```dart
// ❌ BAD: keeps ticking, and keeps this State alive, forever
@override
void initState() {
  super.initState();
  Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
}

// ✅ GOOD
Timer? _ticker;

@override
void initState() {
  super.initState();
  _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
    if (!mounted) return;
    setState(() => _seconds++);
  });
}

@override
void dispose() {
  _ticker?.cancel();
  super.dispose();
}
```

The same applies to debounce timers in search fields — a very common source, since they
are created per keystroke and often only the last one is tracked.

---

## 5. Listeners added but never removed

**Retained by**: the notifier's listener list. Applies to `addListener`,
`WidgetsBinding.instance.addObserver`, route observers, and `FocusNode` listeners.

```dart
// ❌ BAD
@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  WidgetsBinding.instance.addObserver(this);
}

// ✅ GOOD — mirror the acquisitions in reverse
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _scrollController
    ..removeListener(_onScroll)
    ..dispose();
  super.dispose();
}
```

`removeListener` must receive the **same function reference** that was added. Passing a
closure (`addListener(() => _onScroll())`) makes removal impossible — always add a named
method, never an inline lambda.

Reference implementation in this codebase: `lib/shared/pagination/pagination_widget.dart`.

---

## 6. Long-lived references to widgets, `State`, or `BuildContext`

**Retained by**: whatever the singleton is registered on — usually the service locator,
which lives for the whole process.

```dart
// ❌ BAD: the navigator service pins one screen's element tree forever
class NavigationService {
  static BuildContext? context;   // set in some screen's initState
}

// ❌ BAD: a global cache of State objects
final Map<String, _DetailScreenState> _screenCache = {};

// ✅ GOOD: hold a GlobalKey<NavigatorState> on the root MaterialApp instead
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
MaterialApp(navigatorKey: navigatorKey, /* ... */);
```

Same failure through `GetIt`: a `registerLazySingleton` holding a callback that captures a
widget, or a feature object registered globally instead of inside a scope. This codebase's
answer is `FeatureScope` (`lib/core/di/feature_scope.dart`) — the scope is dropped on
`dispose()`, so everything registered in it becomes collectable.

---

## 7. Cubit / Bloc lifetime mismatches

**Retained by**: the `BlocProvider` that created it, or the DI container.

- Cubits are `registerFactory`, never `registerLazySingleton` (project constitution). A
  singleton cubit holds its last state — and every object inside it — indefinitely.
- `BlocProvider.value` does **not** close the cubit; the owner that created it must. Use
  `BlocProvider(create: ...)` when the provider should own the lifecycle.
- Override `close()` to cancel subscriptions, timers, and in-flight requests. Mix in
  `CubitRequestCanceller` for the Dio `CancelToken` case rather than duplicating it.

```dart
class SearchCubit extends Cubit<SearchState> with CubitRequestCanceller<SearchState> {
  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();   // the mixin cancels the CancelToken
  }
}
```

---

## 8. Unbounded caches and growing statics

**Retained by**: a static field — a GC root by definition. This is the one leak that grows
with no navigation at all.

```dart
// ❌ BAD: grows for the life of the process
class ThumbnailCache {
  static final Map<String, Uint8List> _bytes = {};
  static void put(String id, Uint8List data) => _bytes[id] = data;
}

// ✅ GOOD: bounded, and evictable under pressure
class ThumbnailCache {
  static const int _maxEntries = 100;
  static final LinkedHashMap<String, Uint8List> _bytes = LinkedHashMap();

  static void put(String id, Uint8List data) {
    if (_bytes.length >= _maxEntries) _bytes.remove(_bytes.keys.first);
    _bytes[id] = data;
  }

  static void clear() => _bytes.clear();
}
```

Also bound Flutter's own image cache when the app shows many large images:
`PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;` and decode at display
size with `cacheWidth` / `cacheHeight` — a full-resolution photo decoded into a 48 px
avatar wastes memory in proportion to the square of the ratio.

---

## 9. Closures capturing `this` in long-lived callbacks

**Retained by**: the closure. Dart captures the enclosing instance whenever the closure
touches any instance member — including implicitly.

```dart
// ❌ BAD: the analytics service outlives the screen and captures it via _userId
analytics.onFlush(() => log(_userId));

// ✅ GOOD: capture the value, not the object
final String userId = _userId;
analytics.onFlush(() => log(userId));
```

Prefer passing plain values into anything registered with a longer-lived object.

---

## 10. Isolates, ports, and platform resources

**Retained by**: the port registry or the platform side; these survive Dart-side GC
entirely.

```dart
final ReceivePort port = ReceivePort();
final Isolate isolate = await Isolate.spawn(_work, port.sendPort);

// release both
port.close();
isolate.kill(priority: Isolate.immediate);
```

Same discipline for: video and audio players, camera controllers, map controllers,
`WebViewController`, database and file handles, and native event channels — each has an
explicit `dispose`/`close`/`stop` that the platform side will not call for you.

---

## Quick reference

| Acquire | Release | Where |
|---|---|---|
| `TextEditingController()` / `ScrollController()` / `FocusNode()` | `.dispose()` | `State.dispose` |
| `AnimationController()` | `.dispose()` | `State.dispose` |
| `stream.listen(...)` | `subscription.cancel()` | `dispose` / `close` |
| `StreamController()` | `.close()` | `dispose` / `close` |
| `Timer()` / `Timer.periodic()` | `.cancel()` | `dispose` / `close` |
| `notifier.addListener(m)` | `.removeListener(m)` | `dispose` |
| `WidgetsBinding.instance.addObserver(this)` | `.removeObserver(this)` | `dispose` |
| `OverlayEntry()` | `.remove()` then `.dispose()` | `dispose` |
| `CancelToken()` | `.cancel()` | `Cubit.close` (via `CubitRequestCanceller`) |
| `sl.pushNewScope(...)` | `sl.dropScope(...)` | `State.dispose` (via `FeatureScope`) |
| `Isolate.spawn()` / `ReceivePort()` | `.kill()` / `.close()` | owner teardown |

`super.dispose()` and `super.close()` always go **last**.
