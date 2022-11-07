import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/login/data/models/email_code_model.dart';
import 'package:balance_home_app/src/features/login/data/repositories/email_code_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailCodeStateNotifier extends StateNotifier<AuthState> {

  final ICodeRepository emailCodeRepository;
  final AppLocalizations localizations;

  EmailCodeStateNotifier({
    required this.emailCodeRepository,
    required this.localizations,
  }) : super(const AuthStateInitial());
  
  Future<void> requestCode(String email) async {
    state = const AuthStateLoading();
    try {
      await emailCodeRepository.requestCode(email);
      state = const AuthStateSuccess();
    } catch (e) {
      if(e is BadRequestHttpException) {
        state = AuthStateError(localizations.errorSendingEmailCode);
      } else {
        state = AuthStateError(localizations.genericError);
      }
    }
  }
  
  Future<void> verifyCode(EmailCodeModel code) async {
    state = const AuthStateLoading();
    try {
      await emailCodeRepository.verifyCode(code);
      state = const AuthStateSuccess();
    } catch (e) {
      if(e is BadRequestHttpException) {
        if (e.content.keys.contains("code") 
          && e.content["code"].contains("Invalid code")) {
          state = AuthStateError(localizations.invalidEmailCode);
          return;
        } else if (e.content.keys.contains("code") 
          && e.content["code"].contains("Code is no longer valid")) {
          state = AuthStateError(localizations.noLongerValidEmailCode);
          return;
        }
        state = AuthStateError(localizations.errorVerifyingEmailCode);
      } else {
        state = AuthStateError(localizations.genericError);
      }
    }
  }
}