import 'package:balance_home_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manage Settings in device storage
class ThemeLocalDataSource {
  final Future<SharedPreferences> futureSharedPreferences;

  /// Default constructor for [ThemeLocalDataSource]
  ThemeLocalDataSource({required this.futureSharedPreferences});

  Future<ThemeData?> get() async {
    final sharedPreferences = await futureSharedPreferences;
    String? themeStr = sharedPreferences.getString("theme");
    if (themeStr != null && themeStr == "dark") {
      return AppTheme.darkTheme;
    }
    if (themeStr != null && themeStr == "light") {
      return AppTheme.lightTheme;
    }
    return null;
  }

  Future<bool> store(ThemeData theme) async {
    final sharedPreferences = await futureSharedPreferences;
    return await sharedPreferences.setString("theme", theme.brightness.name);
  }

  Future<bool> remove() async {
    final sharedPreferences = await futureSharedPreferences;
    return sharedPreferences.remove("theme");
  }
}
