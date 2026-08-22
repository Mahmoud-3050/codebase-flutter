# language — Package Rules

Rules for refactoring, structuring, and extending this package.
Follow them in every change. Prefer a small, testable API over cleverness.

Host setup lives in `GUIDE.md`. This file is for people changing the package.

This package is **not** a host feature module. Stay framework-light
(Flutter SDK + `flutter_localizations` + `yaml`). Host apps supply persistence
and side effects through ports. Do **not** add `flutter_bloc`,
`hydrated_bloc`, `equatable`, `shared_preferences`, or `get_it`.

---

## 0. Expert defaults (read first)

1. **Mutable app-wide language state lives on `Language.instance`**, not on
   `static` mutable fields. Do **not** add `Language.en` / `Language.ar`
   (or an enum) as a catalog. Options come from YAML `files`.
2. **One reason to change per type.** If a class name needs “and”, split it.
3. **Depend on abstractions you own** (`LanguageStorage`,
   `LanguageChangeListener`). Never import host types (`Dio`, `GetIt`,
   `SharedPreferences`).
4. **Widgets only rebuild.** They never load JSON, parse YAML, or write
   storage.
5. **Invalid states must be unrepresentable** — specific exceptions, strict
   file-name rules, YAML validation at the boundary.
6. **Tests reset the singleton** via `package:language/testing.dart`
   (`resetLanguage()`). Never put `reset` on the host-facing `Language`
   API. The helper must **not** call `dispose()` on the process singleton.
7. **Do not grow the public barrel.** Export only what a host must import.

---

## 1. Package structure (current)

```text
packages/language/
├── GUIDE.md                          # host how-to
├── RULES.md                          # this file
├── pubspec.yaml
├── lib/
│   ├── language.dart             # public barrel + BuildContext extension
│   ├── testing.dart                  # test-only: resetLanguage
│   └── src/
│       ├── domain/
│       │   ├── language.dart     # singleton + ChangeNotifier
│       │   ├── language_model.dart
│       │   ├── language_config.dart
│       │   ├── language_file_parser.dart
│       │   ├── language_storage.dart # port + InMemoryLanguageStorage
│       │   ├── language_change_listener.dart
│       │   └── language_exceptions.dart
│       ├── data/
│       │   ├── language_yaml_loader.dart
│       │   └── asset_language_loader.dart
│       └── presentation/
│           ├── language_localizations.dart
│           ├── language_localizations_delegate.dart
│           ├── language_localizations_setup.dart
│           └── widgets/
│               └── language_builder.dart
└── test/
    └── language_test.dart
```

There is **no** `LanguageController`. `Language` **is** the
`ChangeNotifier`. Do not reintroduce a second listenable.

### Layer rules

| Layer | May import | Must not import |
|---|---|---|
| **domain (values / ports / parser)** | Dart core, `dart:ui` (`Locale`), other domain types | `yaml`, widgets, `AssetBundle` I/O |
| **data** | domain + `yaml` + `flutter/services.dart` (`AssetBundle`) | presentation, host packages |
| **presentation** | domain + Flutter widgets + `AssetLanguageLoader` for JSON | YAML parser |
| **`Language` (facade)** | domain + data loaders + `LanguageLocalizations.load` | host types |

`Language` lives under `domain/` as the package facade. It is the only
domain type allowed to import data/presentation, because `init` /
`changeLanguage` orchestrate YAML, storage, and translation load. Other
domain types stay pure.

`LanguageModel.locale` uses `dart:ui` `Locale` — not `material.dart`.
Do not pull `MaterialApp` or widgets into value objects.

### Public barrel (`lib/language.dart`)

**Exported:** `Language`, `LanguageModel`, `LanguageStorage`,
`InMemoryLanguageStorage`, `LanguageChangeListener`, `LanguageBuilder`,
`LanguageLocalizations` + `.tr` / `.trParams`, `LanguageLocalizationsSetup`, exceptions,
`LanguageContextExtension`.

The domain file is exported with `show Language` so top-level test helpers
in that library are **not** part of the host API.

**Unexported from the host barrel:** `LanguageFileParser`, `LanguageYamlLoader`,
`AssetLanguageLoader`, `LanguageConfig`, `resetLanguage`. Tests import
`package:language/testing.dart` and `package:language/src/…`.

