import 'package:balance_home_app/src/features/register/presentation/forms/register_form.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_form_state.freezed.dart';

@freezed
class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState(RegisterForm form) = _RegisterFormState;
}