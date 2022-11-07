import 'package:balance_home_app/src/features/login/presentation/forms/forgot_password/forgot_password_form.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_form_state.freezed.dart';

@freezed
class ForgotPasswordFormState with _$ForgotPasswordFormState {
  const factory ForgotPasswordFormState(ForgotPasswordForm form) = _ForgotPasswordFormState;
}