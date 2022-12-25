import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/register/domain/entities/register_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_form.freezed.dart';

@freezed
class RegisterForm with _$RegisterForm {
  
  const RegisterForm._();

  const factory RegisterForm(
    {
      required StringField username,
      required StringField email,
      required StringField password,
      required StringField password2,
      required StringField invCode,
      required StringField language,
      required StringField prefCoinType,
    }
  ) = _RegisterForm;

  factory RegisterForm.empty() => const RegisterForm(
    username: StringField(value: ''), 
    email: StringField(value: ''), 
    password: StringField(value: ''), 
    password2: StringField(value: ''),
    invCode: StringField(value: ''),
    language: StringField(value: ''),
    prefCoinType: StringField(value: ''),
  );

  bool get isValid => email.isValid && password.isValid;

  RegisterEntity toModel() {
    return RegisterEntity(
      username: username.value,
      email: email.value, 
      password: password.value,
      password2: password2.value,
      invCode: invCode.value,
      language: language.value,
      prefCoinType: prefCoinType.value
    );
  }
}