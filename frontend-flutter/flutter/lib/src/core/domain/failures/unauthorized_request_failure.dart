import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';

/// Represent 401 error
class UnauthorizedRequestFailure extends HttpRequestFailure {
  const UnauthorizedRequestFailure({required String detail})
      : super(statusCode: 401, detail: detail);
}