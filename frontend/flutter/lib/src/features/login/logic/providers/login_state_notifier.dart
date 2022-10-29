import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/auth/data/models/account_model.dart';
import 'package:balance_home_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account_model_state_notifier.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';
import 'package:balance_home_app/src/features/login/data/repositories/jwt_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginStateNotifier extends StateNotifier<AuthState> {

  final IJwtRepository jwtRepository;
  final IAuthRepository authRepository;
  final AccountModelStateNotifier accountModelStateNotifier;
  final FlutterSecureStorage secureStorage;
  final AppLocalizations localizations;

  LoginStateNotifier({
    required this.jwtRepository,
    required this.authRepository,
    required this.accountModelStateNotifier,
    required this.localizations,
    FlutterSecureStorage? secureStorage
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage(),
    super(const AuthStateInitial());
  
  Future<void> updateJwtAndAccount(CredentialsModel credentials) async {
    state = const AuthStateLoading();
    try {
      await _updateJwt(credentials);
      await _updateAccount();
      state = const AuthStateSuccess();
    } catch (e) {
      if(e is UnauthorizedHttpException) {
        state = AuthStateError(localizations.wrongCredentials);
      } else {
        state = AuthStateError(localizations.genericError);
      }
    }
  }

  Future<void> trySilentLogin() async {
    try {
      // Read jwt refresh token
      String? refresh = await secureStorage.read(key: "refresh_token");
      if (refresh != null) {
        JwtModel refreshJwt = JwtModel(
          access: '', 
          refresh: refresh
        );
        await _refreshJwt(refreshJwt);
        await _updateAccount();
        state = const AuthStateSuccess();
      } else {
        String? email = await secureStorage.read(key: "email");
        String? password = await secureStorage.read(key: "password");
        if (email != null && password != null) {
          CredentialsModel credentials = CredentialsModel(
            email: email,
            password: password
          );
          await _updateJwt(credentials);
          await _updateAccount();
          state = const AuthStateSuccess();
        }
      }
    } catch (e) {
      debugPrint("[SILENT_LOGIN_ERROR] ${e.toString()}");
    }
  }

  Future<void> _updateJwt(CredentialsModel credentials) async {
    final jwt = await jwtRepository.getJwt(credentials);
    await secureStorage.write(key: "email", value: credentials.email);
    await secureStorage.write(key: "password", value: credentials.password);
    await secureStorage.write(key: "refresh_token", value: jwt.refresh);
  }

  Future<void> _refreshJwt(JwtModel refreshJwt) async {
    final jwt = await jwtRepository.refreshJwt(refreshJwt);
    await secureStorage.write(key: "refresh_token", value: jwt.refresh);
  }

  Future<void> _updateAccount() async {
    AccountModel account = await authRepository.getAccount();
    accountModelStateNotifier.setAccountModel(account);
  }
}