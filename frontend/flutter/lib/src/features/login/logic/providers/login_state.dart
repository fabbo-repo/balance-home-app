import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

/// Initial login state
class LoginStateInitial extends LoginState {
  const LoginStateInitial();
}

/// Loading login state
class LoginStateLoading extends LoginState {
  const LoginStateLoading();
}

/// Success login state
class LoginStateSuccess extends LoginState {
  const LoginStateSuccess();
}

/// Error login state
class LoginStateError extends LoginState {
  final String error;

  const LoginStateError(this.error);
}