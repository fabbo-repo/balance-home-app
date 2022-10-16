import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState extends _$LoginState {
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