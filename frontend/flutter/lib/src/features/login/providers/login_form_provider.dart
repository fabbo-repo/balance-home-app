import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(LoginFormState(LoginForm.empty()));

  void setEmail(String email) {
    final appLocalizations = lookupAppLocalizations(ui.window.locale);
    final isEmail = email.length >= 1;
    LoginForm _form = state.form.copyWith(
      email: StringField(value: email) 
    );
    late StringField emailField;
    if (isEmail) {
      final isEmailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
      ).hasMatch(email);
      if (isEmailValid) {
        emailField = _form.email.copyWith(
          isValid: true, 
          errorMessage: ""
        );
      } else {
        emailField = _form.email.copyWith(
          isValid: false, 
          errorMessage: appLocalizations.emailNotValid);
      }
    } else {
      emailField = _form.email.copyWith(
        isValid: false, 
        errorMessage: appLocalizations.needEmail
      );
    }
    state = state.copyWith(form: _form.copyWith(email: emailField));
  }

  void setPassword(String password) {
    final appLocalizations = lookupAppLocalizations(ui.window.locale);
    final isPassword = password.length >= 1;
    LoginForm _form = state.form.copyWith(
      password: StringField(value: password) 
    );
    late StringField passwordField;
    if (isPassword) {
      passwordField = _form.email.copyWith(
        isValid: true, 
        errorMessage: ""
      );
    } else {
      passwordField = _form.email.copyWith(
        isValid: false, 
        errorMessage: appLocalizations.needPassword
      );
    }
    state = state.copyWith(form: _form.copyWith(
      password: passwordField
    ));
  }
}

final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>(
  (ref) {
    return LoginFormNotifier();
  }
);
