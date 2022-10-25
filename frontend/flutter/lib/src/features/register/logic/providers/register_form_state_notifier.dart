import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/presentation/forms/login_form.dart';
import 'package:balance_home_app/src/features/register/presentation/forms/register_form.dart';
import 'package:balance_home_app/src/features/register/presentation/forms/register_form_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReisterFormStateProvider extends StateNotifier<RegisterFormState> {
  ReisterFormStateProvider() : super(RegisterFormState(RegisterForm.empty()));

  void setEmail(String email) {
    final appLocalizations = lookupAppLocalizations(ui.window.locale);
    RegisterForm form = state.form.copyWith(
      email: StringField(value: email) 
    );
    late StringField emailField;
    if (email.isNotEmpty) {
      final isEmailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
      ).hasMatch(email);
      if (isEmailValid) {
        emailField = form.email.copyWith(
          isValid: true, 
          errorMessage: ""
        );
      } else {
        emailField = form.email.copyWith(
          isValid: false, 
          errorMessage: appLocalizations.emailNotValid);
      }
    } else {
      emailField = form.email.copyWith(
        isValid: false, 
        errorMessage: appLocalizations.needEmail
      );
    }
    state = state.copyWith(form: form.copyWith(email: emailField));
  }

  void setPassword(String password) {
    final appLocalizations = lookupAppLocalizations(ui.window.locale);
    RegisterForm form = state.form.copyWith(
      password: StringField(value: password) 
    );
    late StringField passwordField;
    if (password.isNotEmpty) {
      passwordField = form.password.copyWith(
        isValid: true, 
        errorMessage: ""
      );
    } else {
      passwordField = form.password.copyWith(
        isValid: false, 
        errorMessage: appLocalizations.needPassword
      );
    }
    state = state.copyWith(form: form.copyWith(
      password: passwordField
    ));
  }
}
