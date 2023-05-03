import 'package:balance_home_app/config/local_storage_client.dart';
import 'package:balance_home_app/config/theme.dart';
import 'package:flutter/material.dart';

/// Manage Settings in device storage
class ThemeLocalDataSource {
  final LocalStorageClient storageClient;

  /// Default constructor for [ThemeLocalDataSource]
  ThemeLocalDataSource({required this.storageClient});

  Future<ThemeData?> get() async {
    String? themeStr = await storageClient.getValue("theme");
    if (themeStr != null && themeStr == "dark") {
      return AppTheme.darkTheme;
    }
    if (themeStr != null && themeStr == "light") {
      return AppTheme.lightTheme;
    }
    return null;
  }

  Future<bool> store(ThemeData theme) async {
    return await storageClient.store("theme", theme.brightness.name);
  }

  Future<bool> remove() async {
    return await storageClient.removeKey("theme");
  }
}
