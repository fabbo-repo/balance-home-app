
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unauthorized_request_failure.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class FailureUtils {
  static Either<Failure, Map<String, dynamic>> checkResponse({required Map<String, dynamic> body, required int statusCode}) {
    if ((statusCode/10).round() == 20) {
      return right(body);
    }
    else if (statusCode == 400) {
      return left(BadRequestFailure.fromJson(body));
    }
    else if (statusCode == 401) {
      return left(UnauthorizedRequestFailure.fromJson(body));
    }
    debugPrint("Unknown HttpFailure: $body");
    return left(HttpRequestFailure(detail: '', statusCode: statusCode));
  }
}