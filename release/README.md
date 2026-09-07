# Release automation (Fastlane)

All Play Store / TestFlight automation lives in this folder.

```text
release/
├── deploy.config.example   # copy to deploy.config (gitignored)
├── Gemfile
├── README.md
├── secrets/                # keystore, Play JSON, App Store .p8 (gitignored)
├── scripts/
│   ├── deploy.sh
│   ├── test.sh
│   ├── hooks/pre_build.example.sh
│   └── lib/common.sh
├── test/                   # ruby MiniTest + bash config checks
└── fastlane/
    ├── shared/             # version + flavor helpers
    ├── android/            # Fastfile, Appfile
    └── ios/                # Fastfile, Appfile
```

```bash
cp release/deploy.config.example release/deploy.config
# Set GOOGLE_PLAY_TRACK to internal or production, then:
bash release/scripts/deploy.sh
```

`release/deploy.config` is gitignored. Never commit it.

## How it works

1. Load and validate `release/deploy.config`.
2. `flutter analyze` and `flutter test` (toggle with `RUN_ANALYZE` / `RUN_TESTS`).
3. Query Google Play and App Store Connect for the latest build numbers.
4. Write `version: x.y.z+build` back into `pubspec.yaml`. If the App Store
   marketing version is locked (`READY_FOR_SALE`, `WAITING_FOR_REVIEW`,
   `IN_REVIEW`, `PENDING_DEVELOPER_RELEASE`, …), the patch number is bumped.
   The build number always increases globally (`max + 1`) because Android
   `versionCode` cannot go backwards.
5. Generate `android/key.properties` from the keystore keys in `deploy.config`.
6. Run optional pre-build hooks (`PRE_BUILD_SCRIPT`, then the platform-specific
   script) immediately before each AAB / IPA build.
7. Build and upload Android (AAB) to `GOOGLE_PLAY_TRACK` and, on macOS, iOS (IPA).

On Linux the scripts set `SKIP_IOS_BUILD` and skip the IPA with a warning.
App Store Connect API calls for version lookup still run from Linux; only
archiving and codesign need a Mac. Set `SKIP_IOS="true"` to skip iOS
completely, including store version queries.

## Flavored vs non-flavored apps

This repo uses flavors (`dev` / `live`) and `lib/main_dev.dart` /
`lib/main_live.dart`. `deploy.config.example` is already filled in for `live`.
Switch `FLAVOR`, `ENTRYPOINT`, `IOS_SCHEME`, and `IOS_CONFIGURATION` when you
want to ship `dev` instead.

For a Flutter app **without** flavors, the same script and Fastfiles work
unchanged. In `deploy.config`:

```bash
USES_FLAVORS="false"
FLAVOR=""
ENTRYPOINT="lib/main.dart"
IOS_SCHEME="Runner"
IOS_CONFIGURATION="Release"
GOOGLE_PLAY_TRACK="internal"
```

`fastlane/shared/flutter_build.rb` is the only place that branches on flavors.
It also picks the correct AAB path:

- flavored: `build/app/outputs/bundle/liveRelease/app-live-release.aab`
- non-flavored: `build/app/outputs/bundle/release/app-release.aab`

## Pre-build scripts

Set these in `deploy.config` to run a script immediately before `flutter build`
(AAB) or `build_app` (IPA). Leave them empty to skip.

| Key | When it runs |
| --- | --- |
| `PRE_BUILD_SCRIPT` | Before every platform artifact |
| `ANDROID_PRE_BUILD_SCRIPT` | Before the AAB only (after the shared script) |
| `IOS_PRE_BUILD_SCRIPT` | Before the IPA only (after the shared script) |

Relative paths are resolved under `release/` first, then the Flutter project
root. The hook runs from the project root with two arguments
(`internal|production` and `android|ios`) plus `DEPLOY_TRACK` /
`DEPLOY_PLATFORM` in the environment. A non-zero exit aborts the deploy.

```bash
PRE_BUILD_SCRIPT="scripts/hooks/pre_build.example.sh"
ANDROID_PRE_BUILD_SCRIPT=""
IOS_PRE_BUILD_SCRIPT=""
```

Copy `release/scripts/hooks/pre_build.example.sh` and point the keys at your
real script (Firebase swap, codegen, downloading remote config, and so on).

## Secrets and credentials

Put files under `release/secrets/` (gitignored). Paths in `deploy.config`
are relative to `release/`.

