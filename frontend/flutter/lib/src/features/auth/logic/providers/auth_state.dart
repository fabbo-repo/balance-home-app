import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial auth state
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Loading auth state
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// Success auth state
class AuthStateSuccess extends AuthState {
  const AuthStateSuccess();
}

/// Error auth state
class AuthStateError extends AuthState {
  final String error;

  const AuthStateError(this.error);
}