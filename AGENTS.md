# BrewUI (app)

Cross-platform desktop UI for [Homebrew](https://brew.sh).

## Stack

- Flutter desktop only: **macOS**, **Linux**, **Windows**
- No iOS / Android / web targets

## Agent commands

Run from this repository root:

| Task | Command |
|------|---------|
| Resolve deps | `flutter pub get` |
| Run (macOS) | `flutter run -d macos` |
| Build (macOS) | `flutter build macos` |
| Test | `flutter test` |
| Analyze | `flutter analyze --fatal-infos` |
| Format check | `dart format --output=none --set-exit-if-changed .` |

Linux / Windows (when developing on those hosts): `flutter run -d linux` or `flutter run -d windows`.

## Contributing

- Open or pick up work via [Issues](https://github.com/y0n1/brewui/issues) and the [BrewUI project board](https://github.com/users/y0n1/projects/2).
- Prefer issue acceptance criteria over inventing scope in code.
- Desktop only — do not add mobile or web targets.
- Before opening a PR, run the same gates as CI: `flutter analyze --fatal-infos`, `dart format --output=none --set-exit-if-changed .`, and `flutter test` (see `.github/workflows/ci.yml`).
