import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/forgot_password/forgot_password_form.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/forgot_password/forgot_password_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordFormStateProvider extends StateNotifier<ForgotPasswordFormState> {

  final AppLocalizations localizations;

  ForgotPasswordFormStateProvider(this.localizations) : super(ForgotPasswordFormState(ForgotPasswordForm.empty()));

  void setCode(String code) {
    ForgotPasswordForm form = state.form.copyWith(code: StringField(value: code));
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
    ForgotPasswordForm form = state.form.copyWith(email: StringField(value: email));
    late StringField emailField;
    if (email.isEmpty) {
      emailField = form.email.copyWith(isValid: false, 
        errorMessage: localizations.needEmail
      );
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      emailField = form.email.copyWith(isValid: false, 
        errorMessage: localizations.emailNotValid
      );
    } else {
      emailField = form.email.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(email: emailField));
  }

  void setPassword(String password) {
    ForgotPasswordForm form = state.form.copyWith(password: StringField(value: password));
    late StringField passwordField;
    if (password.isEmpty) {
      passwordField = form.password.copyWith(isValid: false, 
        errorMessage: localizations.needPassword);
    } else {
      passwordField = form.password.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(password: passwordField));
  }
  
  void setPassword2(String password2) {
    ForgotPasswordForm form = state.form.copyWith(password2: StringField(value: password2));
    late StringField password2Field;
    if (password2.isEmpty) {
      password2Field = form.password2.copyWith(isValid: false, 
        errorMessage: localizations.needRepeatedPassword);
    } else if (password2 != state.form.password.value) {
      password2Field = form.password2.copyWith(isValid: false, 
        errorMessage: localizations.passwordNotMatch);
    } else {
      password2Field = form.password2.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(password2: password2Field));
  }

  void setCodeError(String error) {
    StringField codeField = state.form.code.copyWith(
      isValid: false, errorMessage: error);
    state = state.copyWith(form: state.form.copyWith(code: codeField));
  }
}
