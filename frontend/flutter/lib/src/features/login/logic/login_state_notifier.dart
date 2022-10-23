import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';
import 'package:balance_home_app/src/features/login/data/repositories/login_repository.dart';
import 'package:balance_home_app/src/features/login/logic/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginStateNotifier extends StateNotifier<LoginState> {
  
  final ILoginRepository _loginRepository;

  final FlutterSecureStorage _secureStorage;

  LoginStateNotifier({
    required ILoginRepository loginRepository,
    FlutterSecureStorage? secureStorage
  }) : _loginRepository = loginRepository,
    _secureStorage = secureStorage ?? FlutterSecureStorage(),
    super(const LoginState.initial());
  
  Future<void> getJwt(CredentialsModel credentials) async {
    state = const LoginState.loading();
    try {
      final jwt = await _loginRepository.getJwt(credentials);
      state = LoginState.data(jwtModel: jwt);
    } catch (_) {
      state = LoginState.error("Error!");
    }
  }

  Future<void> tryLogin() async {
    state = const LoginState.loading();
    try {
      // Read jwt refresh token
      String? refresh = await _secureStorage.read(key: "refresh_token");
      if (refresh != null) {
        JwtModel refresh_jwt = JwtModel(
          access: '', 
          refresh: refresh
        );
        final jwt = await _loginRepository.refreshJwt(refresh_jwt);
        state = LoginState.data(jwtModel: jwt);
      }
      else {
        String? email = await _secureStorage.read(key: "email");
        String? password = await _secureStorage.read(key: "password");
        if (email != null && password != null) {
          CredentialsModel credentials = CredentialsModel(
            email: email,
            password: password
          );
          final jwt = await _loginRepository.getJwt(credentials);
        }
      }
    } catch (_) {
      state = LoginState.error("Error!");
    }
  }
}