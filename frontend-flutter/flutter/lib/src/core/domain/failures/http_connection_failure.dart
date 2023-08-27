import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';

/// Represents Http connection error
class HttpConnectionFailure extends HttpRequestFailure {
  const HttpConnectionFailure({required String detail})
      : super(detail: detail, statusCode: unknownStatusCode);
}
