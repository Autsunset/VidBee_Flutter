import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/constants/app_constants.dart';
import 'shared/i18n/app_localizations.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/glass_navigation_bar.dart';
import 'shared/widgets/glass_widgets.dart';
import 'core/providers/appearance_provider.dart';
import 'core/providers/service_providers.dart';
import 'core/services/services.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/permission_helper.dart';
import 'core/utils/url_utils.dart';
import 'features/download/download.dart';
import 'features/history/history.dart';
import 'features/settings/settings.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await AppLogger.initialize();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogger.error('Flutter 未捕获异常', details.exception, details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogger.error('Platform 未捕获异常', error, stackTrace);
        return true;
      };

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      final appearance = AppThemeStyleNotifier();
      await appearance.ready;
      AppLogger.info('VidBee 启动完成');
      runApp(
        ProviderScope(
          overrides: [appThemeStyleProvider.overrideWith((ref) => appearance)],
          child: const VidBeeApp(),
        ),
      );
      // 通知通道不影响首屏展示，放到 runApp 之后初始化以缩短冷启动等待。
      unawaited(_initializeNotificationService());
    },
    (error, stackTrace) {
      AppLogger.error('Zone 未捕获异常', error, stackTrace);
    },
  );
}

Future<void> _initializeNotificationService() async {
  try {
    await NotificationService().initialize();
  } catch (e, stackTrace) {
    AppLogger.error('通知服务初始化失败，已跳过', e, stackTrace);
  }
}

class VidBeeApp extends ConsumerWidget {
  const VidBeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeStyle = ref.watch(appThemeStyleProvider);
    final languageCode = ref.watch(languageProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(brightness: Brightness.light, style: themeStyle),
      darkTheme: AppTheme.build(brightness: Brightness.dark, style: themeStyle),
      themeMode: themeMode,
      locale: Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _shareChannel = MethodChannel('com.vidbee.share');
  int _selectedIndex = 0;
  final _pendingSharedTexts = Queue<String>();
  bool _isAddUrlDialogOpen = false;

  late final List<Widget?> _pages = [_createPage(0), null, null];

  Widget _createPage(int index) => switch (index) {
    0 => DownloadsPage(onAddUrl: _showAddUrlDialog),
    1 => const HistoryPage(),
    2 => const SettingsPage(),
    _ => const SizedBox.shrink(),
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    if (defaultTargetPlatform == TargetPlatform.android) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _shareChannel.setMethodCallHandler((call) async {
          if (call.method == 'shareReceived') await _receiveSharedTexts();
        });
        unawaited(_receiveSharedTexts());
      });
    }
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _shareChannel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  Future<void> _receiveSharedTexts() async {
    List<String>? texts;
    try {
      texts = await _shareChannel.invokeListMethod<String>('takeSharedTexts');
    } on MissingPluginException {
      return;
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error('读取分享内容失败', error, stackTrace);
      return;
    }
    if (!mounted || texts == null) return;
    _pendingSharedTexts.addAll(texts);
    _showNextSharedUrl();
  }

  void _showNextSharedUrl() {
    if (_isAddUrlDialogOpen) return;
    while (_pendingSharedTexts.isNotEmpty) {
      final url = extractVideoUrl(_pendingSharedTexts.removeFirst());
      if (url != null) {
        _selectPage(0);
        unawaited(_showAddUrlDialog(initialUrl: url));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sharedUrlMissing)),
      );
    }
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // 加载下载路径
    final savedPath = prefs.getString('download_path');
    if (savedPath != null && savedPath.isNotEmpty) {
      if (mounted) {
        ref.read(downloadPathProvider.notifier).state = savedPath;
      }
    } else {
      final defaultPath = await PermissionHelper.getDefaultDownloadPath();
      if (mounted) {
        ref.read(downloadPathProvider.notifier).state = defaultPath;
      }
    }
    // 加载语言设置
    final savedLanguage = prefs.getString('language');
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      if (mounted) {
        ref.read(languageProvider.notifier).state = resolveAppLanguageCode(
          savedLanguage,
        );
      }
    }
    // 加载主题设置
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme != null && savedTheme.isNotEmpty) {
      final themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      if (mounted) {
        ref.read(themeModeProvider.notifier).state = themeMode;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isGlass = AppTheme.isLiquidGlass(context);

    // Keep the page subtree in the same slot when switching styles so downloads,
    // visited tabs and their scroll positions are not reinitialized.
    return GlassBackdrop(
      enabled: isGlass,
      child: Scaffold(
        backgroundColor: isGlass ? Colors.transparent : null,
        extendBody: isGlass,
        appBar: AppBar(
          backgroundColor: isGlass ? Colors.transparent : null,
          systemOverlayStyle: isGlass
              ? (Theme.of(context).brightness == Brightness.dark
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark)
                    .copyWith(statusBarColor: Colors.transparent)
              : null,
          toolbarHeight: isGlass ? 76 : null,
          titleSpacing: isGlass ? 24 : null,
          title: isGlass
              ? const _GlassBrand()
              : const Text(AppConstants.appName),
          actions: [
            if (isGlass)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GlassSurface(
                  borderRadius: 24,
                  blur: 12,
                  child: IconButton(
                    tooltip: loc.addUrl,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _showAddUrlDialog,
                  ),
                ),
              )
            else
              IconButton(
                tooltip: loc.addUrl,
                icon: const Icon(Icons.add),
                onPressed: _showAddUrlDialog,
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isGlass ? 960 : double.infinity,
            ),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                for (final page in _pages) page ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isGlass
            ? GlassNavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectPage,
              )
            : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectPage,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.download_outlined),
                    selectedIcon: const Icon(Icons.download),
                    label: loc.download,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.history_outlined),
                    selectedIcon: const Icon(Icons.history),
                    label: loc.history,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: loc.settings,
                  ),
                ],
              ),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _pages[index] ??= _createPage(index);
      _selectedIndex = index;
    });
  }

  Future<void> _showAddUrlDialog({String? initialUrl}) async {
    if (_isAddUrlDialogOpen) return;
    _isAddUrlDialogOpen = true;
    final route = DialogRoute<void>(
      context: context,
      builder: (context) => AddUrlDialog(initialUrl: initialUrl),
    );
    await Navigator.of(context, rootNavigator: true).push(route);
    await route.completed;
    if (!mounted) return;
    _isAddUrlDialogOpen = false;
    _showNextSharedUrl();
  }
}

class _GlassBrand extends StatelessWidget {
  const _GlassBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFDA79), Color(0xFFF9B61B)],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFFFE6A6)),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 29,
            color: Color(0xFF3C2B08),
          ),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Text(
            'VidBee',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
        ),
      ],
    );
  }
}
