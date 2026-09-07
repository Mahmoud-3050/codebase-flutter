# Generate — Flutter Code Generation Toolkit

> A Dart-based CLI toolkit that auto-generates Flutter boilerplate code following **Clean Architecture**, manages **localization strings**, and provides **project-wide code fix scripts**.

---

## 🧠 Why This Tool? (Instead of Packages)

### The Problem

Flutter's Clean Architecture involves writing **massive amounts of boilerplate** for every feature: entities, models with `fromJson`, use cases, repositories (abstract + implementation), datasources, cubits, states, and dependency injection. For a single API endpoint, a developer typically creates **8–10 files** with repetitive patterns.

The Flutter ecosystem offers packages like **freezed**, **json_serializable**, and **build_runner** to reduce some of this. However, they solve only a *fraction* of the problem and introduce their own overhead.

### What This Tool Replaces

This generate tool is a **zero-dependency, self-contained alternative** that replaces:

| What Packages Typically Handle | Package(s) | What This Tool Does Instead |
|---|---|---|
| JSON → Dart model (`fromJson`/`toJson`) | `json_serializable` + `json_annotation` | Generates models directly from a sample JSON response — no annotations needed |
| Immutable classes, `copyWith`, `==`, `hashCode` | `freezed` + `freezed_annotation` | Generates Equatable entities with `copyWith` and `props` out-of-the-box |
| Code generation runner | `build_runner` | Runs as a simple `dart` CLI script — no build system integration needed |
| Feature scaffolding | Manual / custom scripts | Generates the **entire** Clean Architecture feature structure in one command |
| Cubit/Bloc boilerplate | Manual | Generates Cubit + States files per request |
| Dependency injection wiring | Manual | Generates injection file that registers all repos, datasources, cubits |
| Localization key management | `easy_localization`, `intl`, `slang` | Generates GetX `.tr` string class + appends to `en.json`/`ar.json` |
| Code lint fixes | Individual lint rules | Automated scripts for `print→log`, `dispose`, `withOpacity`, unused assets |

### Key Philosophy

1. **No `build_runner`** — No slow `flutter pub run build_runner build` cycles. Generation is instant via a single `dart` command.
2. **No annotations** — No `@JsonSerializable()`, `@freezed`, or `part` directives polluting source code.
3. **No extra dependencies** — Zero packages added to `pubspec.yaml`. The generator lives outside `lib/` and has no runtime footprint.
4. **Full-feature scope** — Unlike `freezed`/`json_serializable` which only handle models, this tool generates the *entire* feature across all Clean Architecture layers in one shot.
5. **JSON-driven** — Just paste a real API response into a JSON config file and run one command. The tool infers Dart types, handles nested models, lists, and nullability automatically.

---

## 📊 Detailed Comparison

### vs. `json_serializable` + `json_annotation`

| Aspect | `json_serializable` | This Tool |
|---|---|---|
| **Setup** | Add 3 packages (`json_serializable`, `json_annotation`, `build_runner`) to `pubspec.yaml` | No packages — just a `generate/` folder in the project |
| **Input** | Write the Dart class manually, annotate with `@JsonSerializable()`, add `part` file | Paste a sample JSON API response into a `.json` config file |
| **Run** | `dart run build_runner build` (slow, processes entire project) | `dart generate/features/main.dart auth` (instant, targets one feature) |
| **Output** | Only `fromJson`/`toJson` in a `.g.dart` file | Full model + entity + usecase + cubit + datasource + repo + injection |
| **Type inference** | Manual — you write every field type | Automatic — inferred from JSON values (`int`, `String`, `List<Model>`, nested objects) |
| **Nested models** | Must manually create each nested class | Automatically generates sub-model classes from nested JSON objects |
| **Runtime dependency** | `json_annotation` remains in production code | Zero runtime dependency |
| **Build conflicts** | Frequent `build_runner` version conflicts with other generators | No conflicts — standalone script |

### vs. `freezed` + `freezed_annotation`

