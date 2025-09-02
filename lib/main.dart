import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'screens/main_screen.dart';

void main() {
  Intl.defaultLocale = 'pt_BR';

  runApp(const DevolutionCalculatorApp());
}

class DevolutionCalculatorApp extends StatelessWidget {
  const DevolutionCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Devoluções',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(elevation: 4),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
