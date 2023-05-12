import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bad_request_failure.g.dart';

/// Represents 400 request error
@JsonSerializable(fieldRename: FieldRename.snake)
class BadRequestFailure extends HttpRequestFailure {
  const BadRequestFailure({required String detail})
      : super(statusCode: 400, detail: detail);

  // Serialization
  factory BadRequestFailure.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("error_code")) {
      return ApiBadRequestFailure.fromJson(json);
    } else if (json.containsKey("fields")) {
      return InputBadRequestFailure.fromJson(json);
    }
    return _$BadRequestFailureFromJson(json);
  }
}
