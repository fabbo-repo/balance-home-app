import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manage Settings in device storage
class ThemeLocalDataSource {
  final SharedPreferences _sharedPreferences;

  /// Default constructor for [ThemeLocalDataSource]
  ThemeLocalDataSource(this._sharedPreferences);

  ThemeMode get() {
    String? themeStr = _sharedPreferences.getString("theme");
    if (themeStr != null && themeStr == "dark") {
      return ThemeMode.dark;
    }
    if (themeStr != null && themeStr == "light") {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  Future<bool> store(ThemeMode theme) async {
    return await _sharedPreferences.setString("theme", theme.name);
  }

  Future<bool> remove() async {
    return _sharedPreferences.remove("theme");
  }
}
