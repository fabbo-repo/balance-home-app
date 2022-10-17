import 'package:balance_home_app/src/services/auth_services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginRepository {
  final AuthService _authService;

  LoginRepository(this._authService);

  Future<String> login(String email, String password) async {
    return _authService.login(email, password);
  }
}

final loginProvider = Provider<LoginRepository> (
  (ref) {
    return LoginRepository(ref.read(authServiceProvider));
  }
);