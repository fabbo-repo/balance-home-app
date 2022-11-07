import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

/// Initial forgot password state
class ForgotPasswordStateInitial extends ForgotPasswordState {
  const ForgotPasswordStateInitial();
}

/// Loading forgot password state
class ForgotPasswordStateLoading extends ForgotPasswordState {
  const ForgotPasswordStateLoading();
}

/// Code sent forgot password state
class ForgotPasswordStateCodeSent extends ForgotPasswordState {
  const ForgotPasswordStateCodeSent();
}

/// Success forgot password state
class ForgotPasswordStateSuccess extends ForgotPasswordState {
  const ForgotPasswordStateSuccess();
}

/// Error forgot password state
class ForgotPasswordStateError extends ForgotPasswordState {
  final String error;

  const ForgotPasswordStateError(this.error);
}

/// Error forgot password state at sending code
class ForgotPasswordStateCodeSentError extends ForgotPasswordStateError {
  const ForgotPasswordStateCodeSentError(super.error);
}

/// Error forgot password state
class ForgotPasswordStateCodeVerifyError extends ForgotPasswordStateError {
  const ForgotPasswordStateCodeVerifyError(super.error);
}