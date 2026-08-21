import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';

class QrFerryApp extends StatelessWidget {
  const QrFerryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF8B7BFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF111216),
    );

    return MaterialApp(
      title: 'QR Ferry',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0B0C0F),
        cardColor: const Color(0xFF14161B),
        dividerColor: Colors.white.withValues(alpha: 0.08),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
