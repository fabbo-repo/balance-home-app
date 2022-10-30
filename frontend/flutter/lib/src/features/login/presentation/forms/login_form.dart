import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_form.freezed.dart';

@freezed
class LoginForm with _$LoginForm {
  
  const LoginForm._();

  const factory LoginForm(
    {
      required StringField email,
      required StringField password,
    }
  ) = _LoginForm;

  factory LoginForm.empty() => const LoginForm(
    email: StringField(value: ''), 
    password: StringField(value: ''),
  );

  bool get isValid => email.isValid && password.isValid;

  CredentialsModel toModel() {
    return CredentialsModel(
      email: email.value, 
      password: password.value
    );
  }
}