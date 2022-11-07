import 'package:balance_home_app/src/core/forms/string_field.dart';
import 'package:balance_home_app/src/features/login/data/models/email_code_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_code_form.freezed.dart';

@freezed
class EmailCodeForm with _$EmailCodeForm {
  
  const EmailCodeForm._();

  const factory EmailCodeForm(
    {
      required StringField email,
      required StringField code,
    }
  ) = _EmailCodeForm;

  factory EmailCodeForm.empty() => const EmailCodeForm(
    email: StringField(value: ''),
    code: StringField(value: ''),
  );

  bool get isValid => code.isValid;

  EmailCodeModel toModel() {
    return EmailCodeModel(
      email: email.value, 
      code: code.value
    );
  }
}