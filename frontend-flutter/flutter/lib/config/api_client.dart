import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/config/environment.dart';
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unauthorized_request_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:universal_io/io.dart';

const unknownStatusCode = 600;

class ApiClient {
  late final Dio _dioClient;
  JwtEntity? jwtToken;
  DateTime? accessExpirationDate;

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

  ApiClient({Dio? dioClient}) {
    _dioClient = dioClient ?? Dio();
    _dioClient.options = options;
  }

  void _setHeader(String key, String value) async {
    _dioClient.options.headers[key] = value;
  }

  void _removeHeader(String key) async {
    _dioClient.options.headers.remove(key);
  }

  void setLanguage(String localeName) async {
    _setHeader("accept-language", localeName);
  }

  void setJwt(JwtEntity jwt) {
    jwtToken = jwt;
    if (jwt.access != null) {
      accessExpirationDate = JwtDecoder.getExpirationDate(jwt.access!);
      _setHeader("authorization", "Bearer ${jwt.access}");
    }
  }

  void removeJwt() {
    _removeHeader("authorization");
  }

  Either<HttpRequestFailure, Response> _checkFailureOrResponse(
      {required Response response}) {
    if (((response.statusCode ?? unknownStatusCode) / 10).round() == 20) {
      return right(response);
    } else if (response.statusCode == 400) {
      return left(BadRequestFailure.fromJson(response.data));
    } else if (response.statusCode == 401) {
      return left(UnauthorizedRequestFailure.fromJson(response.data));
    }
    debugPrint("[HTTP CHECK] Unknown HttpFailure: ${response.data}");
    return left(HttpRequestFailure(
        detail: '', statusCode: response.statusCode ?? unknownStatusCode));
  }

  Future<void> _checkAccessJwt() async {
    if (accessExpirationDate != null &&
        jwtToken != null &&
        DateTime.now().toUtc().isAfter(accessExpirationDate!
            .toUtc()
            .subtract(const Duration(minutes: 5)))) {
      final res = await postRequest(APIContract.jwtRefresh,
          data: {"refresh": jwtToken!.refresh});
      res.fold((_) => null, (value) {
        setJwt(jwtToken!.copyWith(access: value.data["access"]));
      });
    }
  }

  Future<Either<HttpRequestFailure, Response>> getRequest(String path,
      {Map<String, dynamic>? queryParameters}) async {
    debugPrint("[HTTP REQUEST] GET ${_dioClient.options.baseUrl} - $path "
        "| Headers: ${_dioClient.options.headers}");
    await _checkAccessJwt();
    try {
      final res = await _dioClient.get<Map<String, dynamic>>(path,
          queryParameters: queryParameters);
      return _checkFailureOrResponse(response: res);
    } on DioError catch (error) {
      debugPrint("[HTTP ERROR] $error");
      return left(HttpRequestFailure.empty());
    }
  }

  Future<Either<HttpRequestFailure, Response>> postRequest(String path,
      {Object? data}) async {
    try {
      debugPrint("[HTTP REQUEST] POST | ${_dioClient.options.baseUrl} - $path "
          "| Headers: ${_dioClient.options.headers}");
      await _checkAccessJwt();
      final res = await _dioClient.post<Map<String, dynamic>>(path, data: data);
      return _checkFailureOrResponse(response: res);
    } on DioError catch (error) {
      debugPrint("[HTTP ERROR] $error");
      return left(HttpRequestFailure.empty());
    }
  }

  Future<Either<HttpRequestFailure, Response>> putRequest(String path,
      {Object? data}) async {
    try {
      debugPrint("[HTTP REQUEST] PUT | ${_dioClient.options.baseUrl} - $path "
          "| Headers: ${_dioClient.options.headers}");
      await _checkAccessJwt();
      final res = await _dioClient.put<Map<String, dynamic>>(path, data: data);
      return _checkFailureOrResponse(response: res);
    } on DioError catch (error) {
      debugPrint("[HTTP ERROR] $error");
      return left(HttpRequestFailure.empty());
    }
  }

  Future<Either<HttpRequestFailure, Response>> patchRequest(String path,
      {Object? data}) async {
    try {
      debugPrint("[HTTP REQUEST] PATCH | ${_dioClient.options.baseUrl} - $path "
          "| Headers: ${_dioClient.options.headers}");
      await _checkAccessJwt();
      final res =
          await _dioClient.patch<Map<String, dynamic>>(path, data: data);
      return _checkFailureOrResponse(response: res);
    } on DioError catch (error) {
      debugPrint("[HTTP ERROR] $error");
      return left(HttpRequestFailure.empty());
    }
  }

  Future<Either<HttpRequestFailure, Response>> patchImageRequest(
      String path, Uint8List bytes, String type) async {
    debugPrint("[HTTP REQUEST] Sending image...");
    FormData data = FormData.fromMap({
      "image": MultipartFile.fromBytes(bytes,
          filename: 'upload_image.${type.split("/").last}',
          contentType: MediaType("image", type)),
    });
    return await patchRequest(path, data: data);
  }

  Future<Either<HttpRequestFailure, Response>> delRequest(String path) async {
    try {
      debugPrint("[HTTP REQUEST] DEL | ${Environment.apiUrl} - $path "
          "| Headers: ${_dioClient.options.headers}");
      await _checkAccessJwt();
      final res = await _dioClient.delete<Map<String, dynamic>>(path);
      return _checkFailureOrResponse(response: res);
    } on DioError catch (error) {
      debugPrint("[HTTP ERROR] $error");
      return left(HttpRequestFailure.empty());
    }
  }
}
