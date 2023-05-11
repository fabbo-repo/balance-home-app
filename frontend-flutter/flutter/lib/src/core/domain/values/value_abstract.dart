import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Provides specification for value objects
abstract class ValueAbstract<T> {
  ///
  const ValueAbstract();

  /// getter for value
  Either<Failure, T> get value;

  /// Form validate handler, return error message in case of Failure
  String? get validate =>
      value.fold((failure) => failure.detail, (value) => null);
}
