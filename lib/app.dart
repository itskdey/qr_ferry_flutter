import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'widgets/qrferry_design.dart';

class QrFerryApp extends StatelessWidget {
  const QrFerryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: QrFerryDesign.signal,
      brightness: Brightness.light,
      surface: QrFerryDesign.paper,
    ).copyWith(
      primary: QrFerryDesign.signal,
      onPrimary: QrFerryDesign.ink,
      secondary: QrFerryDesign.blue,
      onSecondary: Colors.white,
      surface: QrFerryDesign.paper,
      onSurface: QrFerryDesign.ink,
      outline: QrFerryDesign.line,
      error: QrFerryDesign.red,
    );

    return GetMaterialApp(
      title: 'QRFerry',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: QrFerryDesign.paper,
        dividerColor: QrFerryDesign.line,
        splashFactory: InkRipple.splashFactory,
        appBarTheme: const AppBarTheme(
          backgroundColor: QrFerryDesign.paper,
          foregroundColor: QrFerryDesign.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: QrFerryDesign.signal,
            foregroundColor: QrFerryDesign.ink,
            minimumSize: const Size(0, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: QrFerryDesign.ink,
            minimumSize: const Size(0, 50),
            side: const BorderSide(color: QrFerryDesign.ink),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
    );
  }
}
