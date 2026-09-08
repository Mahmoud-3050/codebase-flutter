# codebase

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Release (Play Store / TestFlight)

Copy `release/deploy.config.example` to `release/deploy.config`, fill in store
credentials, set `GOOGLE_PLAY_TRACK` to `internal` or `production`, then:

```bash
bash release/scripts/deploy.sh
bash release/scripts/deploy.sh --skip-deploy   # build AAB/IPA only
```

See [release/README.md](release/README.md) for flavors vs no-flavors, secrets, and CI.
