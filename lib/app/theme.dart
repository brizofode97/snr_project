import 'package:material_ui/material_ui.dart';

const Color snrPrimary = Color(0xFF12305A);
const Color snrAccent = Color(0xFF0E8F8A);
const Color snrGradientStart = Color(0xFF1B3F73);

final List<Color> snrBrandGradient = [snrGradientStart, snrAccent];

ThemeData buildSnr360Theme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: snrPrimary,
    secondary: snrAccent,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF1F5FA),
    appBarTheme: AppBarTheme(
      backgroundColor: snrPrimary,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: snrAccent,
      unselectedLabelColor: Colors.white70,
      indicatorColor: snrAccent,
    ),
    navigationDrawerTheme: const NavigationDrawerThemeData(),
    listTileTheme: ListTileThemeData(
      iconColor: snrPrimary,
    ),
  );
}
