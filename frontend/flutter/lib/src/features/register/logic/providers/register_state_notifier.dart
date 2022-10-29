import 'dart:developer';

import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account_model_state_notifier.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/register/data/models/register_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterStateNotifier extends StateNotifier<AuthState> {

  final IAuthRepository authRepository;
  final FlutterSecureStorage secureStorage;
  final AppLocalizations localizations;

  RegisterStateNotifier({
    required this.authRepository,
    required AccountModelStateNotifier accountModelStateNotifier,
    required this.localizations,
    FlutterSecureStorage? secureStorage
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage(),
    super(const AuthStateInitial());
  
  Future<void> createAccount(RegisterModel registration) async {
    state = const AuthStateLoading();
    try {
      await _createAccount(registration);
      state = const AuthStateSuccess();
    } catch (e) {
      if(e is BadRequestHttpException) {
        if (e.content.keys.contains("password")) {
          String firstError = e.content.keys.first;
          if (e.content[firstError].first.contains("too common")) {
            state = AuthStateError(localizations.tooCommonPassword);
            return;
          } 
        }
      } 
      state = AuthStateError(localizations.genericError);
    }
  }

  Future<void> _createAccount(RegisterModel registration) async {
    await authRepository.createAccount(registration);
    await secureStorage.write(key: "email", value: registration.email);
    await secureStorage.write(key: "password", value: registration.password);
  }
}