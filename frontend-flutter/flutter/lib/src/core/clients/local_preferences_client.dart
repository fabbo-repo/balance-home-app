import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesClient {
  @visibleForTesting
  late final Future<SharedPreferences> futureSharedPreferencesClient;

  LocalPreferencesClient({Future<SharedPreferences>? futureSharedPreferences}) {
    futureSharedPreferencesClient =
        futureSharedPreferences ?? SharedPreferences.getInstance();
  }

  Future<String?> getValue(String key) async {
    return (await futureSharedPreferencesClient).getString(key);
  }

  Future<bool> removeKey(String key) async {
    try {
      (await futureSharedPreferencesClient).remove(key);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> store(String key, String value) async {
    try {
      (await futureSharedPreferencesClient).setString(key, value);
    } catch (e) {
      return false;
    }
    return true;
  }
}
