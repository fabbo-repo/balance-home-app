import 'package:balance_home_app/src/features/login/form/login_form.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_form_state.freezed.dart';

@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState(LoginForm form) = _LoginFormState;
}