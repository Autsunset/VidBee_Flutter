import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i18n/app_localizations.dart';
import 'glass_widgets.dart';

class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final destinations = [
      (Icons.downloading_rounded, loc.download),
      (Icons.history_rounded, loc.history),
      (Icons.tune_rounded, loc.settings),
    ];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: MediaQuery.highContrastOf(context),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassSurface(
              borderRadius: 32,
              blur: 20,
              padding: const EdgeInsets.all(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedAlign(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(selectedIndex - 1.0, 0),
                      child: FractionallySizedBox(
                        widthFactor: 1 / destinations.length,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFDB83), Color(0xFFF4B932)],
                            ),
                            border: Border.all(color: const Color(0xFFFFE7AD)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: Semantics(
                            selected: selectedIndex == i,
                            button: true,
                            label: destinations[i].$2,
                            child: Tooltip(
                              message: destinations[i].$2,
                              excludeFromSemantics: true,
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  key: ValueKey('glass-nav-$i'),
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () => onDestinationSelected(i),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 11,
                                    ),
                                    child: ExcludeSemantics(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            destinations[i].$1,
                                            size: 23,
                                            color: selectedIndex == i
                                                ? const Color(0xFF392B10)
                                                : colors.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            destinations[i].$2,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: selectedIndex == i
                                                      ? const Color(0xFF392B10)
                                                      : colors.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
