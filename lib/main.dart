import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/constants/app_constants.dart';
import 'shared/i18n/app_localizations.dart';
import 'core/providers/service_providers.dart';
import 'core/services/services.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/permission_helper.dart';
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

      // 通知初始化失败不能阻塞启动；否则用户会看到「打开即闪退」。
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
      } catch (e, stackTrace) {
        AppLogger.error('通知服务初始化失败，已跳过', e, stackTrace);
      }

      AppLogger.info('VidBee 启动完成');
      runApp(const ProviderScope(child: VidBeeApp()));
    },
    (error, stackTrace) {
      AppLogger.error('Zone 未捕获异常', error, stackTrace);
    },
  );
}

class VidBeeApp extends ConsumerWidget {
  const VidBeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final languageCode = ref.watch(languageProvider);

    const primaryColor = Color(0xFFF9B61B);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),
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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DownloadsPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
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
        ref.read(languageProvider.notifier).state = savedLanguage;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUrlDialog(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
    );
  }

  void _showAddUrlDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddUrlDialog());
  }
}