| Aspect | `freezed` | This Tool |
|---|---|---|
| **Purpose** | Immutable data classes with `copyWith`, `==`, `toString`, union types | Equatable entities + data models + entire feature scaffolding |
| **Setup** | Add 3 packages + configure `build_runner` | No packages |
| **Annotations** | `@freezed`, `@Default`, `@JsonKey` in every class | None — configuration is in external JSON files |
| **Generated code location** | `.freezed.dart` + `.g.dart` files alongside source (clutters `lib/`) | Clean output directly into the Clean Architecture folder structure |
| **Union types / sealed classes** | ✅ Excellent support | ❌ Not supported (not needed for API models) |
| **Rebuild time** | Slow — `build_runner` scans entire project | Instant — single dart script execution |
| **Learning curve** | Moderate (annotations, union syntax, `when`/`map`) | Low (just fill in a JSON template) |
| **IDE support** | Requires generated code to exist for autocomplete | Generated code is plain Dart — works immediately |

### vs. `build_runner`

| Aspect | `build_runner` | This Tool |
|---|---|---|
| **Execution time** | 10–60+ seconds (scans all `lib/` files) | < 1 second per feature |
| **Scope** | Processes every annotated file in the project | Targets only the specified feature |
| **Conflict risk** | Version conflicts between `freezed`, `json_serializable`, `auto_route`, `injectable`, etc. | Zero conflicts — no shared build system |
| **Watch mode** | `build_runner watch` (resource-heavy) | Not needed — run on demand |
| **Cache issues** | Frequent `build_runner clean` needed | No cache, no stale state |

### vs. `easy_localization` / `intl` / `slang`

| Aspect | Localization Packages | This Tool's String Generator |
|---|---|---|
| **Setup** | Package installation + configuration + code generation | Single `dart generate/strings/main.dart` command |
| **Workflow** | Edit ARB/JSON files → run generator → use in code | Edit `lang.json` → run one command → both translation JSONs + Dart class updated |
| **Output** | Varies (ARB, generated Dart, etc.) | Clean `Strings` class with static getters using GetX `.tr` |
| **Framework coupling** | Some are framework-specific | Designed for GetX but the JSON files are framework-agnostic |

### Summary Table

| Feature | `json_serializable` | `freezed` | `build_runner` | **This Tool** |
|---|:---:|:---:|:---:|:---:|
| JSON → Model | ✅ | ✅ | — | ✅ |
| `copyWith` | ❌ | ✅ | — | ✅ |
| Equality (`==` / `props`) | ❌ | ✅ | — | ✅ |
| Entity (domain layer) | ❌ | ❌ | — | ✅ |
| Use Case generation | ❌ | ❌ | — | ✅ |
| Repository + Impl | ❌ | ❌ | — | ✅ |
| Datasource generation | ❌ | ❌ | — | ✅ |
| Cubit + States | ❌ | ❌ | — | ✅ |
| Dependency Injection | ❌ | ❌ | — | ✅ |
| Localization | ❌ | ❌ | — | ✅ |
| Code fix automations | ❌ | ❌ | — | ✅ |
| Zero runtime deps | ❌ | ❌ | — | ✅ |
| No `build_runner` | ❌ | ❌ | N/A | ✅ |
| Instant execution | ❌ | ❌ | ❌ | ✅ |
| Union/sealed types | ❌ | ✅ | — | ❌ |
| `toJson` | ✅ | ✅ | — | ❌ (entity-only) |

### When to Use What

- **Use `freezed`** if you need union types, sealed classes, or pattern matching (`when`/`map`).
- **Use `json_serializable`** if you're in a project that already uses `build_runner` heavily and just need `fromJson`/`toJson` on a few models.
- **Use this tool** if you're building features with Clean Architecture and want to go from *"here's my API response"* to *"here's a fully scaffolded feature"* in seconds, with zero package overhead.

---

## 📁 Folder Structure

```
generate/
├── features/          # Feature code generator (Clean Architecture)
│   ├── main.dart      # Entry point
│   ├── models/        # Internal data models (Feature, Request, Names, etc.)
│   ├── modes/         # Generation strategies (generate / modify)
│   └── files/         # File & buffer templates for each architectural layer
├── fix/               # Automated code fix scripts
├── requests/          # JSON config files that define API features
│   ├── auth/          # Example: auth feature with login, register, etc.
│   ├── common/
│   ├── profile/
│   └── temp/
├── strings/           # Localization string generator
│   ├── main.dart      # Entry point
│   └── lang.json      # Input: new translation keys
└── utils/             # Shared utilities (constants, enums, name helpers)
```

