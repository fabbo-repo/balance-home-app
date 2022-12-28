import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

/// Manage Credentials in device storage
class CredentialsLocalDataSource {
  final FlutterSecureStorage _storage;

  /// Default constructor for [CredentialsLocalDataSource]
  CredentialsLocalDataSource(this._storage);

  /// Get credentials from the device storage
  Future<Either<Failure, CredentialsEntity>> get() async {
    final email = await _storage.read(key: "email");
    final password = await _storage.read(key: "password");
    if (email == null || password == null) {
      return left(const Failure.empty());
    }
    return right(CredentialsEntity(email: email, password: password));
  }

  /// Store credentials in device storage
  Future<bool> store(CredentialsEntity credentials) async {
    try {
      await _storage.write(key: "email", value: credentials.email);
      await _storage.write(key: "password", value: credentials.password);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Remove credentials from device storage
  Future<bool> remove() async {
    try {
      await _storage.delete(key: "email");
      await _storage.delete(key: "password");
    } catch (e) {
      return false;
    }
    return true;
  }
}
