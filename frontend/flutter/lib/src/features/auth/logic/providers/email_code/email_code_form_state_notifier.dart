import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/auth/presentation/forms/email_code_form.dart';
import 'package:balance_home_app/src/features/auth/presentation/forms/email_code_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailCodeFormStateProvider extends StateNotifier<EmailCodeFormState> {

  final AppLocalizations localizations;

  EmailCodeFormStateProvider(this.localizations) : super(EmailCodeFormState(EmailCodeForm.empty()));

  void setCode(String code) {
    EmailCodeForm form = state.form.copyWith(code: StringField(value: code));
    late StringField codeField;
    if (code.length != 6) {
      codeField = form.code.copyWith(isValid: false, 
        errorMessage: localizations.codeSixLength
      );
    } else {
      codeField = form.code.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(code: codeField));
  }

  void setEmail(String email) {
    EmailCodeForm form = state.form.copyWith(email: StringField(value: email));
    StringField emailField = form.email.copyWith(isValid: true, errorMessage: "");
    state = state.copyWith(form: form.copyWith(email: emailField));
  }

  void setCodeError(String error) {
    StringField codeField = state.form.code.copyWith(
      isValid: false, errorMessage: error);
    state = state.copyWith(form: state.form.copyWith(code: codeField));
  }
}
