import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
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
      final result = await _loginRepository.getJwt(credentials);
      state = LoginState.data(jwtModel: result);
    } catch (_) {
      state = LoginState.error("Error!");
    }
  }

  Future<void> tryLogin() async {
    state = const LoginState.loading();
    try {
      // Read jwt credentials
      String? access_token = await _secureStorage.read(key: "access_token");
      String? refresh_token = await _secureStorage.read(key: "refresh_token");
      if (access_token != null && refresh_token != null) {
        
      }
      String? email = await _secureStorage.read(key: "email");
      String? password = await _secureStorage.read(key: "password");
      //final result = await _loginRepository.getJwt(credentials);
      state = LoginState.data(jwtModel: result);
    } catch (_) {
      state = LoginState.error("Error!");
    }
  }
}