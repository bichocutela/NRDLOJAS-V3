import 'package:flutter/material.dart';

class NrdTheme {
  static const _red = Color(0xFFB71C1C);
  static const _gold = Color(0xFFF2B134);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: InkRipple.splashFactory,
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
        fillColor: Colors.white.withValues(alpha: .84),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .82)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: InkRipple.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8CC7FF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0C1724),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A26).withValues(alpha: .86),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        color: (dark ? const Color(0xFF111A26) : Colors.white)
            .withValues(alpha: dark ? .86 : .84),
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? .18 : .62),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: -4,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: dark ? .14 : .045),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
