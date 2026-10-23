import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF002E63);
  static const background = Color(0xFFFAF8F5);
  static const ink = Color(0xFF18211E);
  static const muted = Color(0xFF606C66);
  static const border = Color(0xFFE5E8E5);
  static const blueTint = Color(0xFFEEF4FA);
  static const greenTint = Color(0xFFEEF7F2);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFF99C5FF) : AppColors.primary,
      onPrimary: dark ? const Color(0xFF002248) : Colors.white,
      surface: dark ? const Color(0xFF1B2429) : Colors.white,
      onSurface: dark ? const Color(0xFFEEF2EF) : AppColors.ink,
      onSurfaceVariant: dark ? const Color(0xFFAEBBB5) : AppColors.muted,
      outlineVariant: dark ? const Color(0xFF34444A) : AppColors.border,
      primaryContainer: dark ? const Color(0xFF24394B) : AppColors.blueTint,
      onPrimaryContainer: dark ? const Color(0xFFBAD7FB) : AppColors.primary,
      secondaryContainer: dark ? const Color(0xFF173B31) : AppColors.greenTint,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF11191E) : AppColors.background,
      fontFamily: 'Inter',
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.onSurface),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: colors.onSurface),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: colors.onSurface),
        bodySmall: TextStyle(fontSize: 12, height: 1.45, color: colors.onSurfaceVariant),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF11191E) : AppColors.background,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: colors.onSurface),
      ),
      dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: .7), fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: colors.outlineVariant),
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surface,
        selectedColor: colors.primary,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
    );
  }
}
