import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormStateProvider extends StateNotifier<LoginFormState> {

  final AppLocalizations localizations;

  LoginFormStateProvider(this.localizations) : super(LoginFormState(LoginForm.empty()));

  void setEmail(String email) {
    LoginForm form = state.form.copyWith(email: StringField(value: email));
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
    LoginForm form = state.form.copyWith(password: StringField(value: password));
    late StringField passwordField;
    if (password.isEmpty) {
      passwordField = form.password.copyWith(isValid: false, 
        errorMessage: localizations.needPassword);
    } else {
      passwordField = form.password.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(password: passwordField));
  }
}
