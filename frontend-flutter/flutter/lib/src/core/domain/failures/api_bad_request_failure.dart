import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_bad_request_failure.g.dart';

/// Represents an specific api error in a bad request
@JsonSerializable(fieldRename: FieldRename.snake)
class ApiBadRequestFailure extends BadRequestFailure {
  @JsonKey(defaultValue: -1)
  final int errorCode;

  const ApiBadRequestFailure({required String detail, required this.errorCode})
      : super(detail: detail);

  // Serialization
  factory ApiBadRequestFailure.fromJson(Map<String, dynamic> json) =>
      _$ApiBadRequestFailureFromJson(json);
}
