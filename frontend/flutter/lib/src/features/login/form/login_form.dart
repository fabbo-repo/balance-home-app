import 'package:balance_home_app/src/core/validations/string_field.dart';
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
}