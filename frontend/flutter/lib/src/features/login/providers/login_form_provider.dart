import 'package:balance_home_app/src/core/validations/string_field.dart';
import 'package:balance_home_app/src/features/login/form/login_form.dart';
import 'package:balance_home_app/src/features/login/form/login_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(LoginFormState(LoginForm.empty()));

  void setEmail(String email) {
    final isEmail = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    ).hasMatch(email);
    
    LoginForm _form = state.form.copyWith(
      email: StringField(value: email) 
    );

    late StringField emailField;

    if (isEmail) {
      emailField = _form.email.copyWith(isValid: true, errorMessage: "");
    } else {
      emailField = _form.email.copyWith(isValid: false, errorMessage: "Email is not valid");
    }
    state = state.copyWith(form: _form.copyWith(email: emailField));
  }
}

final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>(
  (ref) {
    return LoginFormNotifier();
  }
);
