import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/login/data/repositories/forgot_password_repository.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_form_state_notifier.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_state.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_state_notifier.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/forgot_password/forgot_password_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final forgotPasswordFormStateProvider = StateNotifierProvider<ForgotPasswordFormStateProvider, ForgotPasswordFormState>(
  (StateNotifierProviderRef<ForgotPasswordFormStateProvider, ForgotPasswordFormState> ref) {
    AppLocalizations localizations = ref.watch(localizationStateNotifierProvider).localization;
    return ForgotPasswordFormStateProvider(localizations);
  }
);

/// StateNotifier
final forgotPasswordStateNotifierProvider = StateNotifierProvider<ForgotPasswordStateNotifier, ForgotPasswordState>(
  (StateNotifierProviderRef<ForgotPasswordStateNotifier, ForgotPasswordState> ref) {
    AppLocalizations localizations = ref.watch(localizationStateNotifierProvider).localization;
    return ForgotPasswordStateNotifier(
      forgotPasswordRepository: ref.read(forgotPasswordRepositoryProvider),
      localizations: localizations
    );
  }
);

/// Forgot Password Repository
final forgotPasswordRepositoryProvider = Provider<IForgotPasswordRepository>(
  (ProviderRef<IForgotPasswordRepository> ref) => ForgotPasswordRepository(
    httpService: ref.read(httpServiceProvider)
  )
);