import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/features/login/data/models/forgot_password_model.dart';
import 'package:balance_home_app/src/features/login/data/repositories/forgot_password_repository.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordStateNotifier extends StateNotifier<ForgotPasswordState> {

  final IForgotPasswordRepository forgotPasswordRepository;
  final AppLocalizations localizations;

  ForgotPasswordStateNotifier({
    required this.forgotPasswordRepository,
    required this.localizations
  }) : super(const ForgotPasswordStateInitial());
  
  Future<void> requestCode(String email) async {
    state = const ForgotPasswordStateLoading();
    try {
      await forgotPasswordRepository.requestCode(email);
      state = const ForgotPasswordStateCodeSent();
    } catch (e) {
      if(e is BadRequestHttpException) {
        if (e.content.keys.contains("email") 
          && e.content["email"].contains("User not found")) {
          state = ForgotPasswordStateCodeSentError(localizations.emailNotValid);
          return;
        } else if (e.content.keys.contains("code") 
          && e.content["code"].first.contains("Code has already been sent")) {  
          state = ForgotPasswordStateCodeSentError(localizations.errorSendingCodeTime.replaceFirst(
            "{}", e.content["code"].first.split(" ")[6].split(".")[0]));
          return;
        }
        state = ForgotPasswordStateCodeSentError(localizations.errorSendingCode);
      } else {
        state = ForgotPasswordStateError(localizations.genericError);
      }
    }
  }

  Future<void> verifyCode(ForgotPasswordModel model) async {
    state = const ForgotPasswordStateLoading();
    try {
      await forgotPasswordRepository.verifyCode(model);
      state = const ForgotPasswordStateSuccess();
    } catch (e) {
      if(e is BadRequestHttpException) {
        if (e.content.keys.contains("code") 
          && e.content["code"].contains("Invalid code")) {
          state = ForgotPasswordStateCodeVerifyError(localizations.invalidCode);
          return;
        } else if (e.content.keys.contains("code") 
          && e.content["code"].contains("Code is no longer valid")) {
          state = ForgotPasswordStateCodeVerifyError(localizations.noLongerValidCode);
          return;
        } else if (e.content.keys.contains("new_password")) {
          if (e.content["new_password"].first.contains("too common")) {
            state = ForgotPasswordStateCodeVerifyError(localizations.tooCommonPassword);
            return;
          } 
        }
        state = ForgotPasswordStateCodeVerifyError(localizations.errorVerifyingCode);
      } else {
        state = ForgotPasswordStateError(localizations.genericError);
      }
    }
  }

  void setHasCodeSent() {
    state = const ForgotPasswordStateCodeSent();
  }
}