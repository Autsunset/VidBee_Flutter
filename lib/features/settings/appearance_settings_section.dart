import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/appearance_provider.dart';
import '../../shared/i18n/app_localizations.dart';

class AppearanceSettingsSection extends ConsumerWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final selectedStyle = ref.watch(appThemeStyleProvider);
    final theme = Theme.of(context);

    Future<void> selectStyle(AppThemeStyle style) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(appThemeStyleProvider.notifier).setStyle(style);
      } catch (_) {
        if (!messenger.mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(loc.error)));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.interfaceStyle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            loc.appearanceHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackCards =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20;
              final cards = [
                _StyleCard(
                  key: const ValueKey('style-liquid-glass'),
                  style: AppThemeStyle.liquidGlass,
                  title: loc.liquidGlass,
                  description: loc.liquidGlassDescription,
                  selected: selectedStyle == AppThemeStyle.liquidGlass,
                  onTap: () => selectStyle(AppThemeStyle.liquidGlass),
                ),
                _StyleCard(
                  key: const ValueKey('style-classic'),
                  style: AppThemeStyle.classic,
                  title: loc.classicStyle,
                  description: loc.classicStyleDescription,
                  selected: selectedStyle == AppThemeStyle.classic,
                  onTap: () => selectStyle(AppThemeStyle.classic),
                ),
              ];
              if (stackCards) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [cards[0], const SizedBox(height: 12), cards[1]],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    super.key,
    required this.style,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final AppThemeStyle style;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final borderRadius = BorderRadius.circular(20);

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.34)
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StylePreview(style: style),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? colors.primary : colors.outline,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StylePreview extends StatelessWidget {
  const _StylePreview({required this.style});

  final AppThemeStyle style;

  @override
  Widget build(BuildContext context) {
    final glass = style == AppThemeStyle.liquidGlass;
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final classicColors = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF9B61B),
      brightness: brightness,
    );
    final base = dark ? const Color(0xFF182D35) : const Color(0xFFDAEDE8);
    final foreground = glass
        ? dark
              ? Colors.white
              : const Color(0xFF194E4A)
        : classicColors.onSurface;
    final accent = glass ? const Color(0xFFF9C361) : classicColors.primary;

    Widget bar(double width) => Container(
      width: width,
      height: 5,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(3),
      ),
    );

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: glass ? null : classicColors.surface,
          gradient: glass
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    base,
                    const Color(0xFF328E80).withValues(alpha: 0.55),
                    base,
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 14, color: accent),
                  const SizedBox(width: 6),
                  Expanded(child: bar(36)),
                  const SizedBox(width: 20),
                  Icon(Icons.more_horiz, size: 14, color: foreground),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: glass
                        ? Colors.white.withValues(alpha: dark ? 0.12 : 0.45)
                        : classicColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(glass ? 15 : 6),
                    border: glass
                        ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.south_rounded, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Expanded(child: bar(40)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: 64,
                height: 13,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(glass ? 8 : 3),
                  border: glass
                      ? Border.all(color: Colors.white.withValues(alpha: 0.6))
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
