import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Por defecto, tema claro
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Cambiar el tema y notificar a los listeners
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
