import 'dart:ui';

import 'package:flutter/material.dart';

class NrdTheme {
  static const _red = Color(0xFFB71C1C);
  static const _gold = Color(0xFFF2B134);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _red,
        brightness: Brightness.light,
        primary: _red,
        secondary: _gold,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .78)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8CC7FF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0C1724),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A26).withValues(alpha: .78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class GlassSoft extends StatelessWidget {
  const GlassSoft({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = BorderRadius.circular(radius);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: shape,
              color: (dark ? const Color(0xFF111A26) : Colors.white)
                  .withValues(alpha: dark ? .70 : .66),
              border: Border.all(
                color: Colors.white.withValues(alpha: dark ? .25 : .68),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  spreadRadius: -3,
                  offset: const Offset(0, 7),
                  color: Colors.black.withValues(alpha: dark ? .20 : .07),
                ),
              ],
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