---

## 2. Clean Code

### 2.1 Small, single-purpose functions

`init` sequences collaborators; it does not inline YAML parsing, file-name
regex, or JSON decode.

```dart
Future<void> init({LanguageStorage? storage, …}) async {
  final config = config ?? await LanguageYamlLoader.load(…);
  applyConfig(config);
  _current = fromCode(await _storage.getLanguageCode());
  await _loadTranslations(_current);
  _listener?.onLanguageChanged(_current);
  notifyListeners();
}
```

### 2.2 Intention-revealing names

| Avoid | Prefer |
|---|---|
| `lang`, `l`, `cfg` | `language`, `config`, `jsonAssetPaths` |
| `data`, `map` | `localizedStrings`, `yamlDocument` |
| `onChange` in `main()` | `LanguageChangeListener` |

### 2.3 No magic strings

YAML keys and the default asset name are named constants on
`LanguageYamlKeys` / `LanguageYamlLoader.defaultAssetName`. Host storage keys
(`languageCode`) live in the **host** adapter.

### 2.4 Guard clauses

Validate at the YAML / file-name boundary. Throw specific exceptions:

- `InvalidLanguageYamlException`
- `InvalidLanguageFileNameException`
- `MissingLanguageYamlException`
- `LanguageNotInitializedException`
- `UnsupportedLanguageException`

Never `throw Exception('error')`.

### 2.5 DRY

File-name parsing belongs in `LanguageFileParser` only. Path → language
belongs in `LanguageConfig.declaredLanguages` / `assetPathFor`. Code → model
belongs in `LanguageModel.lookup` (used by `fromCode` and YAML
`default_language`). Do not re-split `'ar_EG.json'` in localizations or the
YAML loader.

### 2.6 Comments explain why

Keep comments for: why `init` must run before `runApp`, why
`default_language` is not always `files.first`, why `resetLanguage()` must not
`dispose()`, why widget tests must pass a fake `AssetBundle`.

---

## 3. OOP principles

### 3.1 Encapsulation

Hide mutable fields. Callers use `init`, `changeLanguage`, and getters.
`supportedLanguages` is an unmodifiable view.

Before `init` / after `resetLanguage()`, current language is `und` and
`supportedLanguages` is empty — not a hardcoded `en`/`ar` list.

### 3.2 Singleton instead of static classes

If the type holds *mutable process-wide state*, it is a singleton instance.
If it is a namespace of pure functions, use `abstract final class`.

| Type | Pattern |
|---|---|
| `Language` | **Singleton** + `ChangeNotifier` |
| `LanguageLocalizations` | instance per locale + cached active instance |
| `LanguageYamlLoader` / `LanguageFileParser` / `AssetLanguageLoader` | `abstract final` static methods |
| `LanguageConfig` / `LanguageModel` | immutable value objects |
| `LanguageStorage` / `LanguageChangeListener` | `abstract interface class` ports |
| `InMemoryLanguageStorage` | ordinary instance (default adapter) |

```dart
final class Language extends ChangeNotifier {
  Language._();
  static final Language instance = Language._();
  factory Language() => instance;
  void _reset() { /* not on the host API — do not dispose() */ }
}

@visibleForTesting
void resetLanguage() => Language.instance._reset();
```

Language **options** come only from YAML `files` via `supportedLanguages`.
`LanguageModel.en` / `.ar` may exist as well-known aliases for tests and
native-name defaults; they are not the catalog.

`changeLanguage` rejects models that are not in `supportedLanguages`.

**Do not** make a singleton of value objects, `LanguageBuilder`, loaders, or
host `DioConsumer` / `SharedPreferences`.

**Tests:** `import 'package:language/testing.dart';` then
`resetLanguage()` in `setUp` / `tearDown`. Do not add `Language.reset`.

### 3.3 Composition over inheritance

Do not build `class ArabicLanguage extends Language`. Compose storage,
listener, and config. Widgets compose `LanguageBuilder`; they do not subclass
it.

### 3.4 Program to an interface

Ports are `abstract interface class`. Hosts `implements` them. Package code
never constructs a host type. The storage field is typed `LanguageStorage`.