---

## 1. Feature Generator (`generate/features/`)

### What It Does

Generates a complete **Clean Architecture** feature module from JSON API definitions. A single command scaffolds:

| Layer | Generated Files |
|---|---|
| **Domain → Entities** | `*_response.dart` (Equatable entity with `copyWith` & `props`) |
| **Domain → Use Cases** | `*_usecase.dart` |
| **Domain → Repository** | `*_repo.dart` (abstract interface) |
| **Data → Models** | `*_model.dart` (extends entity, with `fromJson`) |
| **Data → Datasource** | `*_remote_datasource.dart` |
| **Data → Repository Impl** | `*_repo_impl.dart` |
| **Presentation → Cubit** | `*_cubit.dart` (cubit + sealed states in one file) |
| **DI** | `*_injection.dart` |

### How to Run

```bash
dart generate/features/main.dart <feature_name>
```

Example: `dart generate/features/main.dart auth`

### How It Works

1. Reads the feature name from CLI args.
2. Locates JSON config files in `generate/requests/<feature_name>/`.
3. Reads **two independent modes**:
   - **Feature mode** from `generate/requests/<feature>/settings.json`
   - **Request mode** from each `*_request.json`
4. For each request JSON, it parses models, endpoints, params, and response structure.
5. Generates Dart files using `StringBuffer`-based templates.
6. After a request is generated or modified, that request's `mode` is set to `0` (protected). Deleted requests stay at `mode: 3` as a tombstone. Feature `settings.json` is set to `0` after a full **generate** run.

### Feature mode (`settings.json`)

| `mode` | Meaning |
|---|---|
| `0` | **Protected** — the generator refuses to run |
| `1` | **Generate** — create the feature directory tree and all **active** request files from scratch |
| `2` | **Modify** — apply per-request modes on an existing feature (add / overwrite / delete). Protected requests are not rewritten |
| `3` | **Delete-only** — process request `mode: 3` tombstones and rewrite aggregate files |

### Request mode (`*_request.json`)

Request `mode` is **not** the feature mode. It is ignored unless the feature is allowed to run (`settings.json` is 1, 2, or 3).

| `mode` | Meaning |
|---|---|
| `0` | **Protected** — leave this request's entity/model/usecase/cubit files untouched. Still included in datasource/repo/injection |
| `1` | **Generate** — create this request's files (add a request to an existing feature, or include it in a new feature) |
| `2` | **Modify** — overwrite this request's entity/model/usecase/cubit from the JSON |
| `3` | **Delete** — delete generated files for this request; leave the JSON as a tombstone. Excluded from aggregate files |

### Modify-feature cases (`settings.json` → `2`)

Existing requests stay at `mode: 0`. Only the requests you intend to change get 1, 2, or 3.

**Add request(s)** — existing `0`, new request(s) `1`, feature `2`:
creates files for the new requests, then rewrites datasource/repo/injection to include them.

**Delete request(s)** — existing `0`, delete request(s) `3`, feature `2`:
deletes those request files, then rewrites aggregates without them.

**Modify request(s)** — existing `0`, changed request(s) `2`, feature `2`:
overwrites those request files, then rewrites aggregates. Other request files are not touched.

A single modify run may mix all three (some `1`, some `2`, some `3`, the rest `0`). If every request is `0`, the generator exits without rewriting files.

### JSON Request Config Format

Each JSON file in `generate/requests/<feature>/` defines one API request:

```json
{
  "name": "login",
  "model_class": "Student",
  "endpoint": "/common/login",
  "type": "POST",
  "token": false,
  "params": {
    "login": "123456789",
    "password": "1111",
    "image": "avatar.png"
  },
  "param_types": {
    "image": "file"
  },
  "response": {
    "status": "success",
    "data": {
      "id": 97,
      "first_name": "Alice",
      "birthdate": "1995-08-24",
      "created_at": "2024-10-18 10:48:37",
      "class_name$company": "Company",
      "company": {
        "id": 1,
        "name": "Acme"
      },
      "class_name$items": "Item",
      "items": [
        { "id": 1, "title": "One" }
      ],
      "type$note": "String",
      "note": "keep as String even if it looks like a date"
    },
    "message": "api.login successfully"
  },
  "mode": 1
}
```

