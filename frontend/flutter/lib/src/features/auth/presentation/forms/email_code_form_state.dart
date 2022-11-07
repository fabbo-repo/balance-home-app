import 'package:balance_home_app/src/features/auth/presentation/forms/email_code_form.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_code_form_state.freezed.dart';

@freezed
class EmailCodeFormState with _$EmailCodeFormState {
  const factory EmailCodeFormState(EmailCodeForm form) = _EmailCodeFormState;
}