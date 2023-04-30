import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:fpdart/fpdart.dart';

/// Provides specification for value objects
abstract class ValueAbstract<T> {
  ///
  const ValueAbstract();

  /// getter for value
  Either<Failure, T> get value;

  /// Form validate handler, return error message in case of Failure
  String? get validate => value.fold(
      (failure) => failure is HttpRequestFailure
          ? failure.detail
          : failure is UnprocessableEntityFailure
              ? failure.message
              : "",
      (value) => null);
}
