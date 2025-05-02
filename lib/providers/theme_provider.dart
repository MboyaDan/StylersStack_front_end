import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   _isDarkMode = prefs.getBool('darkMode')?? false;
    notifyListeners(); // Notify after loading
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode',isDarkMode);
    notifyListeners();
  }
}