| Key | What to put there |
| --- | --- |
| `GOOGLE_PLAY_TRACK` | `internal` or `production` |
| `GOOGLE_PLAY_PACKAGE_NAME` | Android application id |
| `GOOGLE_PLAY_JSON_KEY` | Play Console service account JSON with Release manager access |
| `GOOGLE_PLAY_RELEASE_STATUS` | `draft` (review in Play Console) or `completed` |
| `ANDROID_KEYSTORE_PATH` / `_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | Upload keystore. `android/key.properties` is generated at build time — do not maintain it by hand |
| `IOS_TEAM_ID` / `IOS_BUNDLE_IDENTIFIER` | Apple team and bundle id. Signing uses the Apple ID logged into Xcode (`Automatically manage signing`) |
| `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_PATH` | App Store Connect API key (`.p8`) — TestFlight **upload** and store version lookup only, not signing |
| `DRY_RUN` | `true` validates config only; skips version bump, build, and upload |
| `TESTFLIGHT_GROUPS` | Optional comma-separated TestFlight group names |

Create the Play service account in Play Console → Setup → API access, then
invite the account as a Release manager.

iOS **signing and archive** use Xcode only: open the project on your Mac,
sign in with your Apple Developer account, and enable Automatically manage
signing for the Release configurations. Create the App Store Connect API key
under Users and Access → Integrations → App Store Connect API for **upload**
and version lookup.

## Ruby / Fastlane

The scripts run Fastlane through Bundler (`release/Gemfile`).

```bash
# Debian/Ubuntu
sudo apt install ruby-full ruby-bundler
gem install bundler

# or rbenv
rbenv install 3.3.6
rbenv global 3.3.6
gem install bundler
```

`release/scripts/lib/common.sh` runs `bundle install` on first use.

## Tests

Automated checks do **not** talk to Google Play or App Store Connect:

```bash
bash release/scripts/test.sh
```

That runs bash syntax checks, `validate_config` cases (missing keys, bad
`GOOGLE_PLAY_TRACK`, missing secret files, pre-build hooks), and MiniTest for
flavor/AAB paths, pubspec version bump, and signing property escaping. Ruby
tests are skipped if `ruby` is not installed.

`DRY_RUN="true"` in `deploy.config` validates the config then stops — no
version bump, no Flutter build, no upload:

```bash
# in release/deploy.config
DRY_RUN="true"
bash release/scripts/deploy.sh
```

Use `GOOGLE_PLAY_TRACK="internal"` and `GOOGLE_PLAY_RELEASE_STATUS="draft"`
for the first real upload. Do not run `deploy.sh` on every PR.

## Drop this into another Flutter project

1. Copy the whole `release/` folder.
2. Copy the release-automation entries from `.gitignore`.
3. Copy `release/deploy.config.example` → `release/deploy.config` and set
   package name, bundle id, entrypoint, and secret paths.
4. Set `USES_FLAVORS` and `GOOGLE_PLAY_TRACK` as above.
5. Confirm Android release signing reads `android/key.properties` (standard
   Flutter template already does).
6. Confirm `ios/Runner/Info.plist` uses `$(FLUTTER_BUILD_NAME)` and
   `$(FLUTTER_BUILD_NUMBER)` so pubspec is the single version source.

## Shared application id in this repo

`dev` and `live` currently share `com.base.app` on both platforms, so they
are the **same** store listing. Changing `FLAVOR` does not create a second
app. They cannot be installed side by side.

To ship a separate dev app later, give `dev` its own application id
(`applicationIdSuffix ".dev"` in Gradle and a distinct iOS bundle id) and a
second Firebase Android/iOS app. Then point `GOOGLE_PLAY_PACKAGE_NAME` /
`IOS_BUNDLE_IDENTIFIER` at those ids — the lanes do not need to change.

## Optional macOS GitHub Actions job

Android lanes run on Linux. iOS archive needs `macos-latest`. Example:

```yaml
name: Release
on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
          working-directory: release
      - name: Write deploy.config
        working-directory: release
        run: |
          printf '%s\n' "${{ secrets.DEPLOY_CONFIG }}" > deploy.config
          mkdir -p secrets
          printf '%s\n' "${{ secrets.PLAY_JSON }}" > secrets/play-store-service-account.json
          printf '%s\n' "${{ secrets.ASC_P8 }}" > secrets/AuthKey.p8
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > secrets/upload-keystore.jks
      - name: Deploy
        run: bash release/scripts/deploy.sh
```

Prefer storing the whole `deploy.config` plus binary secrets in GitHub
Actions secrets rather than committing any of them.
