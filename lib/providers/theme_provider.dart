import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  late Box _themeBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _themeBox = await Hive.openBox('settings');
    _isDarkMode = _themeBox.get('darkMode', defaultValue: false);
    notifyListeners(); // Notify after loading
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeBox.put('darkMode', _isDarkMode);
    notifyListeners();
  }
}
