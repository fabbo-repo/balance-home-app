import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account_model_state_notifier.dart';
import 'package:balance_home_app/src/features/login/data/repositories/jwt_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/register/data/models/register_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterStateNotifier extends StateNotifier<AuthState> {

  final IAuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;

  RegisterStateNotifier({
    required IAuthRepository authRepository,
    required AccountModelStateNotifier accountModelStateNotifier,
    FlutterSecureStorage? secureStorage
  }) : _authRepository = authRepository,
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    super(const AuthStateInitial());
  
  Future<void> createAccount(RegisterModel registration) async {
    state = const AuthStateLoading();
    try {
      await _createAccount(registration);
      state = const AuthStateSuccess();
    } catch (e) {
      if(e is UnauthorizedHttpException) {
        state = AuthStateError(lookupAppLocalizations(ui.window.locale).wrongCredentials);
      } else {
        state = AuthStateError(lookupAppLocalizations(ui.window.locale).genericError);
      }
    }
  }

  Future<void> _createAccount(RegisterModel registration) async {
    await _authRepository.createAccount(registration);
    await _secureStorage.write(key: "email", value: registration.email);
    await _secureStorage.write(key: "password", value: registration.password);
  }
}