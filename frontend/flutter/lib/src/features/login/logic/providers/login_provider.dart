import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/login/data/repositories/jwt_repository.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_form_state_notifier.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_state_notifier.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final loginFormStateProvider = StateNotifierProvider<LoginFormStateProvider, LoginFormState>(
  (StateNotifierProviderRef<LoginFormStateProvider, LoginFormState> ref) {
    AppLocalizations localizations = ref.watch(localizationStateNotifierProvider).localization;
    return LoginFormStateProvider(localizations);
  }
);

/// StateNotifier
final loginStateNotifierProvider = StateNotifierProvider<LoginStateNotifier, AuthState>(
  (StateNotifierProviderRef<LoginStateNotifier, AuthState> ref) => 
  LoginStateNotifier(
    jwtRepository: ref.watch(jwtRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    accountModelStateNotifier: ref.watch(accountStateNotifierProvider.notifier)
  )
);

/// JWT Repository
final jwtRepositoryProvider = Provider<IJwtRepository>(
  (ProviderRef<IJwtRepository> ref) => JwtRepository(
    httpService: ref.read(httpServiceProvider)
  )
);