# themes — Package Rules

Rules for refactoring, structuring, and extending this package.
Follow them in every change. Prefer a small, testable API over cleverness.

Host setup lives in `GUIDE.md`. This file is for people changing the package.

This package is **not** a host feature module. Stay framework-light
(Flutter SDK only). Host apps supply palettes, persistence, and side
effects through Dart config and ports. Do **not** add `flutter_bloc`,
`hydrated_bloc`, `equatable`, `shared_preferences`, `get_it`, or `yaml`.

---

## 0. Expert defaults (read first)

1. **Mutable app-wide theme state lives on `Themes.instance`**, not on
   `static` mutable fields. Modes are Flutter `ThemeMode.light` /
   `ThemeMode.dark` only — not `system`, not a host `enum Themes`.
2. **One reason to change per type.** If a class name needs “and”, split it.
3. **Depend on abstractions you own** (`ThemeStorage`,
   `ThemeChangeListener`). Never import host types (`Dio`, `GetIt`,
   `SharedPreferences`, `flutter_screenutil`).
4. **Widgets only rebuild.** They never write storage or branch on
   `isDark` to pick `primary` vs `primaryDark`.
5. **Invalid states must be unrepresentable** — specific exceptions, no
   `ThemeMode.system` after `init`.
6. **Tests reset the singleton** via `package:themes/testing.dart`
   (`resetThemes()`). Never put `reset` on the host-facing `Themes`
   API. The helper must **not** call `dispose()` on the process singleton.
7. **Do not grow the public barrel.** Export only what a host must import.
8. **New colors are `extra` keys**, not new `ThemeColors` fields, unless
   the token belongs on `ColorScheme` / every screen.

---

## 1. Package structure (current)

```text
packages/themes/
├── GUIDE.md                          # host how-to
├── RULES.md                          # this file
├── pubspec.yaml
├── lib/
│   ├── themes.dart                   # public barrel + BuildContext extension
│   ├── testing.dart                  # test-only: resetThemes
│   └── src/
│       ├── domain/
│       │   ├── themes.dart           # singleton + ChangeNotifier
│       │   ├── theme_config.dart
│       │   ├── theme_storage.dart    # port + InMemoryThemeStorage
│       │   ├── theme_change_listener.dart
│       │   └── theme_exceptions.dart
│       └── presentation/
│           ├── theme_colors.dart     # ThemeExtension
│           ├── theme_data_factory.dart
│           └── widgets/
│               └── theme_builder.dart
└── test/
    └── themes_test.dart
```

There is **no** `ThemeCubit`. `Themes` **is** the `ChangeNotifier`.
Do not reintroduce a second listenable.

There is **no** YAML / data layer. Palettes are Dart `ThemeConfig`.

### Layer rules

| Layer | May import | Must not import |
|---|---|---|
| **domain (ports / config / facade)** | Dart core, `ThemeColors`, Flutter `ThemeMode` | host packages, ScreenUtil |
| **presentation** | domain + Flutter widgets | host packages |
| **`Themes` (facade)** | domain + `ThemeDataFactory` | host types |

`Themes` lives under `domain/` as the package facade. It is the only
domain type allowed to import `ThemeDataFactory`, because `lightTheme` /
`darkTheme` orchestrate color `ThemeData`. Other domain types stay free
of widget layout.

`ThemeConfig` may import `ThemeColors` because the palette **is** colors.
`ThemeColors` uses `material.dart` for `ThemeExtension`.

Do not pull `MaterialApp` into value objects.

### Public barrel (`lib/themes.dart`)

**Exported:** `Themes`, `ThemeColors`, `ThemeConfig`, `ThemeStorage`,
`InMemoryThemeStorage`, `ThemeChangeListener`, `ThemeBuilder`,
exceptions, `ThemesContext`.

The domain file is exported with `show Themes` so `resetThemes` is **not**
part of the host API.

**Unexported from the host barrel:** `ThemeDataFactory`, `resetThemes`.
Tests import `package:themes/testing.dart` and `package:themes/src/…`.

---

## 2. Clean Code

### 2.1 Small, single-purpose functions

`init` sequences collaborators; it does not inline `ThemeData` component
themes (AppBar font sizes). That is the host `copyWith`.

### 2.2 Intention-revealing names

| Avoid | Prefer |
|---|---|
| `AppTheme`, `AppColors` | `Themes`, `ThemeColors` |
| `thm`, `cfg` | `themes`, `config` |
| `onChange` in `main()` | `ThemeChangeListener` |

