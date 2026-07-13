# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

VidBee_Flutter is an Android video downloader built on Flutter, wrapping the `yt-dlp` engine (via the `extractor` plugin) for 1000+ sites. State is managed with Riverpod, persistence with Drift/SQLite, UI with Material 3. See `AGENTS.md` for commit/PR conventions and coding style.

## Commands

```bash
flutter pub get                                              # install deps
flutter run                                                  # run on device/emulator (Android)
flutter analyze                                              # lint (uses analysis_options.yaml)
flutter test                                                 # all tests
flutter test test/history_service_test.dart                 # single test file
flutter test --plain-name "addToHistory"                    # single test by name
dart run build_runner build --delete-conflicting-outputs    # regenerate Drift .g.dart after DB changes
flutter build apk --release                                  # signed release APK (needs android/key.properties)
```

After editing any Drift table, DAO, or `@DriftDatabase`/`@DriftAccessor` class, you MUST re-run `build_runner` — the `.g.dart` files are generated and must never be hand-edited.

## Architecture

### Download state flow (the key cross-cutting pattern)

Download task state does **not** live in Riverpod. It lives in `DownloadService` (`lib/core/services/download_service.dart`), which owns the mutable `_downloadQueue` and `_activeTasks` map (max 3 concurrent). Two messaging systems bridge the plugin, the service, and the UI:

1. `YtDlpService` listens to the `extractor` plugin's `onProgress`/`onStateChanged`/`onError` streams and **re-fires them as events on a global `EventBus`** (`lib/core/utils/event_bus.dart`, singleton `eventBus`).
2. `DownloadService` listens to those bus events, mutates its task maps, then fires a `TaskUpdatedEvent`.
3. The UI (`downloads_page.dart`) listens for `TaskUpdatedEvent` and calls `_refreshTasks()`, which copies `downloadService.getAllTasks()` into the `downloadTasksProvider` StateProvider so widgets rebuild.

So Riverpod's `downloadTasksProvider` is just a **snapshot mirror** refreshed by events, not the source of truth. When changing download behavior, trace through this EventBus chain — updating a provider directly will not work.

Riverpod providers themselves are wired in `lib/core/providers/service_providers.dart` (services, DAOs, and UI StateProviders all live in this one file).

### Services (`lib/core/services/`)

- `YtDlpService` and `CookieService` are **singletons** (`factory ... => _instance`). Calling `CookieService()` anywhere returns the same instance, even though they're also exposed via providers.
- On `YtDlpService.initialize()`, the app auto-updates yt-dlp to the latest stable (3 retries) and falls back to the bundled version on failure.
- After a download, the plugin returns the output *template* string, not the real path. `_findDownloadedFile` locates the newest non-`.part` file, then `MediaScanner.scanFile` notifies the Android media library so the file appears in galleries.

### Bilibili / cookie special-casing (read before touching parsing)

In `ytdlp_service.dart`, both `getVideoInfo` and `startDownload` contain duplicated Bilibili logic: rewrite `m.bilibili.com` → `www.bilibili.com`, **force a desktop User-Agent** (a mobile UA makes yt-dlp redirect to mobile and parsing fails), and add a `--referer`. If you change one path, change the other.

Cookies are stored **per domain**, not globally. `CookieService.importNetscapeCookieFile` splits an imported `cookies.txt` by domain into separate `cookies_<domain>.txt` files in the app documents dir, with paths saved in SharedPreferences under `cookie_file_path_<domain>`. The global `getCookieFilePath`/`setCookieFilePath` methods are `@Deprecated` — use the `*ForDomain` variants. WebView cookie clearing wipes *all* cookies (the API can't delete by domain).

### Database (`lib/core/database/`)

Drift DB (`vidbee.db`) with table `DownloadHistory`. `schemaVersion = 3` with additive `onUpgrade` (indexes on `downloaded_at`/`playlist_id` at v2; v3 removes unused `subscription_id` from the Drift schema only — old DBs may still have the orphan column, which is harmless). Bump the version and extend `onUpgrade` if you change a table.

### Settings persistence is split (intentional, but watch for it)

Download path and language are stored in **SharedPreferences** (loaded in `main.dart._loadSavedSettings`, read/written across `settings_page.dart`). There is *also* a `SettingsDao` + `AppSettings` model backed by the Drift `Settings` table. The settings page leans on SharedPreferences; the Drift-backed settings are largely unused. Don't assume one is canonical — check which mechanism a given setting actually uses.

### Internationalization (`lib/shared/i18n/`)

i18n is **hand-maintained, not generated** from ARB files. `AppLocalizations` exposes one getter per string, each calling `_translate(key)`, which dispatches to a per-language `Map<String,String>` in `app_localizations_{en,zh,ja,ko}.dart`. To add a string: add a getter in `app_localizations.dart` AND add the key to all four language maps. Only 4 locales are actually implemented (`zh`, `en`, `ja`, `ko`); `AppConstants.supportedLanguages` lists 14 but most are aspirational.

## Platform / build notes

- **Android only** in practice (a `windows/` folder exists but the app targets Android). `minSdk = 24` is required by the `extractor` plugin.
- Release builds currently **disable** R8 minify/resource shrinking (`isMinifyEnabled = false`) after `v2026.07.11.2` re-enable caused open-on-launch crashes on some devices. Keep `android/app/proguard-rules.pro` ready; only re-enable minify after full keep-rule validation on real devices.
- Signing reads `android/key.properties`; CI (`.github/workflows/build.yml`, runs on `windows-latest`) decodes the keystore from secrets. Pushing a `v*.*.*` tag builds a signed APK and publishes a GitHub release.
- The app requests `MANAGE_EXTERNAL_STORAGE` and defaults downloads to `/storage/emulated/0/Download` so other apps can see them.

## Lint

`flutter_lints` is enabled, including `prefer_const_constructors` / `prefer_const_literals_to_create_immutables`.
