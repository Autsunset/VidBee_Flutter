import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bounded translucent layer for floating navigation and important controls.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 28,
    this.blur = 16,
  }) : assert(borderRadius >= 0),
       assert(blur >= 0);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>();
    final highContrast = MediaQuery.maybeOf(context)?.highContrast ?? false;
    final opaque = highContrast || glass == null;
    final radius = BorderRadius.circular(borderRadius);
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: opaque ? theme.colorScheme.surface : null,
        gradient: opaque
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [glass.surfaceTop, glass.surfaceBottom],
              ),
      ),
      child: CustomPaint(
        foregroundPainter: _GlassRimPainter(
          radius: borderRadius,
          start: opaque ? theme.colorScheme.outline : glass.rimStart,
          end: opaque ? theme.colorScheme.outline : glass.rimEnd,
          highContrast: opaque,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
    // Clip before filtering: otherwise even a small control blurs the viewport.
    if (!opaque && blur > 0) {
      surface = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      );
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: opaque
              ? const []
              : [
                  BoxShadow(
                    color: glass.shadow,
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                    spreadRadius: -8,
                  ),
                ],
        ),
        child: ClipRRect(borderRadius: radius, child: surface),
      ),
    );
  }
}

/// Glass-like list material without the cost of one backdrop filter per row.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => GlassSurface(
    padding: padding,
    margin: margin,
    borderRadius: borderRadius,
    blur: 0,
    child: child,
  );
}

/// Static painted atmosphere; switching style keeps the content element intact.
class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass =
        theme.extension<GlassTheme>() ??
        (theme.brightness == Brightness.dark
            ? GlassTheme.dark
            : GlassTheme.light);
    final highContrast = MediaQuery.maybeOf(context)?.highContrast ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _AtmospherePainter(
                  glass: glass,
                  enabled: enabled,
                  highContrast: highContrast,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.radius,
    required this.start,
    required this.end,
    required this.highContrast,
  });

  final double radius;
  final Color start;
  final Color end;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(0.75);
    final border = RRect.fromRectAndRadius(
      rect,
      Radius.circular((radius - 0.75).clamp(0, radius)),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 1.5 : 1.2;
    if (highContrast) {
      paint.color = start;
    } else {
      paint.shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [
          start,
          start.withValues(alpha: start.a * 0.42),
          end,
          start.withValues(alpha: start.a * 0.65),
        ],
        [0, 0.38, 0.7, 1],
      );
    }
    canvas.drawRRect(border, paint);
    if (highContrast) return;

    final inset = rect.deflate(1.4);
    if (inset.isEmpty) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        inset,
        Radius.circular((radius - 2.15).clamp(0, radius)),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..shader = ui.Gradient.linear(inset.topLeft, inset.bottomCenter, [
          start.withValues(alpha: start.a * 0.26),
          Colors.transparent,
        ]),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      start != oldDelegate.start ||
      end != oldDelegate.end ||
      highContrast != oldDelegate.highContrast;
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({
    required this.glass,
    required this.enabled,
    required this.highContrast,
  });

  final GlassTheme glass;
  final bool enabled;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled || size.isEmpty) return;
    final bounds = Offset.zero & size;
    if (highContrast) {
      canvas.drawRect(bounds, Paint()..color = glass.backgroundStart);
      return;
    }
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(bounds.topLeft, bounds.bottomRight, [
          glass.backgroundStart,
          glass.backgroundEnd,
        ]),
    );

    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [color, color.withValues(alpha: 0)],
            [0, 1],
          ),
      );
    }

    final width = size.width;
    glow(
      Offset(width * 0.98, size.height * 0.09),
      width * 0.95,
      glass.amberGlow,
    );
    glow(
      Offset(width * -0.05, size.height * 0.57),
      width * 0.9,
      glass.mintGlow,
    );
    glow(
      Offset(width * 1.15, size.height * 0.96),
      width * 0.72,
      glass.mintGlow.withValues(alpha: glass.mintGlow.a * 0.7),
    );

    // Thin arcs give the still backdrop a lens-like depth without animation.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = glass.rimStart.withValues(alpha: glass.rimStart.a * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 1.01, size.height * 0.2),
        width: width * 1.38,
        height: size.height * 0.7,
      ),
      arcPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 1.01, size.height * 0.2),
        width: width * 1.47,
        height: size.height * 0.75,
      ),
      arcPaint
        ..color = glass.rimStart.withValues(alpha: glass.rimStart.a * 0.1),
    );
  }

  @override
  bool shouldRepaint(_AtmospherePainter oldDelegate) =>
      glass != oldDelegate.glass ||
      enabled != oldDelegate.enabled ||
      highContrast != oldDelegate.highContrast;
}