### 3.5 Immutability for values

`LanguageModel` and `LanguageConfig` are immutable. Equality on the model
is `code` + `countryCode` (native name ignored). Mutation of “current
language” is the singleton’s job.

---

## 4. SOLID

### 4.1 SRP

| Type | Reason to change |
|---|---|
| `Language` | init / current locale / notify / `changeLanguage` |
| `LanguageYamlLoader` | YAML shape / asset name |
| `LanguageFileParser` | file-name grammar |
| `AssetLanguageLoader` | JSON bytes → `Map<String, String>` |
| `LanguageConfig` | path ↔ model mapping |
| `LanguageModel.lookup` | how codes resolve to variants |
| `LanguageStorage` | persistence contract only |
| `LanguageChangeListener` | host side-effect contract only |
| `LanguageBuilder` | how the tree subscribes to the singleton |
| `LanguageLocalizations` | key lookup / `.tr` / `.trParams` |
| `LanguageLocalizationsSetup` | Flutter locale list / resolution / delegates |

If `Language.init` starts parsing regex, it has stolen SRP from
`LanguageFileParser`.

### 4.2 OCP

New persistence → new `LanguageStorage` in the **host**.
New side effects → new `LanguageChangeListener` in the **host**.
New languages → YAML `files` + JSON assets. Do not hard-code `en`/`ar` as
the only pair after `init`.

### 4.3 LSP

`getLanguageCode` returns `null` on first launch, never throws for a missing
key. `saveLanguageCode` persists the JSON file stem (`ar` or `ar_EG`).
`init` restores that value only on an **exact** match against `files`;
invalid or stale stems fall back to `defaultLanguage`.
`InMemoryLanguageStorage` must behave the same way.

### 4.4 ISP

`LanguageStorage` is get + save of **one** language code — not a generic
key-value store.

`LanguageChangeListener` is one method: `onLanguageChanged`.

### 4.5 DIP

```text
Language (policy)
    depends on
LanguageStorage, LanguageChangeListener (abstractions)
    implemented by
host adapters
```

The package ships `InMemoryLanguageStorage` as a default. The field type
stays `LanguageStorage`.

---

## 5. Design patterns in this package

| Pattern | Where | Role |
|---|---|---|
| **Singleton** | `Language` | one process-wide language state |
| **Facade** | `Language.init` | YAML + storage + translations |
| **Port / Adapter** | `LanguageStorage`, `LanguageChangeListener` | host plugs in |
| **Observer** | `ChangeNotifier` + `LanguageBuilder` (`ListenableBuilder`) | UI rebuilds |
| **Strategy** | storage / listener implementations | swappable |
| **Value Object** | `LanguageModel`, `LanguageConfig` | equality by value |
| **Factory** | `LanguageYamlLoader.parse` / `load` | config from YAML |
| **Null Object** | `InMemoryLanguageStorage` when host omits storage | safe default |
| **Guard** | `LanguageNotInitializedException`, `UnsupportedLanguageException` | fail fast |

**Do not use:** Bloc / Cubit / HydratedBloc, GetIt inside the package, a god
`Utils` class, inheritance hierarchies for languages, a second
`LanguageController`.

### Observer wiring

`LanguageBuilder` listens to `Language.instance` via `ListenableBuilder`.
Side effects do **not** live in the widget; they live in
`LanguageChangeListener`.

Call `onLanguageChanged`:

1. once at the end of `init` (restored or default language)
2. after every successful `changeLanguage` (skip when language is unchanged)

### YAML as configuration, not code

`language.yaml` is the source of truth:

- `default_language` → `defaultLanguage` and first-launch locale (optional;
  omitted → first `files` entry)
- `files` → `supportedLanguages` (declaration order)

File names: `ar.json` **or** country files `ar_EG.json` + `ar_SA.json`. Each
path is a distinct option (`==` uses code + country).

`LanguageModel.lookup` order:

1. exact `fullCode` (`ar_SA` → `ar_SA.json`)
2. language-only file (`ar` → `ar.json` if present)
3. first same-language country variant

Flutter still requires those JSON paths under `flutter.assets` in the
**host** `pubspec.yaml`.

