import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/auth/data/models/account_model.dart';
import 'package:balance_home_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account_model_state_notifier.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';
import 'package:balance_home_app/src/features/login/data/repositories/jwt_repository.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginStateNotifier extends StateNotifier<LoginState> {

  final IJwtRepository _jwtRepository;
  final IAuthRepository _authRepository;
  final AccountModelStateNotifier _accountModelStateNotifier;
  final FlutterSecureStorage _secureStorage;

  LoginStateNotifier({
    required IJwtRepository jwtRepository,
    required IAuthRepository authRepository,
    required AccountModelStateNotifier accountModelStateNotifier,
    FlutterSecureStorage? secureStorage
  }) : _jwtRepository = jwtRepository,
    _authRepository = authRepository,
    _accountModelStateNotifier = accountModelStateNotifier,
    _secureStorage = secureStorage ?? FlutterSecureStorage(),
    super(const LoginStateInitial());
  
  Future<void> updateJwtAndAccount(CredentialsModel credentials) async {
    state = const LoginStateLoading();
    try {
      await _updateJwt(credentials);
      await _updateAccount();
      state = LoginStateSuccess();
    } catch (e) {
      if(e is UnauthorizedHttpException) {
        state = LoginStateError(lookupAppLocalizations(ui.window.locale).wrongCredentials);
      } else {
        state = LoginStateError(lookupAppLocalizations(ui.window.locale).genericError);
      }
    }
  }

  Future<void> trySilentLogin() async {
    try {
      // Read jwt refresh token
      String? refresh = await _secureStorage.read(key: "refresh_token");
      if (refresh != null) {
        JwtModel refresh_jwt = JwtModel(
          access: '', 
          refresh: refresh
        );
        await _refreshJwt(refresh_jwt);
        await _updateAccount();
        state = LoginStateSuccess();
      } else {
        String? email = await _secureStorage.read(key: "email");
        String? password = await _secureStorage.read(key: "password");
        if (email != null && password != null) {
          CredentialsModel credentials = CredentialsModel(
            email: email,
            password: password
          );
          await _updateJwt(credentials);
          await _updateAccount();
          state = LoginStateSuccess();
        }
      }
    } catch (e) { }
  }

  Future<void> _updateJwt(CredentialsModel credentials) async {
    final jwt = await _jwtRepository.getJwt(credentials);
    await _secureStorage.write(key: "email", value: credentials.email);
    await _secureStorage.write(key: "password", value: credentials.password);
    await _secureStorage.write(key: "refresh_token", value: jwt.refresh);
  }

  Future<void> _refreshJwt(JwtModel refresh_jwt) async {
    final jwt = await _jwtRepository.refreshJwt(refresh_jwt);
    await _secureStorage.write(key: "refresh_token", value: jwt.refresh);
  }

  Future<void> _updateAccount() async {
    AccountModel account = await _authRepository.getAccount();
    _accountModelStateNotifier.setAccountModel(account);
  }
}