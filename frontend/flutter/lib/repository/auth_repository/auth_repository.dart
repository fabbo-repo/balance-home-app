
import 'package:balance_home_app/services/auth_service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<String> login(String email, String password) async {
    return _authService.login(email, password);
  }
}

final authRepositoryProvider = Provider<AuthRepository> (
  (ref) {
    return AuthRepository(ref.read(authServiceProvider));
  }
);