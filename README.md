# BrewUI

Cross-platform desktop UI for [Homebrew](https://brew.sh).

**Targets:** macOS, Linux, and Windows only (no mobile/web).

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (3.44+ recommended)
- Desktop toolchain for your platform (Xcode on macOS, etc.)

## Develop

From this repository root:

```bash
flutter pub get
flutter run -d macos          # primary development platform today
flutter build macos
flutter test
flutter analyze --fatal-infos
dart format --output=none --set-exit-if-changed .
```

Linux / Windows (when developing on those hosts):

```bash
flutter run -d linux
flutter run -d windows
```

## Contributing

Track work on [Issues](https://github.com/y0n1/brewui/issues) and the [project board](https://github.com/users/y0n1/projects/2). Use each issue’s acceptance criteria as the source of truth for what to build.

CI (`.github/workflows/ci.yml`) runs analyze, format check, and unit tests on every PR and on pushes to `main`. Run those commands locally before opening a PR.
