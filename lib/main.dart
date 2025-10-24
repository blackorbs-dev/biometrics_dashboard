import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard/pages.dart';

void main() {
  runApp(const ProviderScope(child: BiometricsApp()));
}

class BiometricsApp extends ConsumerWidget {
  const BiometricsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Biometrics Dashboard',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF9F9FD),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFF9F9FD)
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFDEDEDF)),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFFF9F9FD),
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDEDEDF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    ),
  ),
  useMaterial3: true,
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF181818),
  cardTheme: CardThemeData(
    color: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade700),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF2D2D2D),
      foregroundColor: const Color(0xFFEAEAEA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade700),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    ),
  ),
  useMaterial3: true,
);
