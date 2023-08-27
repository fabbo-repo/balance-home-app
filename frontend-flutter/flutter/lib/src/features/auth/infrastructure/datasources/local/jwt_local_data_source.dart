import 'package:balance_home_app/src/core/clients/local_preferences_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Manage JWT in device storage
class JwtLocalDataSource {
  final LocalPreferencesClient storageClient;

  /// Default constructor for [JwtLocalDataSource]
  JwtLocalDataSource({required this.storageClient});

  /// Get jwt from the device storage
  Future<Either<Failure, JwtEntity>> get() async {
    String? access = await storageClient.getValue("accessToken");
    String? refresh = await storageClient.getValue("refreshToken");
    if (access == null) {
      return left(const EmptyFailure());
    }
    return right(JwtEntity(access: access, refresh: refresh));
  }

  /// Store jwt in device storage
  Future<bool> store(JwtEntity jwt, {required bool longDuration}) async {
    try {
      if (jwt.access != null) {
        await storageClient.store("accessToken", jwt.access!);
      }
      if (jwt.refresh != null && longDuration) {
        await storageClient.store("refreshToken", jwt.refresh!);
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Remove jwt from device storage
  Future<bool> remove() async {
    try {
      await storageClient.removeKey("accessToken");
      await storageClient.removeKey("refreshToken");
    } catch (_) {
      return false;
    }
    return true;
  }
}
