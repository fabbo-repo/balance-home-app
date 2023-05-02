import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';

/// Manage JWT in device storage
class JwtLocalDataSource {
  final Future<SharedPreferences> futureSharedPreferences;

  /// Default constructor for [JwtLocalDataSource]
  JwtLocalDataSource({required this.futureSharedPreferences});

  /// Get jwt from the device storage
  Future<Either<Failure, JwtEntity>> get() async {
    final sharedPreferences = await futureSharedPreferences;
    String? refresh, access;
    if (kIsWeb) {
      final cookies = _loadCookies();
      refresh = cookies["refreshToken"];
      access = cookies["accessToken"];
    } else {
      refresh = sharedPreferences.getString("refreshToken");
      access = sharedPreferences.getString("accessToken");
    }
    if (refresh == null || access == null) {
      return left(const EmptyFailure());
    }
    return right(JwtEntity(access: access, refresh: refresh));
  }

  /// Store jwt in device storage
  Future<bool> store(JwtEntity jwt) async {
    final sharedPreferences = await futureSharedPreferences;
    try {
      if (kIsWeb) {
        final cookies = _loadCookies();
        cookies["refreshToken"] = jwt.refresh;
        if (jwt.access != null) {
          cookies["accessToken"] = jwt.access!;
        }
        _storeCookies(cookies);
      } else {
        await sharedPreferences.setString("refreshToken", jwt.refresh);
        if (jwt.access != null) {
          await sharedPreferences.setString("accessToken", jwt.access!);
        }
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Remove jwt from device storage
  Future<bool> remove() async {
    final sharedPreferences = await futureSharedPreferences;
    try {
      if (kIsWeb) {
        final cookies = _loadCookies();
        cookies.remove("refreshToken");
        cookies.remove("accessToken");
        _storeCookies(cookies);
      } else {
        await sharedPreferences.remove("refreshToken");
        await sharedPreferences.remove("accessToken");
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Map<String, String> _loadCookies() {
    final cookies = document.cookie;
    if (cookies != null && cookies.isNotEmpty) {
      final entity = cookies.split("; ").map((item) {
        final split = item.split("=");
        return MapEntry(split[0], split[1]);
      });
      return Map.fromEntries(entity);
    }
    return {};
  }

  void _storeCookies(Map<String, String> cookies) {
    cookies.forEach((key, value) {
      document.cookie = "$key=$value";
    });
  }
}
