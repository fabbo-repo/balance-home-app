import 'package:balance_home_app/src/core/domain/failures/failure.dart';

/// Represents Http request error
class HttpRequestFailure extends Failure {
  final int statusCode;
  final String detail;

  const HttpRequestFailure({required this.statusCode, required this.detail});
}
