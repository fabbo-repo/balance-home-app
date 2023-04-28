import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bad_request_failure.g.dart';

/// Represents 400 error
@JsonSerializable(fieldRename: FieldRename.snake)
class BadRequestFailure extends HttpRequestFailure {
  @JsonKey(defaultValue: -1) 
  final int errorCode;

  const BadRequestFailure({required String detail, required this.errorCode})
      : super(statusCode: 400, detail: detail);

  // Serialization
  factory BadRequestFailure.fromJson(Map<String, dynamic> json) =>
      _$BadRequestFailureFromJson(json);
}
