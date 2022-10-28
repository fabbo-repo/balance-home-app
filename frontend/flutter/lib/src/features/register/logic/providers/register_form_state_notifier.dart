import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/register/presentation/forms/register_form.dart';
import 'package:balance_home_app/src/features/register/presentation/forms/register_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterFormStateProvider extends StateNotifier<RegisterFormState> {

  final AppLocalizations localizations;

  RegisterFormStateProvider(this.localizations) : super(RegisterFormState(RegisterForm.empty()));

  void setUsername(String username) {
    final appLocalizations = localizations;
    RegisterForm form = state.form.copyWith(username: StringField(value: username));
    late StringField usernameField;
    if (username.isEmpty) {
      usernameField = form.username.copyWith(isValid: false, 
        errorMessage: appLocalizations.needUsername
      );
    } else if (username.length > 15) {
      usernameField = form.username.copyWith(isValid: false, 
        errorMessage: appLocalizations.usernameMaxSize
      );
    } else if (!RegExp(r"^[A-Za-z0-9]+$").hasMatch(username)) {
      usernameField = form.username.copyWith(isValid: false, 
        errorMessage: appLocalizations.usernameNotValid
      );
    } else {
      usernameField = form.username.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(username: usernameField));
  }

  void setEmail(String email) {
    final appLocalizations = localizations;
    RegisterForm form = state.form.copyWith(email: StringField(value: email));
    late StringField emailField;
    if (email.isEmpty) {
      emailField = form.email.copyWith(isValid: false, 
        errorMessage: appLocalizations.needEmail
      );
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      emailField = form.email.copyWith(isValid: false, 
        errorMessage: appLocalizations.emailNotValid
      );
    } else {
      emailField = form.email.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(email: emailField));
  }

  void setPassword(String password) {
    final appLocalizations = localizations;
    RegisterForm form = state.form.copyWith(password: StringField(value: password));
    late StringField passwordField;
    if (password.isEmpty) {
      passwordField = form.password.copyWith(isValid: false, 
        errorMessage: appLocalizations.needPassword);
    } else {
      passwordField = form.password.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(password: passwordField));
  }
  
  void setPassword2(String password2) {
    final appLocalizations = localizations;
    RegisterForm form = state.form.copyWith(password2: StringField(value: password2));
    late StringField password2Field;
    if (password2.isEmpty) {
      password2Field = form.password2.copyWith(isValid: false, 
        errorMessage: appLocalizations.needRepeatedPassword);
    } else if (password2 != state.form.password.value) {
      password2Field = form.password2.copyWith(isValid: false, 
        errorMessage: appLocalizations.passwordNotMatch);
    } else {
      password2Field = form.password2.copyWith(isValid: true, errorMessage: "");
    }
    state = state.copyWith(form: form.copyWith(password: password2Field));
  }
}
