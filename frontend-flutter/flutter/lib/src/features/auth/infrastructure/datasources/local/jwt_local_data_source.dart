import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manage JWT in device storage
class JwtLocalDataSource {
  final Future<SharedPreferences> futureSharedPreferences;

  /// Default constructor for [JwtLocalDataSource]
  JwtLocalDataSource({required this.futureSharedPreferences});

  /// Get jwt from the device storage
  Future<Either<Failure, JwtEntity>> get() async {
    final sharedPreferences = await futureSharedPreferences;
    final refresh = sharedPreferences.getString("refreshToken");
    final access = sharedPreferences.getString("accessToken");
    if (refresh == null) {
      return left(const EmptyFailure());
    }
    return right(JwtEntity(access: access ?? '', refresh: refresh));
  }

  /// Store jwt in device storage
  Future<bool> store(JwtEntity jwt) async {
    final sharedPreferences = await futureSharedPreferences;
    try {
      await sharedPreferences.setString("refreshToken", jwt.refresh);
      if (jwt.access != null) {
        await sharedPreferences.setString("accessToken", jwt.access!);
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
      await sharedPreferences.remove("refreshToken");
      await sharedPreferences.remove("accessToken");
    } catch (e) {
      return false;
    }
    return true;
  }
}
