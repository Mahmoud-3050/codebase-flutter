# language

Host how-to for this localization package. Design rules for changing the
package live in `RULES.md`.

The package has **no** Bloc, Equatable, or persistence plugins. Dependencies
are Flutter SDK, `flutter_localizations`, and `yaml`. The host supplies
storage and side effects through two ports: `LanguageStorage` and
`LanguageChangeListener`.

## Public API

Import `package:language/language.dart`. That barrel exports:

| Type | Role |
|---|---|
| `Language.instance` | singleton: `init`, `changeLanguage`, current locale |
| `LanguageModel` | one language (`code`, optional `countryCode`, `nativeName`) |
| `LanguageStorage` / `InMemoryLanguageStorage` | persist last code |
| `LanguageChangeListener` | host side effects on change |
| `LanguageBuilder` | rebuild `MaterialApp` when locale changes |
| `LanguageLocalizations` + `'key'.tr` | string lookup |
| `LanguageLocalizationsSetup` | `supportedLocales`, delegates, resolution |
| Exceptions | YAML, file names, init, unsupported language |

`LanguageConfig`, `LanguageYamlLoader`, `LanguageFileParser`, and
`AssetLanguageLoader` are **not** exported. Tests may import them from
`package:language/src/…`.

There are **no** `Language.en` / `Language.ar` constants. Options come
from YAML `files` via `Language.instance.supportedLanguages`.
`LanguageModel.en` / `.ar` exist as value aliases (tests / native names),
not as the selectable catalog.

## 1. Add the package

```yaml
# pubspec.yaml
dependencies:
  language:
    path: ./packages/language   # or your path / git URL
```

## 2. Declare translation JSON files

Create `language.yaml` at the **host project root**. JSON file names must
match `ar.json` or `ar_EG.json` (2–3 lowercase letters, optional `_` + two
uppercase country letters).

Each path is its own selectable language. You can use language-only files,
country variants of the same language, or both.

```yaml
# Language-only files
default_language: ar

files:
  - assets/lang/en.json
  - assets/lang/ar.json
```

```yaml
# Country variants (Egyptian vs Saudi Arabic)
default_language: ar_EG

files:
  - assets/lang/en.json
  - assets/lang/ar_EG.json
  - assets/lang/ar_SA.json
```

- Omit `default_language` to use the **first** entry in `files`.
- `default_language: ar` with only `ar_EG` / `ar_SA` selects the first Arabic
  file. Prefer `ar_EG` when the default country matters.
- Lookup (`fromCode`, `default_language`): exact `fullCode` (`ar_SA`), then
  language-only (`ar.json`), then the first same-language country file.
- Stored locale is **not** fuzzy: it must equal a file stem (`ar` or `ar_EG`).

Register the YAML file and the JSON folders:

```yaml
# pubspec.yaml
flutter:
  assets:
    - language.yaml
    - assets/lang/
```

JSON files are flat string maps. Missing keys: `'some_key'.tr` returns
`some_key`.

## 3. Implement `LanguageStorage` (persist locale)

The package stores the JSON **file stem**, which must match a `files` entry:
`ar.json` → `'ar'`, `ar_EG.json` → `'ar_EG'`. On `init`, a stored value is
accepted only when it exactly matches a declared file (same grammar as the
file name, without `.json`). `AR`, `ar-EG`, `ar_eg`, or `'ar'` when only
`ar_EG.json` exists are ignored and the default language is used. First
launch must return `null`, not throw.

```dart
import 'package:language/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLanguageStorage implements LanguageStorage {
  const SharedPreferencesLanguageStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'languageCode';

  @override
  Future<String?> getLanguageCode() async => _prefs.getString(_key);

  @override
  Future<void> saveLanguageCode(String code) async {
    await _prefs.setString(_key, code);
  }
}
```

If you omit `storage` in `init`, the package uses `InMemoryLanguageStorage`
(lost when the process dies).

## 4. Implement `LanguageChangeListener` (host side effects)

Keep Dio headers, validator locales, analytics, etc. **out of `main()`** and
**out of widgets**. Implement the port in the host:

