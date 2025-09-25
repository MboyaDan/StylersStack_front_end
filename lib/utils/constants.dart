import 'package:flutter/material.dart';

class AppColors {
  // ==========
  // THEME-AWARE COLORS (require BuildContext)
  // ==========
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  // ==========
  // STATIC BRAND COLORS (safe for const widgets)
  // ==========
  static const Color brown = Color(0xFF795548); // brand brown
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color grey = Colors.grey;
  static const Color button = Color(0xFFE5E5E5);
  static const Color button2 = Color(0xFFD5C1B1);
  static const Color text1 = Color(0xFF333333);
  static const Color text2 = Color(0xFF666666);
  static const Color text3 = Color(0xFF999999);
  static const Color text4 = Color(0xFFCCCCCC);
  static const Color mpesaRed = Color(0xFFE51C23);
  static const Color mpesaGreen = Color(0xFF1BA548);







}

class AppSpacing {
  static const double padding = 12.0;
  static const double cardMargin = 8.0;
  static const double imageSize = 60.0;
  static const double borderRadius = 12.0;
}
