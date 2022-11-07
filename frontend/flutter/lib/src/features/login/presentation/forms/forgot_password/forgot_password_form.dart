import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/data/models/forgot_password_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_form.freezed.dart';

@freezed
class ForgotPasswordForm with _$ForgotPasswordForm {
  
  const ForgotPasswordForm._();

  const factory ForgotPasswordForm(
    {
      required StringField email,
      required StringField code,
      required StringField password,
      required StringField password2,
    }
  ) = _ForgotPasswordForm;

  factory ForgotPasswordForm.empty() => const ForgotPasswordForm(
    email: StringField(value: ''), 
    code: StringField(value: ''), 
    password: StringField(value: ''),
    password2: StringField(value: ''),
  );

  bool get isValid => email.isValid && code.isValid && password.isValid && password2.isValid;

  ForgotPasswordModel toModel() {
    return ForgotPasswordModel(
      code: code.value,
      email: email.value, 
      newPassword: password.value
    );
  }
}