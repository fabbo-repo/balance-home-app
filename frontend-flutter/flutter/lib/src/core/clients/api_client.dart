import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/config/app_environment.dart';
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

/// The `ApiClient` class is responsible for managing the connection
/// and making REST API requests.
class ApiClient {
  @visibleForTesting
  late final Dio dioClient;
  @visibleForTesting
  final bool displayRequestLogs;
  @visibleForTesting
  final bool displayResponseLogs;
  @visibleForTesting
  JwtEntity? jwtToken;

  final BaseOptions options = BaseOptions(
      baseUrl: AppEnvironment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      followRedirects: false,
      validateStatus: (status) => true,
      headers: {
        "content-type": ContentType.json.toString(),
        "accept": ContentType.json.toString(),
      });

  /// Creates an instance of `ApiClient` with the Dio client as optional.
  /// The Dio client is used to make requests to the API.
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

  /// Handles the HTTP status codes of the responses.
  /// Returns the correct Failures or, in case it went well, returns the response itself.
  ///
  /// HTTP status codes cases:
  /// * 20X code: `Response`
  /// * 400 code: `BadRequestFailure`
  /// * 401 code: `UnauthorizedRequestFailure`
  /// * 429 code: `TooManyRequestFailure`
  /// * Other: `HttpRequestFailure`
  @visibleForTesting
  Either<HttpRequestFailure, Response> checkFailureOrResponse(
      {required String path, required Response response}) {
    connectionStateListenable.value = true;
    if (displayResponseLogs) logResponse(response);
    if (((response.statusCode ?? unknownStatusCode) / 10).round() == 20) {
      return right(response);
    } else if (response.statusCode == 400) {
      if (response.data is String) {
        return left(BadRequestFailure(detail: response.data));
      }
      return left(BadRequestFailure.fromJson(response.data));
    } else if (response.statusCode == 401) {
      if (response.data is String) {
        return left(UnauthorizedRequestFailure(detail: response.data));
      }
      return left(UnauthorizedRequestFailure.fromJson(response.data));
    } else if (response.statusCode == 429) {
      return left(TooManyRequestFailure(endpoint: path));
    }
    debugPrint("[HTTP CHECK] Unknown HttpFailure: ${response.data}");
    return left(HttpRequestFailure(
        detail: '', statusCode: response.statusCode ?? unknownStatusCode));
  }

  /// Handles token expiration and renewal. It does not throw any exception,
  /// in case of not being able to renew the access token,
  /// it removes the authorization header
  @visibleForTesting
  Future<void> checkAccessJwt() async {
    try {
      if (jwtToken != null &&
          jwtToken!.access != null &&
          jwtToken!.access!.isNotEmpty &&
          JwtDecoder.isExpired(jwtToken!.access!)) {
        if (jwtToken!.refresh != null &&
            jwtToken!.refresh!.isNotEmpty &&
            !JwtDecoder.isExpired(jwtToken!.refresh!)) {
          final res = await dioClient.post(APIContract.jwtRefresh,
              data: {"refresh": jwtToken!.refresh});
          checkFailureOrResponse(path: APIContract.jwtRefresh, response: res)
              .fold((_) {
            removeJwt();
          }, (value) {
            setJwt(jwtToken!.copyWith(access: value.data["access"]));
          });
        } else {
          removeJwt();
        }
      }
    } on Exception {
      removeJwt();
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

  /// Handles exceptions thrown by connection errors. 
  /// 
  /// Updates the connection state as disabled (`false`)
  @visibleForTesting
  HttpConnectionFailure handleConnectionError(final Exception error) {
    debugPrint("[HTTP ERROR] $error");
    connectionStateListenable.value = false;
    return HttpConnectionFailure(detail: error.toString());
  }

  /// Performs a GET request to the API with the provided path.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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

  /// Performs a POST request to the API with the provided path and data.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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

  /// Performs a PUT request to the API with the provided path and data.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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

  /// Performs a PATCH request to the API with the provided path and data.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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

  /// Performs a PATCH image request to the API with the provided path, 
  /// image bytes and image mime type.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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

  /// Performs a DEL request to the API with the provided path.
  /// Path should not include the base url of the server.
  ///
  /// Returns either a HTTP failure or a HTTP response.
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
