import 'package:balance_home_app/config/app_colors.dart';
import 'package:flutter/material.dart';

/// Default [ThemeData]
class AppTheme {
  @visibleForTesting
  static NavigationRailThemeData navigationRailTheme =
      const NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.white54),
          backgroundColor: Color.fromARGB(255, 70, 70, 70));

  @visibleForTesting
  static BottomNavigationBarThemeData bottomNavigationBarTheme =
      const BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: Color.fromARGB(255, 70, 70, 70));

  /// Light [ThemeData]
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: AppColors.primaryColor,
      primaryColor: AppColors.primaryColor,
      backgroundColor: const Color.fromARGB(254, 254, 252, 224),
      navigationRailTheme: navigationRailTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme);

  /// Dark [ThemeData]
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: AppColors.primaryColor,
      primaryColor: AppColors.primaryColor,
      backgroundColor: const Color.fromARGB(254, 254, 252, 224),
      navigationRailTheme: navigationRailTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme);
}
