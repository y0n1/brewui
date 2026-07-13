import 'package:brewui/ui/theme/brew_colors.dart';
import 'package:flutter/material.dart';

/// Dark Material 3 theme aligned with the brew.sh palette.
ThemeData buildBrewTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrewColors.marigold,
    onPrimary: BrewColors.background,
    secondary: BrewColors.dallas,
    onSecondary: BrewColors.peach,
    error: BrewColors.danger,
    onError: BrewColors.background,
    surface: BrewColors.surface,
    onSurface: BrewColors.peach,
    onSurfaceVariant: BrewColors.mutedText,
    outline: BrewColors.shadow,
    outlineVariant: BrewColors.dallas,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: BrewColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: BrewColors.surface,
      foregroundColor: BrewColors.peach,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: BrewColors.peach,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: BrewColors.peach,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(color: BrewColors.peach, fontSize: 14),
      bodySmall: TextStyle(color: BrewColors.mutedText, fontSize: 12),
      labelLarge: TextStyle(
        color: BrewColors.peach,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BrewColors.peach,
        side: const BorderSide(color: BrewColors.marigold, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: BrewColors.marigold,
    ),
    dividerTheme: const DividerThemeData(
      color: BrewColors.dallas,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      textColor: BrewColors.peach,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minVerticalPadding: 8,
    ),
  );
}
