import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_failure.freezed.dart';

/// Represents all possible http failures
@freezed
class HttpFailure implements Exception {
  const HttpFailure._();

  /// Expected value is null or empty
  const factory HttpFailure.empty() = _EmptyHttpFailure;

  /// Represent 401 error
  const factory HttpFailure.unauthorized({required String message}) = _UnauthorizedHttpFailure;

  /// Represents 400 error
  const factory HttpFailure.badRequest({required String message}) = _BadRequestHttpFailure;
  
  /// Represents 500 error
  const factory HttpFailure.serverError({required String message}) = _ServerErrorHttpFailure;

  /// Get the error message for specified failure

  String get error => this is _UnauthorizedHttpFailure
      ? (this as _UnauthorizedHttpFailure).message
      : this is _BadRequestHttpFailure
      ? (this as _BadRequestHttpFailure).message
      : '$this';
}
