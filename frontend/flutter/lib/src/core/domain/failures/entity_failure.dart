import 'package:freezed_annotation/freezed_annotation.dart';

part 'entity_failure.freezed.dart';

/// Represents all possible entity failures
@freezed
class EntityFailure implements Exception {
  const EntityFailure._();

  /// Expected value is null or empty
  const factory EntityFailure.empty() = _EmptyEntityFailure;

  ///  Expected value has invalid format
  const factory EntityFailure.unprocessableEntity({required String message}) =
      _UnprocessableEntityFailure;

  /// Get the error message for specified failure
  String get error => this is _UnprocessableEntityFailure
      ? (this as _UnprocessableEntityFailure).message
      : '$this';
}
