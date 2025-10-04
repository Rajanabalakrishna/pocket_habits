import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class AppPalette {
  // Dark Theme Colors
  static const darkBackground = Color(0xFF1A202C);
  static const darkSurface = Color(0xFF2D3748);
  static const darkCard = Color(0xFF4A5568);
  static const darkPrimary = Color(0xFF667EEA);
  static const darkSecondary = Color(0xFF764ABC);

  // Light Theme Colors
  static const lightBackground = Color(0xFFF7F8FC);
  static const lightSurface = Colors.white;
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF4C51BF);
  static const lightSecondary = Color(0xFF805AD5);

  // Common Colors
  static const success = Color(0xFF48BB78);
  static const warning = Color(0xFFED8936);
  static const error = Color(0xFFE53E3E);
  static const info = Color(0xFF3182CE);

  // Dark Theme
  static final darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCard,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      background: darkBackground,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(56),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData( // Changed to BottomNavigationBarThemeData
      backgroundColor: darkSurface,
      selectedItemColor: darkPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkPrimary,
      ),
    ),
  );

  // Light Theme
  static final lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCard,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: lightCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(56),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData( // Changed to BottomNavigationBarThemeData
      backgroundColor: Colors.white,
      selectedItemColor: lightPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightPrimary,
      ),
    ),
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;

  ThemeNotifier({ThemeMode mode = ThemeMode.system})
      : _mode = mode,
        super(AppPalette.lightTheme) {
    _loadTheme();
  }

  ThemeMode get mode => _mode;
  bool get isDarkMode => _mode == ThemeMode.dark;

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'system';

    switch (themeString) {
      case 'light':
        _mode = ThemeMode.light;
        state = AppPalette.lightTheme;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        state = AppPalette.darkTheme;
        break;
      default:
        _mode = ThemeMode.system;
        // Use system theme
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        state = brightness == Brightness.dark
            ? AppPalette.darkTheme
            : AppPalette.lightTheme;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.light) {
      _mode = ThemeMode.dark;
      state = AppPalette.darkTheme;
      await prefs.setString('theme', 'dark');
    } else {
      _mode = ThemeMode.light;
      state = AppPalette.lightTheme;
      await prefs.setString('theme', 'light');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _mode = mode;

    switch (mode) {
      case ThemeMode.light:
        state = AppPalette.lightTheme;
        await prefs.setString('theme', 'light');
        break;
      case ThemeMode.dark:
        state = AppPalette.darkTheme;
        await prefs.setString('theme', 'dark');
        break;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        state = brightness == Brightness.dark
            ? AppPalette.darkTheme
            : AppPalette.lightTheme;
        await prefs.setString('theme', 'system');
        break;
    }
  }
}
