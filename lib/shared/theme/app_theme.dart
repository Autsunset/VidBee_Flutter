import 'package:flutter/material.dart';

import '../../core/providers/appearance_provider.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFFF9B61B);

  static bool isLiquidGlass(BuildContext context) =>
      Theme.of(context).extension<GlassTheme>() != null;

  static ThemeData build({
    required Brightness brightness,
    required AppThemeStyle style,
  }) {
    final original = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
    );
    if (style == AppThemeStyle.classic) return original;

    final dark = brightness == Brightness.dark;
    final colors = original.colorScheme.copyWith(
      primary: dark ? const Color(0xFFFFD180) : const Color(0xFF865500),
      onPrimary: dark ? const Color(0xFF432B00) : Colors.white,
      primaryContainer: dark
          ? const Color(0xFF624719)
          : const Color(0xFFFFE0A0),
      onPrimaryContainer: dark
          ? const Color(0xFFFFE6B7)
          : const Color(0xFF392700),
      secondary: dark ? const Color(0xFF9CDBCF) : const Color(0xFF28675B),
      onSecondary: dark ? const Color(0xFF00382E) : Colors.white,
      secondaryContainer: dark
          ? const Color(0xFF204D45)
          : const Color(0xFFD4EEE5),
      onSecondaryContainer: dark
          ? const Color(0xFFC5EFE3)
          : const Color(0xFF164438),
      tertiary: dark ? const Color(0xFFA9CFDF) : const Color(0xFF356377),
      onTertiary: dark ? const Color(0xFF0B3445) : Colors.white,
      tertiaryContainer: dark
          ? const Color(0xFF254A5B)
          : const Color(0xFFD8EAF0),
      onTertiaryContainer: dark
          ? const Color(0xFFCBE8F4)
          : const Color(0xFF153D50),
      surface: dark ? const Color(0xFF112127) : const Color(0xFFF3F7F4),
      onSurface: dark ? const Color(0xFFEAF3F0) : const Color(0xFF172F34),
      onSurfaceVariant: dark
          ? const Color(0xFFB6CDCE)
          : const Color(0xFF4D6569),
      surfaceContainerLowest: dark ? const Color(0xFF0B191E) : Colors.white,
      surfaceContainerLow: dark
          ? const Color(0xFF152A31)
          : const Color(0xFFF1F6F3),
      surfaceContainer: dark
          ? const Color(0xFF1B333A)
          : const Color(0xFFE8F1EC),
      surfaceContainerHigh: dark
          ? const Color(0xFF26424A)
          : const Color(0xFFDEEAE4),
      surfaceContainerHighest: dark
          ? const Color(0xFF314F56)
          : const Color(0xFFD3E2DC),
      outline: dark ? const Color(0xFF7D9B9E) : const Color(0xFF748D8F),
      outlineVariant: dark ? const Color(0xFF38555D) : const Color(0xFFBFD1CA),
      surfaceTint: Colors.transparent,
    );
    final glass = dark ? GlassTheme.dark : GlassTheme.light;
    final text = original.textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    final typography = text.copyWith(
      displayLarge: text.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1.08,
      ),
      displayMedium: text.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        height: 1.1,
      ),
      headlineLarge: text.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        height: 1.15,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.18,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.45,
        height: 1.25,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
      ),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: text.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.45),
      bodySmall: text.bodySmall?.copyWith(height: 1.4),
      labelLarge: text.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: text.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return original.copyWith(
      colorScheme: colors,
      textTheme: typography,
      scaffoldBackgroundColor: glass.backgroundStart,
      canvasColor: colors.surface,
      dividerColor: colors.outlineVariant.withValues(alpha: 0.5),
      extensions: [glass],
      appBarTheme: AppBarThemeData(
        backgroundColor: glass.backgroundStart,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: typography.titleLarge,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: rounded.copyWith(
          side: BorderSide(color: glass.rimStart.withValues(alpha: 0.45)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return typography.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.onSurface
                : colors.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFF9C361),
        foregroundColor: const Color(0xFF352704),
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        extendedTextStyle: typography.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF9C361),
          foregroundColor: const Color(0xFF352704),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: typography.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: typography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.outlineVariant),
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: typography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: typography.labelLarge,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.outlineVariant),
        ),
        titleTextStyle: typography.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        modalBackgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        dragHandleColor: colors.outline,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        selectedTileColor: colors.primaryContainer.withValues(alpha: 0.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerLow,
        selectedColor: colors.primaryContainer,
        side: BorderSide(color: colors.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: typography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? const Color(0xFFFFD180) : const Color(0xFFA56B05),
        linearTrackColor: colors.surfaceContainerHighest,
        linearMinHeight: 5,
        borderRadius: BorderRadius.circular(8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: colors.onSurface,
        contentTextStyle: typography.bodyMedium?.copyWith(
          color: colors.surface,
        ),
        actionTextColor: dark
            ? const Color(0xFF704A00)
            : const Color(0xFFFFD180),
      ),
    );
  }
}

