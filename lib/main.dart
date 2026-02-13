import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storedTheme = prefs.getString('theme_mode') ?? 'system';
  
  runApp(CoffeeCalculatorApp(initialTheme: storedTheme));
}

class CoffeeCalculatorApp extends StatefulWidget {
  final String initialTheme;
  const CoffeeCalculatorApp({super.key, required this.initialTheme});

  @override
  State<CoffeeCalculatorApp> createState() => _CoffeeCalculatorAppState();
}

class _CoffeeCalculatorAppState extends State<CoffeeCalculatorApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = _parseTheme(widget.initialTheme);
  }

  ThemeMode _parseTheme(String theme) {
    if (theme == 'dark') return ThemeMode.dark;
    if (theme == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void _toggleTheme() async {
    final nextMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = nextMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', nextMode == ThemeMode.dark ? 'dark' : 'light');
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
