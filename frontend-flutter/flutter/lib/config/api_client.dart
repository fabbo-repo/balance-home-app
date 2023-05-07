import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/config/environment.dart';
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/too_many_requests_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unauthorized_request_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:universal_io/io.dart';

const unknownStatusCode = 600;

/// Provides a [ValueNotifier] to the app to check http connection state 
final connectionStateListenable = ValueNotifier<bool>(true);

class ApiClient {
  @visibleForTesting
  late final Dio dioClient;
  final bool displayRequestLogs;
  final bool displayResponseLogs;
  JwtEntity? jwtToken;

  final BaseOptions options = BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 15000),
      receiveTimeout: const Duration(seconds: 15000),
      sendTimeout: const Duration(seconds: 15000),
      followRedirects: false,
      validateStatus: (status) => true,
      headers: {
        "content-type": ContentType.json.toString(),
        "accept": ContentType.json.toString(),
      });

  ApiClient(
      {Dio? dio,
      this.displayRequestLogs = false,
      this.displayResponseLogs = false}) {
    dioClient = dio ?? Dio();
    dioClient.options = options;
  }

  @visibleForTesting
  void setHeader(String key, String value) async {
    dioClient.options.headers[key] = value;
  }

  @visibleForTesting
  void removeHeader(String key) async {
    dioClient.options.headers.remove(key);
  }

  void setLanguage(String localeName) async {
    setHeader("accept-language", localeName);
  }

  void setJwt(JwtEntity jwt) {
    jwtToken = jwt;
    if (jwt.access != null && JwtDecoder.tryDecode(jwt.access!) != null) {
      setHeader("authorization", "Bearer ${jwt.access}");
    }
  }

  void removeJwt() {
    removeHeader("authorization");
  }

  @visibleForTesting
  Either<HttpRequestFailure, Response> checkFailureOrResponse(
      {required String path, required Response response}) {
    connectionStateListenable.value = true;
    if (displayResponseLogs) logResponse(response);
    if (((response.statusCode ?? unknownStatusCode) / 10).round() == 20) {
      return right(response);
    } else if (response.statusCode == 400) {
      return left(BadRequestFailure.fromJson(response.data));
    } else if (response.statusCode == 401) {
      return left(UnauthorizedRequestFailure.fromJson(response.data));
    } else if (response.statusCode == 429) {
      return left(TooManyRequestFailure(endpoint: path));
    }
    debugPrint("[HTTP CHECK] Unknown HttpFailure: ${response.data}");
    return left(HttpRequestFailure(
        detail: '', statusCode: response.statusCode ?? unknownStatusCode));
  }

  @visibleForTesting
  Future<void> checkAccessJwt() async {
    if (jwtToken != null &&
        jwtToken!.access != null &&
        jwtToken!.access!.isNotEmpty &&
        jwtToken!.refresh != null &&
        jwtToken!.refresh!.isNotEmpty &&
        JwtDecoder.isExpired(jwtToken!.access!)) {
      final res = await dioClient
          .post(APIContract.jwtRefresh, data: {"refresh": jwtToken!.refresh});
      checkFailureOrResponse(path: APIContract.jwtRefresh, response: res)
          .fold((_) => null, (value) {
        setJwt(jwtToken!.copyWith(access: value.data["access"]));
      });
    }
  }

  @visibleForTesting
  void logRequest(String path, String method) {
    debugPrint("[HTTP REQUEST] $method ${dioClient.options.baseUrl} - $path "
        "| Headers: ${dioClient.options.headers}");
  }

  @visibleForTesting
  void logResponse(Response response) {
    debugPrint(
        "[HTTP RESPONSE] ${response.data} | Headers: ${response.headers}");
  }

  @visibleForTesting
  HttpConnectionFailure handleConnectionError(final Exception error) {
    debugPrint("[HTTP ERROR] $error");
    connectionStateListenable.value = false;
    return HttpConnectionFailure(detail: error.toString());
  }

  Future<Either<HttpRequestFailure, Response>> getRequest(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      if (displayRequestLogs) logRequest(path, "GET");
      await checkAccessJwt();
      final res = await dioClient.get(path, queryParameters: queryParameters);
      return checkFailureOrResponse(path: path, response: res);
    } on Exception catch (error) {
      return left(handleConnectionError(error));
    }
  }

  Future<Either<HttpRequestFailure, Response>> postRequest(String path,
      {Object? data}) async {
    try {
      if (displayRequestLogs) logRequest(path, "POST");
      await checkAccessJwt();
      final res = await dioClient.post(path, data: data);
      return checkFailureOrResponse(path: path, response: res);
    } on Exception catch (error) {
      return left(handleConnectionError(error));
    }
  }

  Future<Either<HttpRequestFailure, Response>> putRequest(String path,
      {Object? data}) async {
    try {
      if (displayRequestLogs) logRequest(path, "PUT");
      await checkAccessJwt();
      final res = await dioClient.put(path, data: data);
      return checkFailureOrResponse(path: path, response: res);
    } on Exception catch (error) {
      return left(handleConnectionError(error));
    }
  }

  Future<Either<HttpRequestFailure, Response>> patchRequest(String path,
      {Object? data}) async {
    try {
      if (displayRequestLogs) logRequest(path, "PATCH");
      await checkAccessJwt();
      final res = await dioClient.patch(path, data: data);
      return checkFailureOrResponse(path: path, response: res);
    } on Exception catch (error) {
      return left(handleConnectionError(error));
    }
  }

  Future<Either<HttpRequestFailure, Response>> patchImageRequest(
      String path, Uint8List bytes, String type) async {
    if (displayRequestLogs) debugPrint("[HTTP REQUEST] Sending image...");
    FormData data = FormData.fromMap({
      "image": MultipartFile.fromBytes(bytes,
          filename: 'upload_image.${type.split("/").last}',
          contentType: MediaType("image", type)),
    });
    return await patchRequest(path, data: data);
  }

  Future<Either<HttpRequestFailure, Response>> delRequest(String path) async {
    try {
      if (displayRequestLogs) logRequest(path, "DEL");
      await checkAccessJwt();
      final res = await dioClient.delete(path);
      return checkFailureOrResponse(path: path, response: res);
    } on Exception catch (error) {
      return left(handleConnectionError(error));
    }
  }
}
