# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter application named `vidbee_flutter`. App code lives in `lib/`:

- `lib/main.dart` starts the app.
- `lib/core/` contains models, database DAOs, providers, services, and utilities.
- `lib/features/` groups user-facing areas such as downloads, history, and settings.
- `lib/shared/` contains constants and hand-maintained localization classes.

Platform projects are in `android/` and `windows/`. Tests live in `test/`, currently starting with `test/widget_test.dart`. Root screenshots and guides such as `COOKIES_GUIDE.md` are documentation assets. Generated Drift files use the `.g.dart` suffix; update them with code generation rather than manual edits.

## Build, Test, and Development Commands

- `flutter pub get` installs Dart and Flutter dependencies from `pubspec.yaml`.
- `flutter run` launches the app on the selected device or emulator.
- `flutter test` runs unit and widget tests.
- `flutter analyze` runs the Flutter analyzer with `analysis_options.yaml`.
- `dart run build_runner build --delete-conflicting-outputs` regenerates Drift database code after DAO, table, or database changes.
- `flutter build apk` creates an Android release APK.

Run commands from the repository root.

## Coding Style & Naming Conventions

Use standard Dart formatting: two-space indentation, trailing commas for readable multi-line Flutter widgets, and `dart format .` before submitting broad edits. The project uses `package:flutter_lints/flutter.yaml`; `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` are intentionally ignored.

Name Dart files in `snake_case.dart`. Use `PascalCase` for classes and widgets, `camelCase` for fields, methods, providers, and local variables. Keep feature-specific UI inside `lib/features/<feature>/` and shared business logic inside `lib/core/`.

## Testing Guidelines

Use `flutter_test` for widget and unit coverage. Place tests under `test/` and name files with the `_test.dart` suffix, for example `download_service_test.dart` or `settings_page_test.dart`. Add focused tests when changing services, persistence, parsing, or visible workflows. Run `flutter test` and `flutter analyze` before opening a pull request.

## Commit & Pull Request Guidelines

Recent history uses short imperative or release-oriented subjects, including `fix: ...`, `docs: ...`, `chore: ...`, and version commits such as `v1.0.6+7: ...`. Keep commit subjects concise and describe the user-visible or maintenance impact.

Pull requests should include a clear summary, test results, linked issues when applicable, and screenshots or screen recordings for UI changes. Mention any generated files, platform-specific behavior, permission changes, or migration steps.

## Security & Configuration Tips

Do not commit personal cookies, tokens, signing keys, or local build artifacts. Be careful when editing download, cookie, WebView login, notification, and permission code because these areas affect user data and platform security behavior.
