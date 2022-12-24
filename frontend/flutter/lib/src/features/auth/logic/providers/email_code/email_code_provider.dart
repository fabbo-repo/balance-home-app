import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/email_code/email_code_form_state_notifier.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/email_code/email_code_state_notifier.dart';
import 'package:balance_home_app/src/features/auth/presentation/forms/email_code_form_state.dart';
import 'package:balance_home_app/src/features/login/data/repositories/email_code_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final emailCodeFormStateProvider = StateNotifierProvider<EmailCodeFormStateProvider, EmailCodeFormState>(
  (StateNotifierProviderRef<EmailCodeFormStateProvider, EmailCodeFormState> ref) {
    AppLocalizations localizations = ref.watch(appLocalizationsProvider);
    return EmailCodeFormStateProvider(localizations);
  }
);

/// StateNotifier
final emailCodeStateNotifierProvider = StateNotifierProvider<EmailCodeStateNotifier, AuthState>(
  (StateNotifierProviderRef<EmailCodeStateNotifier, AuthState> ref) {
    AppLocalizations localizations = ref.watch(appLocalizationsProvider);
    return EmailCodeStateNotifier(
      localizations: localizations,
      emailCodeRepository: ref.watch(emailCodeRepositoryProvider)
    );
  }
);

/// Email Code Repository
final emailCodeRepositoryProvider = Provider<ICodeRepository>(
  (ProviderRef<ICodeRepository> ref) => EmailCodeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);