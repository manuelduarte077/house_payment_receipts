import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Por defecto, tema claro
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Cambiar el tema y notificar a los listeners
  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    await _saveThemeToPrefs(); // Guardar la preferencia del tema
  }

  // Cargar el tema desde SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    notifyListeners(); // Notificar a los listeners después de cargar el tema
  }

  // Guardar el tema en SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }
}