@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.surfaceTop,
    required this.surfaceBottom,
    required this.rimStart,
    required this.rimEnd,
    required this.shadow,
    required this.amberGlow,
    required this.mintGlow,
  });

  static const light = GlassTheme(
    backgroundStart: Color(0xFFF0F6F3),
    backgroundEnd: Color(0xFFE4EFEB),
    surfaceTop: Color(0xEAFFFFFF),
    surfaceBottom: Color(0xC5F7FCFA),
    rimStart: Color(0xFFFFFFFF),
    rimEnd: Color(0x80ABC8BD),
    shadow: Color(0x13203F40),
    amberGlow: Color(0x66F9CB7D),
    mintGlow: Color(0x809AD7C8),
  );

  static const dark = GlassTheme(
    backgroundStart: Color(0xFF0D1D23),
    backgroundEnd: Color(0xFF152E35),
    surfaceTop: Color(0xD4314A51),
    surfaceBottom: Color(0xE01A3037),
    rimStart: Color(0x6289B4B4),
    rimEnd: Color(0x284D7575),
    shadow: Color(0x3800080D),
    amberGlow: Color(0x386D5126),
    mintGlow: Color(0x4D247C73),
  );

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color surfaceTop;
  final Color surfaceBottom;
  final Color rimStart;
  final Color rimEnd;
  final Color shadow;
  final Color amberGlow;
  final Color mintGlow;

  @override
  GlassTheme copyWith({
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? surfaceTop,
    Color? surfaceBottom,
    Color? rimStart,
    Color? rimEnd,
    Color? shadow,
    Color? amberGlow,
    Color? mintGlow,
  }) => GlassTheme(
    backgroundStart: backgroundStart ?? this.backgroundStart,
    backgroundEnd: backgroundEnd ?? this.backgroundEnd,
    surfaceTop: surfaceTop ?? this.surfaceTop,
    surfaceBottom: surfaceBottom ?? this.surfaceBottom,
    rimStart: rimStart ?? this.rimStart,
    rimEnd: rimEnd ?? this.rimEnd,
    shadow: shadow ?? this.shadow,
    amberGlow: amberGlow ?? this.amberGlow,
    mintGlow: mintGlow ?? this.mintGlow,
  );

  @override
  GlassTheme lerp(covariant GlassTheme? other, double t) {
    if (other == null) return this;
    return GlassTheme(
      backgroundStart: Color.lerp(backgroundStart, other.backgroundStart, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surfaceTop: Color.lerp(surfaceTop, other.surfaceTop, t)!,
      surfaceBottom: Color.lerp(surfaceBottom, other.surfaceBottom, t)!,
      rimStart: Color.lerp(rimStart, other.rimStart, t)!,
      rimEnd: Color.lerp(rimEnd, other.rimEnd, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      amberGlow: Color.lerp(amberGlow, other.amberGlow, t)!,
      mintGlow: Color.lerp(mintGlow, other.mintGlow, t)!,
    );
  }
}