`LanguageConfig.assetPathFor` prefers exact `fullCode`, then first path with
the same language code.

---

## 6. Flutter-specific rules

- Call `init` after `WidgetsFlutterBinding.ensureInitialized()` and
  **before** `runApp`.
- `LanguageBuilder` wraps `MaterialApp` / `MaterialApp.router` and passes
  `locale:` from the singleton.
- `localeResolutionCallback` order: exact country, language-only locale,
  first same language, then **`defaultLanguage.locale`** — not
  `supportedLocales.first`.
- Pass `AssetBundle` into `init` / `load` in tests. Widget tests that hit
  `rootBundle` for missing JSON **hang**; use a fake bundle.
- Runtime locale cannot be `const` on `MaterialApp.locale`.
- Do not `dispose()` the process singleton from a widget `dispose()`.
  Tests call `resetLanguage()` from `package:language/testing.dart`.

Domain may import `dart:ui` for `Locale`. Presentation may import
`material.dart` / `cupertino.dart` / `flutter_localizations`.

---

## 7. Error handling

| Situation | Type |
|---|---|
| Bad `ar.json` / `ar_EG.json` name | `InvalidLanguageFileNameException` |
| YAML missing as an asset | `MissingLanguageYamlException` |
| YAML malformed / empty `files` / unknown default | `InvalidLanguageYamlException` |
| `changeLanguage` before `init` | `LanguageNotInitializedException` |
| `changeLanguage` not in YAML `files` | `UnsupportedLanguageException` |
| JSON asset missing at runtime | empty map; `.tr` / `.trParams` returns the key |

Do not swallow errors with empty `catch` in orchestration. YAML load maps
any asset failure to `MissingLanguageYamlException`. JSON load returning
`null` from `AssetLanguageLoader` is the missing-file path.

---

## 8. Testing rules

- `setUp` / `tearDown` call `resetLanguage()` (testing library).
- Fake `LanguageStorage` and `LanguageChangeListener` — do not use
  SharedPreferences.
- Fake `AssetBundle` for YAML + JSON in widget tests and any `init` that
  loads translations.
- Cover: YAML default + files list, country variants (`ar_EG` vs `ar_SA`),
  storage restore, no-op `changeLanguage`, unsupported language, missing
  YAML, `.tr` fallback, `.trParams` substitution, `LanguageBuilder` rebuild, `resetLanguage()` →
  `und` / empty list.
- Package tests must not import `lib/` of the host app.
- Host tests of the app may import `package:language/testing.dart`;
  production `lib/` of the host must not.

---

## 9. Refactoring workflow (when changing this package)

Work in this order; keep behavior unless the task says otherwise.

1. **Structure** — file in the wrong layer? Split SRP violations.
2. **Catalog** — no new `Language.en` / enum of languages; YAML `files`
   only.
3. **Naming** — YAML keys, ports, `changeLanguage`, `fullCode`.
4. **Guards** — init-not-called, invalid YAML, invalid file names,
   unsupported language.
5. **DIP** — any new `if (storageType == …)` becomes a new host adapter.
6. **Lookup** — change `LanguageModel.lookup` once; YAML and `fromCode`
   share it.
7. **Tests** — reset singleton; fake bundle for widgets.
8. **Barrel** — export only the new public type, if it is public.
9. **GUIDE.md** — update host snippets when the public API changes.

---

## 10. Quick checklist

| Check | Pass |
|---|---|
| No Bloc / Equatable / prefs in `pubspec.yaml` | |
| Mutable language state is on the singleton, not `static` | |
| No `Language.en` / `.ar`; options from YAML `files` | |
| Country variants stay distinct (`ar_EG` ≠ `ar_SA`) | |
| Host implements `LanguageStorage` + `LanguageChangeListener` | |
| Widgets do not parse YAML or JSON | |
| YAML `default_language` and `files` drive runtime config | |
| `init` before `runApp`; `resetLanguage` in tests only; no singleton `dispose()` | |
| `changeLanguage` throws if not in `supportedLanguages` | |
| Ports stay small; adapters live in the host | |
| Public barrel did not grow without need | |
| No `LanguageController` / second source of truth for `_current` | |
