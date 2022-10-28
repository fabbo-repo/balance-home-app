import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/register/logic/providers/register_form_state_notifier.dart';
import 'package:balance_home_app/src/features/register/logic/providers/register_state_notifier.dart';
import 'package:balance_home_app/src/features/register/presentation/forms/register_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final registerFormStateProvider = StateNotifierProvider<RegisterFormStateProvider, RegisterFormState>(
  (StateNotifierProviderRef<RegisterFormStateProvider, RegisterFormState> ref) {
    AppLocalizations localizations = ref.watch(localizationStateNotifierProvider).localization;
    return RegisterFormStateProvider(localizations);
  }
);

/// StateNotifier
final registerStateNotifierProvider = StateNotifierProvider<RegisterStateNotifier, AuthState>(
  (StateNotifierProviderRef<RegisterStateNotifier, AuthState> ref) => 
  RegisterStateNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    accountModelStateNotifier: ref.watch(accountStateNotifierProvider.notifier)
  )
);