Flutter already has `Theme` and `Colors`. Do not reuse those names.

### 2.3 No magic strings

Storage values are `ThemeMode.light.name` / `ThemeMode.dark.name`
(`'light'` / `'dark'`). Host storage **keys** (`appTheme`) live in the
**host** adapter.

### 2.4 Guard clauses

Validate at the config / mode boundary. Throw specific exceptions:

- `InvalidThemeConfigException`
- `ThemeNotInitializedException`
- `UnsupportedThemeException`
- `MissingThemeExtraException`

Never `throw Exception('error')`.

### 2.5 DRY

Light vs dark values live on two `ThemeColors` instances. Widgets and
`ExtraColors` getters never branch on mode.

### 2.6 Comments explain why

Keep comments for: why `init` must run before `runApp`, why ScreenUtil
`copyWith` cannot run in `init`, why `resetThemes()` must not `dispose()`,
why `ThemeMode.system` is rejected.

---

## 3. OOP principles

### 3.1 Encapsulation

Hide mutable fields. Callers use `init`, `changeTheme`, and getters.
`extras` is an unmodifiable view.

Before `init` / after `resetThemes()`, `colors` throws — not a fake light
palette.

### 3.2 Singleton instead of static classes

If the type holds *mutable process-wide state*, it is a singleton instance.
If it is a namespace of pure functions, use `abstract final class`.

| Type | Pattern |
|---|---|
| `Themes` | **Singleton** + `ChangeNotifier` |
| `ThemeDataFactory` | `abstract final` static methods |
| `ThemeConfig` / `ThemeColors` | immutable value objects |
| `ThemeStorage` / `ThemeChangeListener` | `abstract interface class` ports |
| `InMemoryThemeStorage` | ordinary instance (default adapter) |

```dart
final class Themes extends ChangeNotifier {
  Themes._();
  static final Themes instance = Themes._();
  factory Themes() => instance;
  void _reset() { /* not on the host API — do not dispose() */ }
}

@visibleForTesting
void resetThemes() => Themes.instance._reset();
```

**Do not** make a singleton of value objects, `ThemeBuilder`, or host
`SharedPreferences`.

**Tests:** `import 'package:themes/testing.dart';` then `resetThemes()` in
`setUp` / `tearDown`. Do not add `Themes.reset`.

### 3.3 Composition over inheritance

Do not build `class DarkThemes extends Themes`. Compose storage, listener,
and config. Widgets compose `ThemeBuilder`; they do not subclass it.

### 3.4 Program to an interface

Ports are `abstract interface class`. Hosts `implements` them. Package
code never constructs a host type. The storage field is typed `ThemeStorage`.

### 3.5 Immutability for values

`ThemeColors` and `ThemeConfig` are immutable. Mutation of “current mode”
is the singleton’s job.

---

## 4. SOLID

### 4.1 SRP

| Type | Reason to change |
|---|---|
| `Themes` | init / current mode / notify / `changeTheme` |
| `ThemeConfig` | which palettes and default mode |
| `ThemeColors` | token fields + extra map + lerp |
| `ThemeDataFactory` | how tokens map to `ThemeData` / `ColorScheme` |
| `ThemeStorage` | persistence contract only |
| `ThemeChangeListener` | host side-effect contract only |
| `ThemeBuilder` | how the tree subscribes to the singleton |

If `Themes.init` starts setting `18.sp` AppBar styles, it has stolen SRP
from the host.

### 4.2 OCP

New persistence → new `ThemeStorage` in the **host**.
New side effects → new `ThemeChangeListener` in the **host**.
New one-off colors → host `extra` + `ExtraColors`. Do not add a field to
`ThemeColors` for a single-screen color.

### 4.3 LSP

`getThemeMode` returns `null` on first launch, never throws for a missing
key. `saveThemeMode` persists `'light'` or `'dark'`. `init` restores that
value only on an **exact** match; anything else falls back to `defaultMode`.
`InMemoryThemeStorage` must behave the same way.

### 4.4 ISP

`ThemeStorage` is get + save of **one** mode string — not a generic
key-value store.

`ThemeChangeListener` is one method: `onThemeChanged`.

### 4.5 DIP

```text
Themes (policy)
    depends on
ThemeStorage, ThemeChangeListener (abstractions)
    implemented by
host adapters
```

The package ships `InMemoryThemeStorage` as a default. The field type
stays `ThemeStorage`.

