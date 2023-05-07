import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';

/// Represents a too many Http request error in a specific endpoint
class TooManyRequestFailure extends HttpRequestFailure {
  final String endpoint;

  const TooManyRequestFailure({required this.endpoint})
      : super(statusCode: 429, detail: "");
}