```dart
import 'package:language/language.dart';
import 'package:field_validator/field_validator.dart';

class LanguageChangeAdapter implements LanguageChangeListener {
  const LanguageChangeAdapter({required this.dioConsumer});

  final DioConsumer dioConsumer;

  @override
  void onLanguageChanged(LanguageModel language) {
    FieldValidator.instance.setLocale(
      ValidatorLocale.fromCode(language.code),
    );
    dioConsumer.updateLanguageCodeHeader();
  }
}
```

`onLanguageChanged` runs:

- once at the end of `Language.instance.init` (restored or default)
- after every **successful** `changeLanguage` (not on no-op / not-initialized)

Use `language.fullCode` for `Accept-Language` when country variants exist.

## 5. Call `Language.instance.init` in `main()`

After `WidgetsFlutterBinding.ensureInitialized()`, and after constructing
storage / listener dependencies. **Before** `runApp`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // … other host setup (DI, Firebase, …)

  await Language.instance.init(
    storage: SharedPreferencesLanguageStorage(prefs),
    listener: LanguageChangeAdapter(dioConsumer: dioConsumer),
  );

  runApp(const App());
}
```

`changeLanguage` throws `LanguageNotInitializedException` if `init` has not
run.

## 6. Rebuild the app when the locale changes

Wrap `MaterialApp` / `MaterialApp.router` with `LanguageBuilder`. Pass
`locale` through so directionality and localizations update.

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageBuilder(
      builder: (context, language, locale) {
        return MaterialApp.router(
          locale: locale,
          supportedLocales: LanguageLocalizationsSetup.supportedLocales,
          localeResolutionCallback:
              LanguageLocalizationsSetup.localeResolutionCallback,
          localizationsDelegates: LanguageLocalizationsSetup.localizationsDelegates,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
```

Do **not** `dispose()` `Language.instance` from a widget. There is no host
`reset` API; tests import `package:language/testing.dart`.

Locale resolution: exact country (`ar_SA`), then language-only (`ar`), then
the first `ar_*`, then `defaultLanguage` — not `files.first`.

## 7. Translate strings and switch language

```dart
Text('welcome_message'.tr);

final languages = Language.instance.supportedLanguages;
await Language.instance.changeLanguage(languages.first);

await Language.instance.changeLanguage(
  Language.instance.fromCode('ar_EG'),
);
```

Pass a model from `supportedLanguages` (or `fromCode` / `fromLocale`, which
resolve against that list). Anything else throws
`UnsupportedLanguageException`.

| Accessor | Meaning |
|---|---|
| `Language.instance.current` | current `LanguageModel` |
| `currentLocale` / `currentCode` | `Locale` / `fullCode` (`ar_EG`) |
| `isArabic` / `isEnglish` | based on language `code` |
| `context.currentLanguage` | same as `current` |
| `context.currentLocale` | current `Locale` |
| `context.currentLanguageCode` | current `fullCode` |
| `context.isArabic` / `context.isEnglish` | same as the singleton |

## Setup checklist

| Step | What |
|---|---|
| `language.yaml` at project root | `default_language` (optional) + `files` |
| `pubspec.yaml` assets | YAML + JSON folders |
| `LanguageStorage` impl | `getLanguageCode` / `saveLanguageCode` |
| `LanguageChangeListener` impl | host side effects only |
| `await Language.instance.init(...)` | before `runApp` |
| `LanguageBuilder` around `MaterialApp` | supplies `locale` |

## Optional `init` arguments

| Parameter | Default | Purpose |
|---|---|---|
| `storage` | `InMemoryLanguageStorage()` | persist last locale |
| `listener` | `null` | host side effects |
| `yamlAssetName` | `'language.yaml'` | override YAML asset path |
| `bundle` | `rootBundle` | tests / custom `AssetBundle` |
| `config` | loaded from YAML | skip YAML (tests) |

## Exceptions

| When | Type |
|---|---|
| JSON file name is not `ar.json` / `ar_EG.json` | `InvalidLanguageFileNameException` |
| YAML asset missing from host `pubspec` | `MissingLanguageYamlException` |
| YAML not a map, empty `files`, unknown default | `InvalidLanguageYamlException` |
| `changeLanguage` before `init` | `LanguageNotInitializedException` |
| `changeLanguage` with a model not in `files` | `UnsupportedLanguageException` |
| Translation JSON missing at runtime | empty map; `.tr` returns the key |