---

## 5. Design patterns in this package

| Pattern | Where | Role |
|---|---|---|
| **Singleton** | `Themes` | one process-wide theme state |
| **Facade** | `Themes.init` | config + storage |
| **Port / Adapter** | `ThemeStorage`, `ThemeChangeListener` | host plugs in |
| **Observer** | `ChangeNotifier` + `ThemeBuilder` (`ListenableBuilder`) | UI rebuilds |
| **Strategy** | storage / listener implementations | swappable |
| **Value Object** | `ThemeColors`, `ThemeConfig` | equality by value |
| **Null Object** | `InMemoryThemeStorage` when host omits storage | safe default |
| **Guard** | `ThemeNotInitializedException`, `UnsupportedThemeException` | fail fast |

**Do not use:** Bloc / Cubit / HydratedBloc, GetIt inside the package, YAML
as the daily color source, a god `Utils` class, `primary` vs `primaryDark`
fields, a second `ThemeController`.

### Observer wiring

`ThemeBuilder` listens to `Themes.instance` via `ListenableBuilder`.
Side effects do **not** live in the widget; they live in
`ThemeChangeListener`.

Call `onThemeChanged`:

1. once at the end of `init` (restored or default mode)
2. after every successful `changeTheme` (skip when mode is unchanged)

### Dart palettes, not YAML

Host `ThemeConfig` is the source of truth. Hex edits hot-reload. YAML is
out of scope for this package.

---

## 6. Flutter-specific rules

- Call `init` after `WidgetsFlutterBinding.ensureInitialized()` and
  **before** `runApp`.
- `ThemeBuilder` wraps `MaterialApp` / `MaterialApp.router` and passes
  `themeMode` from the singleton.
- Host `copyWith` for fonts / `.sp` / `.w` must run **inside**
  `ScreenUtilInit`, not in `Themes.init`.
- Do not `dispose()` the process singleton from a widget `dispose()`.
  Tests call `resetThemes()` from `package:themes/testing.dart`.

---

## 7. Error handling

| Situation | Type |
|---|---|
| `defaultMode == ThemeMode.system` | `InvalidThemeConfigException` |
| `changeTheme` before `init` | `ThemeNotInitializedException` |
| `changeTheme(ThemeMode.system)` | `UnsupportedThemeException` |
| `extra` key missing | `MissingThemeExtraException` |

Do not swallow errors with empty `catch` in orchestration.

---

## 8. Testing rules

- `setUp` / `tearDown` call `resetThemes()` (testing library).
- Fake `ThemeStorage` and `ThemeChangeListener` — do not use
  SharedPreferences.
- Cover: default mode, storage restore, invalid stored value, no-op
  `changeTheme`, `ThemeMode.system`, missing extra, `ThemeBuilder` rebuild,
  `resetThemes()` → uninitialized.
- Package tests must not import `lib/` of the host app.
- Host tests of the app may import `package:themes/testing.dart`;
  production `lib/` of the host must not.

---

## 9. Refactoring workflow (when changing this package)

Work in this order; keep behavior unless the task says otherwise.

1. **Structure** — file in the wrong layer? Split SRP violations.
2. **Catalog** — no `ThemeMode.system`; no YAML.
3. **Naming** — not `AppTheme` / `AppColors`; not Flutter `Theme` / `Colors`.
4. **Guards** — init-not-called, system mode, missing extra.
5. **DIP** — any new `if (storageType == …)` becomes a new host adapter.
6. **Tokens** — prefer `extra` over a new typed field.
7. **Tests** — reset singleton.
8. **Barrel** — export only the new public type, if it is public.
9. **GUIDE.md** — update host snippets when the public API changes.

---

## 10. Quick checklist

| Check | Pass |
|---|---|
| No Bloc / Equatable / prefs / yaml in `pubspec.yaml` | |
| Mutable theme state is on the singleton, not `static` | |
| Only `ThemeMode.light` / `dark` | |
| Host implements `ThemeStorage` + optional `ThemeChangeListener` | |
| Widgets do not pick `primaryDark` | |
| Host Dart `ThemeConfig` drives palettes | |
| `init` before `runApp`; `resetThemes` in tests only; no singleton `dispose()` | |
| `changeTheme(system)` throws | |
| Ports stay small; adapters live in the host | |
| Public barrel did not grow without need | |
| No `ThemeCubit` / second source of truth for `_mode` | |
