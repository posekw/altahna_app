import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CoffeeCalculatorApp());
}

class CoffeeCalculatorApp extends StatefulWidget {
  const CoffeeCalculatorApp({super.key});

  @override
  State<CoffeeCalculatorApp> createState() => _CoffeeCalculatorAppState();
}

class _CoffeeCalculatorAppState extends State<CoffeeCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: _themeMode,
      home: HomeScreen(onThemeToggle: _toggleTheme),
    );
  }
}