| Field | Description |
|---|---|
| `name` | Request name (used for file naming / class naming) |
| `model_class` | Optional data class name. The generator looks for that class under `lib/shared/domain/entities` (see Shared entities). If found, the local entity is skipped and the per-request model extends the shared entity. If not found, the class is generated locally as usual. Defaults to `<name>_data` when omitted (no shared lookup). |
| `endpoint` | API endpoint path |
| `type` | HTTP method: `GET`, `POST`, `PUT`, `PATCH`, `DELETE` |
| `token` | Whether the request requires authentication |
| `params` | Request parameters (sample JSON shape used to generate the use case Params class) |
| `param_types` | Optional map of param key → `"file"` or `"image"`. Those params become `File?` and the datasource sends `FormData` instead of a JSON body. |
| `response` | Sample API response — `data` structure is used for entity/model generation. If `pagination` is present (see Paginated lists), the cubit extends `PaginationCubit`. |
| `class_name$<field>` | Sibling meta-key in any response object. Forces the Dart class name for that nested object or list item (instead of deriving it from the key / stripping a trailing `s`). Stripped out of generated fields. |
| `type$<field>` | Sibling meta-key. Forces the Dart type (`DateTime` or `String`) over the DateTime naming heuristic. |
| `mode` | `0`=protected, `1`=generate (add / create files), `2`=modify (overwrite this request's files), `3`=delete. Independent of `settings.json`. |

### DateTime fields

String fields are generated as `DateTime?` when:

1. An explicit `type$<field>: "DateTime"` override is present, **or**
2. The JSON key ends with `_at`, `_date`, or contains `date` (case-insensitive)

Use `type$<field>: "String"` to keep a field as `String` when the heuristic would otherwise pick DateTime. Parsing uses `toDateTimeOrNull()` from `lib/core/utils/extensions.dart`.

### Shared entities (`model_class`)

Path is configured in `generate/utils/constants.dart`:

```dart
static const String sharedEntitiesPath = 'lib/shared/domain/entities';
```

On each run the generator scans that folder for `class <ModelClass>`. Promoting a model to shared is **manual**: move the entity file into that folder. The next generate/modify run will import it instead of emitting a local copy. Per-request `{Name}Response` / `{Name}Model` wrappers always stay in the feature. Shared entity files are never deleted by delete mode.

### File / image uploads

```json
"params": { "title": "cv", "file": "cv.pdf" },
"param_types": { "file": "file" }
```

Generates `File? file` on Params, a `toFormData()` method, and `dioConsumer.post(..., formData: params.toFormData())` in the datasource.

### Paginated lists (`response.pagination`)

When the sample `response` contains a `pagination` object **and** `data` is a list, the generator wires the shared pagination stack instead of a one-shot cubit:

```json
{
  "name": "getJobs",
  "model_class": "Job",
  "endpoint": "/jobs",
  "type": "GET",
  "params": {
    "search": ""
  },
  "response": {
    "status": "success",
    "data": [{ "id": 1, "title": "Engineer" }],
    "pagination": {
      "total": 100,
      "count": 10,
      "per_page": 10,
      "current_page": 1,
      "total_pages": 10
    },
    "message": "ok"
  },
  "mode": 1
}
```

| Generated piece | Behavior |
|---|---|
| **Entity** | `PaginationMeta pagination` on `{Name}Response` (`pagination_entity.dart`). Nested `Pagination` classes are not generated. |
| **Model** | `PaginationMetaModel.fromJson` (`pagination_model.dart`). |
| **Params** | Always generated. Adds `page` and `per_page` if they are missing from `params`. Extra filters (e.g. `search`) stay on Params and as cubit fields. |
| **Datasource** | GET requests send `queryParameters: params.toJson()` (includes `page` / `per_page`). |
| **Cubit** | Extends `PaginationCubit<Item>`. Implements `fetchPage` only — no sealed `{Name}State` in the cubit file. Call `fLoadFirstPage` / `fRefresh` / `fLoadNextPage`. |
| **Widget** | `{Name}Consumer` uses `PaginationWidget<{Name}Cubit, Item>`. |

`pagination` keys match `PaginationMetaModel`: `total`, `count`, `per_page`, `current_page`, `total_pages`.

### Form errors (`response.errors`)

Server validation errors belong on `Failure`, not on generated entities. Envelope `errors` is skipped when generating `{Name}Response` / `{Name}Model` (no nested `Errors` class).

`lib/core/api` maps failed bodies to `ValidationException` / `ValidationFailure` with `fieldErrors`:

| `errors` shape | Result |
|---|---|
| `{ "email": ["taken"] }` or `{ "email": "taken" }` | `fieldErrors['email']` |
| `[{ "field": "email", "message": "taken" }]` | `fieldErrors['email']` |
| `["email is taken"]` | `ValidationException` with message, empty `fieldErrors` |

HTTP **422**, **400 with `errors`**, and **200 + `status` ≠ success** with `errors` all go through `ApiResponse.exceptionOf` / the Dio mapper. Generated datasources `throw ApiResponse.exceptionOf(response)` when `ApiResponse.isSuccess` is false.

Cubits emit `ApiCallError.fromFailure` so `fieldErrors` reach the UI. Wrap a form in `FieldErrorsScope` and set `AppTextFormField.fieldName` (API key, e.g. `first_name`). Matching fields show the error inline; a snackbar is used only when `fieldErrors` is empty.

### Dependency injection

Generated `{feature}_injection.dart` does **not** register every request in one feature-wide scope. It emits:

- `register{Feature}DataLayer(GetIt sl)` — repository + datasource
- `register{Request}(GetIt sl)` — that request's cubit (`registerFactory`) and use case (`registerLazySingleton`)

Each navigation flow pushes its **own** named GetIt scope and lists only the registrations that screen needs. `FeatureScope` pushes the scope, runs those functions, and drops the scope on exit.

```dart
const String _studentProfileScopeName = 'StudentProfileScope';

FeatureScope(
  scopeName: _studentProfileScopeName,
  registrations: [
    registerProfileDataLayer,
    registerGetStudentProfile,
    registerUpdateStudentProfile,
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => ServiceLocator.instance<GetStudentProfileCubit>(),
      ),
      BlocProvider(
        create: (_) => ServiceLocator.instance<UpdateStudentProfileCubit>(),
      ),
    ],
    child: const StudentProfileScreen(),
  ),
)
```

A company-profile route would use a different `scopeName` and only `registerGetCompanyProfile` / `registerUpdateCompanyProfile`. Unused requests stay unregistered until their flow opens.

`ServiceLocator.init()` only registers core singletons.

### Delete mode

Set a request JSON `"mode": 3` and the feature `settings.json` `"mode": 2` (or `3` for a delete-only pass). The generator:

1. Logs and deletes that request's entity, model, usecase, cubit, states, and tests
2. Regenerates datasource / repository / injection **without** that request
3. Leaves the JSON file in place at `mode: 3` (tombstone). Delete the JSON yourself to forget it entirely
4. Never deletes a shared entity under `sharedEntitiesPath`

### Generated Directory Structure

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/     # Remote datasource
│   ├── models/          # Data models (fromJson)
│   └── repositories/    # Repository implementation
├── domain/
│   ├── entities/        # Equatable entities
│   ├── repositories/    # Abstract repository interface
│   └── usecases/        # Use cases
├── presentation/
│   ├── controller/      # Cubit + States
│   ├── pages/           # (empty, for UI)
│   └── widgets/         # (empty, for widgets)
└── <feature>_injection.dart   # Dependency injection setup
```

---

## 2. String / Localization Generator (`generate/strings/`)

### What It Does

Generates localization files from a simple key-value JSON input:
- Appends new keys to **every existing** `assets/lang/*.json` file (`en.json`, `ar.json`, and country files such as `ar_EG.json`, `ar_SA.json`, `ar_OM.json` if they exist). Missing files are not created.
- With `--d`, **removes** those keys from all of those JSON files.
- Regenerates a Dart `Strings` class at `lib/config/language/strings.dart` with `.tr` getters and `.trParams` methods (from `en.json`, or the first `en_*` file).

### How to Run

```bash
# Add new keys (append mode)
dart generate/strings/main.dart

# Delete mode
dart generate/strings/main.dart --d
```

### Input Format (`lang.json`)

Each entry is a key (or English sentence converted to a snake_case key) mapped
to an object of locale codes → strings. The generator writes into **existing**
`assets/lang/*.json` files only (`en_EG`, `en_SA`, `en_OM`, `ar_EG`, …).

**Language defaults** — every English file gets `en`, every Arabic file gets `ar`:

```json
{
  "choose_future_date_and_time": {
    "en": "Please choose a future date and time",
    "ar": "الرجاء اختيار تاريخ ووقت في المستقبل"
  }
}
```

**Country values** — listed locales get those strings. An omitted country file
uses the first entry of the same language (`en_OM` → first `en_*`):

```json
{
  "welcome": {
    "en_EG": "Welcome (Egypt)",
    "en_SA": "Welcome (Saudi)",
    "ar_EG": "أهلًا",
    "ar_SA": "هلا"
  }
}
```

**Language + country** — omitted files use `en` / `ar` when those keys exist
(they win over “first country”):

```json
{
  "welcome": {
    "en": "Welcome",
    "ar": "مرحبا",
    "en_EG": "Welcome (Egypt)",
    "ar_EG": "أهلًا"
  }
}
```

Lookup for a file stem: exact locale → `en` / `ar` → first same-language value
in the object → the outer key text.

**Placeholders** — `{identifier}` belongs in **values only**, never in the outer key:

```json
{
  "welcome": {
    "en": "welcome {username}",
    "ar": "مرحبا {username}",
    "ar_EG": "اهلا وسهلا {username}"
  },
  "counts_from": {
    "en": "{current} counts from {total}",
    "ar": "{current} عدد من {total}"
  }
}
```

Generated API uses required named `String` parameters:

```dart
Strings.welcome(username: 'Ahmed');
Strings.countsFrom(current: '10', total: '20');
```

- Dart reserved keywords are automatically skipped.
- Keys ending with `_` are treated as special suffixes.

### Output

**`assets/lang/*.json`** — translations appended or removed on each existing file.  
**`lib/config/language/strings.dart`** — Generated Dart class:

```dart
import 'package:language/language.dart';

abstract class Strings {
  static String get chooseFutureDateAndTime => 'choose_future_date_and_time'.tr;

  static String welcome({required String username}) =>
      'welcome'.trParams({'username': username});
}
```

---

## 3. Fix Scripts (`generate/fix/`)

Four standalone Dart scripts for project-wide automated code fixes:

### 3.1 `fix_print_statements.dart`

Replaces all `print()` and `debugPrint()` calls with `log()` from `dart:developer` across the `lib/` folder. Automatically adds the `import 'dart:developer';` import if missing.

```bash
dart generate/fix/fix_print_statements.dart
```

### 3.2 `fix_textcontroller_and_focusnode_dispose.dart`

Scans all Dart files in `lib/` for `TextEditingController()` and `FocusNode()` declarations and automatically adds `.dispose()` calls to a `dispose()` method. Creates the `dispose()` override if it doesn't exist.

```bash
dart generate/fix/fix_textcontroller_and_focusnode_dispose.dart
```

### 3.3 `fix_withopacity.dart`

Replaces deprecated `.withOpacity(x)` calls with `.withValues(alpha: x)` across all Dart files in `lib/`.

```bash
dart generate/fix/fix_withopacity.dart
```

### 3.4 `unused_assets_finder.dart`

Analyzes the `Assets` class (`lib/core/manager/assets.dart`) and reports which asset constants are unused in the project. Optionally deletes the unused asset files.

```bash
# Report only
dart run generate/fix/unused_assets_finder.dart

# Delete unused assets
dart run generate/fix/unused_assets_finder.dart --delete

# Delete from specific folders only
dart run generate/fix/unused_assets_finder.dart --delete --folders=images,svg,lottie
```

---

## 4. Router Generator (`generate/router/`)

### What It Does

Automatically adds new type-safe routes to a feature's navigation system. This script:
- Adds a new route constant to `lib/config/routes/app_routes.dart`.
- Appends a `@TypedGoRoute` and `GoRouteData` class to the feature's `router.dart`.
- Adds a **per-screen** `BuildContext` navigation extension (`go` / `push`).
- When `"scopes"` is set, wraps the screen in `FeatureScope` + `MultiBlocProvider` for that flow.
- Runs `build_runner` to generate the matching code.

### How to Run

1. Edit `generate/router/router.json` with your screen details.
2. Run the generator:
```bash
dart generate/router/main.dart
```

### JSON Config Format (`router.json`)

Unscoped route (splash-style — no GetIt scope):

```json
{
  "feature": "splash",
  "screen": "SplashScreen",
  "route": "splash"
}
```

Scoped navigation flow (profile-style — registers only what that screen needs):

```json
{
  "feature": "profile",
  "screen": "StudentProfileScreen",
  "route": "studentProfile",
  "scopes": ["getStudentProfile", "updateStudentProfile"]
}
```

`"scopes"` is optional. Each entry is a request name. The generator always prepends `register{Feature}DataLayer`, then `register{Request}` + a `BlocProvider` for `{Request}Cubit`. Omit `"scopes"` (or use `[]`) for screens that should not push a GetIt scope.

Optional `"args"` still become route/screen constructor fields.

---

## 5. Utilities (`generate/utils/`)

Shared Dart utilities used by the generators:

| File | Purpose |
|---|---|
| `constants.dart` | Terminal color codes, file path constants |
| `enums.dart` | `ModeType` (generate/modify/protected/delete), `RequestType` (HTTP methods), `DartType` (type inference) |
| `exceptions.dart` | Custom `NamesException` and `DartTypeException` |
| `extension.dart` | Extensions: `RequestType.fromString()`, `DartType.fromType()`, `DartType.typeName()`, `List.lineContains()` |
| `functions.dart` | Helpers: `capitalizeFirstChar()`, `createFile()`, `createDirectory()`, `getDartType()`, `getDataKeys()` |
| `generate_used_func.dart` | Legacy/duplicate helper functions (mostly commented out) |
| `names_helper.dart` | Name case conversion: `toSnakeCase()`, `snakeToCamelCase()`, `camelToClassCase()`, etc. |

---

## 6. Key Internal Models

| Model | File | Role |
|---|---|---|
| `Feature` | `features/models/feature.dart` | Represents a feature module (name, requests, settings, mode) |
| `Request` | `features/models/request.dart` | Represents a single API request with endpoint, params, response |
| `Names` | `features/models/names.dart` | Holds all case variants of a name (snake, camel, class, original) |
| `Settings` | `features/models/settings.dart` | Feature-level settings (mode flag) |
| `Endpoint` | `features/models/endpoint.dart` | API endpoint metadata |
| `GenerateModel` | `features/models/generate_model.dart` | Generates entity & model classes from JSON response maps |
| `Layer` / `SubLayer` | `features/models/layer.dart`, `sub_layer.dart` | Represents Clean Architecture directory structure |
| `RequestBuffers` | `features/models/request_buffers.dart` | Holds string buffers for all generated layers |
| `RequestFiles` | `features/models/request_files.dart` | Holds file references for generated files (entity, model, cubit, etc.) |

---

## Quick Reference

| Task | Command |
|---|---|
| Generate a new feature | Feature `settings.json` → `"mode": 1`, request JSONs → `"mode": 1`, then `dart generate/features/main.dart <feature_name>` |
| Add requests to existing feature | Feature `settings.json` → `"mode": 2`, existing requests → `"mode": 0`, new request JSONs → `"mode": 1` |
| Modify requests in existing feature | Feature `settings.json` → `"mode": 2`, existing requests → `"mode": 0`, changed request JSONs → `"mode": 2` |
| Delete requests from existing feature | Feature `settings.json` → `"mode": 2`, existing requests → `"mode": 0`, removed request JSONs → `"mode": 3` |
| Add translation strings | Edit `generate/strings/lang.json`, then `dart generate/strings/main.dart` |
| Add a profile route | Edit `generate/router/router.json`, then `dart generate/router/main.dart` |
| Replace `print` → `log` | `dart generate/fix/fix_print_statements.dart` |
| Auto-add `.dispose()` | `dart generate/fix/fix_textcontroller_and_focusnode_dispose.dart` |
| Fix `withOpacity` deprecation | `dart generate/fix/fix_withopacity.dart` |
| Find unused assets | `dart run generate/fix/unused_assets_finder.dart` |
