import 'package:balance_home_app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      primaryColor: AppColors.primaryColor,
      navigationRailTheme: navigationRailTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      textTheme: GoogleFonts.openSansTextTheme(),
      colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.light,
              primarySwatch: AppColors.primaryColor)
          .copyWith(background: const Color.fromARGB(254, 254, 252, 224)));

  /// Dark [ThemeData]
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      navigationRailTheme: navigationRailTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      textTheme: GoogleFonts.openSansTextTheme(),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: AppColors.primaryColor)
          .copyWith(
              brightness: Brightness.dark,
              background: const Color.fromARGB(254, 254, 252, 224)));
}
