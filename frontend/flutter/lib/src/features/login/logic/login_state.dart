import 'package:balance_home_app/src/features/login/data/models/account_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  // Initial
  const factory LoginState.initial() = _LoginStateInitial;
  
  // Loading
  const factory LoginState.loading() = _LoginStateLoading;

  // Data
  const factory LoginState.data(
    {
      required AccountModel account
    }) = _LoginStateData;

  // Error
  const factory LoginState.error([String? error]) = _LoginStateError;
}