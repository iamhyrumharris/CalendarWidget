import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/calendar_screen.dart';
import 'providers/theme_provider.dart' as app_theme;

void main() {
  runApp(
    const ProviderScope(
      child: CalendarApp(),
    ),
  );
}

class CalendarApp extends ConsumerWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(app_theme.themeModeProvider);
    
    ThemeMode effectiveThemeMode;
    switch (themeMode) {
      case app_theme.ThemeMode.system:
        effectiveThemeMode = ThemeMode.system;
        break;
      case app_theme.ThemeMode.light:
        effectiveThemeMode = ThemeMode.light;
        break;
      case app_theme.ThemeMode.dark:
        effectiveThemeMode = ThemeMode.dark;
        break;
    }
    
    return MaterialApp(
      title: 'Journal Calendar',
      debugShowCheckedModeBanner: false,
      themeMode: effectiveThemeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const CalendarScreen(),
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.blue,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
    );
  }
}
