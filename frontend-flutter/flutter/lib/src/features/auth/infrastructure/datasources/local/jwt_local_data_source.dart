import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

/// Manage JWT in device storage
class JwtLocalDataSource {
  final FlutterSecureStorage _storage;

  /// Default constructor for [JwtLocalDataSource]
  JwtLocalDataSource(this._storage);

  /// Get jwt from the device storage
  Future<Either<Failure, JwtEntity>> get() async {
    final refresh = await _storage.read(key: "refresh_jwt");
    final access = await _storage.read(key: "access_jwt");
    if (refresh == null) {
      return left(const EmptyFailure());
    }
    return right(JwtEntity(access: access ?? '', refresh: refresh));
  }

  /// Store jwt in device storage
  Future<bool> store(JwtEntity jwt) async {
    try {
      await _storage.write(key: "refresh_jwt", value: jwt.refresh);
      await _storage.write(key: "access_jwt", value: jwt.access);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Remove jwt from device storage
  Future<bool> remove() async {
    try {
      await _storage.delete(key: "refresh_jwt");
      await _storage.delete(key: "refresh_jwt");
    } catch (e) {
      return false;
    }
    return true;
  }
}
