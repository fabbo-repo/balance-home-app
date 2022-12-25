import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:balance_home_app/config/environment.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/features/login/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/login/domain/entities/jwt_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:http_parser/src/media_type.dart';

/// Encapsulates the proccess of making authorized HTTP requests from the services.
///
/// This allows for mocking all HTTP requests in service testing and also,
/// reduces code duplication by abstracting this proccess.
class HttpService {
  /// Client that will make all requests
  final http.Client _client;

  JwtEntity? _jwtModel;

  final FlutterSecureStorage _secureStorage;

  /// Creates an [HttpService].
  ///
  /// The optional [http.CLient] argument is added for testing purposes.
  HttpService({http.Client? client, FlutterSecureStorage? secureStorage})
      : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Gets the base url of the server using environment variables.
  String baseUrl = Environment.apiUrl;

  /// Returns the necessary content and authentication headers for all server requests.
  Map<String, String> getHeaders() {
    Map<String, String> headers = {
      "Content-Type": ContentType.json.toString(),
      "Accept-Language": "en"
    };
    if (_jwtModel != null) {
      headers["Authorization"] = "Bearer ${_jwtModel!.access}";
    }
    return headers;
  }

  /// Sends a [GET] request to [baseUrl]/[subPath].
  Future<HttpResponse> sendGetRequest(String subPath) async {
    try {
      HttpResponse response = _createHttpResponse(await _client
          .get(Uri.parse("$baseUrl/$subPath"), headers: getHeaders()));
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendGetRequest(subPath);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `POST` request to `baseUrl`/`subPath` with `body` as the content.
  Future<HttpResponse> sendPostRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = _createHttpResponse(await _client.post(
          Uri.parse("$baseUrl/$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPostRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `POST` multipart request to upload the image located at `filePath` to `baseUrl`/`subPath`.
  Future<HttpResponse> sendPostImageRequest(
      String subPath, String filePath, String type) async {
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse("$baseUrl/$subPath"));
      List<int> bytes = await File(filePath).readAsBytes();
      http.MultipartFile httpImage = http.MultipartFile.fromBytes(
          'upload_file', bytes,
          contentType: MediaType.parse(type),
          filename: 'upload_file_${filePath.hashCode}.$type');
      if (_jwtModel != null) {
        request.headers["Authorization"] = "Bearer ${_jwtModel!.access}";
      }
      request.files.add(httpImage);
      HttpResponse response =
          HttpResponse((await _client.send(request)).statusCode, {});
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPostImageRequest(subPath, filePath, type);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `PUT` request to `baseUrl`/`subPath` and with `body` as content.
  Future<HttpResponse> sendPutRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = _createHttpResponse(await _client.put(
          Uri.parse("$baseUrl/$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPutRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `PATCH` request to `baseUrl`/`subPath` and with `body` as content.
  Future<HttpResponse> sendPatchRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = _createHttpResponse(await _client.patch(
          Uri.parse("$baseUrl/$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPatchRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `DEL` request to `baseUrl`/`subPath`.
  Future<HttpResponse> sendDelRequest(String subPath) async {
    try {
      HttpResponse response = _createHttpResponse(await _client
          .delete(Uri.parse("$baseUrl/$subPath"), headers: getHeaders()));
      if (await _shouldRepeatResponse(response)) {
        // Recursive call
        return await sendDelRequest(subPath);
      }
      return response;
    } catch (e) {
      log(e.toString());
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  HttpResponse _createHttpResponse(http.Response response) {
    Map<String, dynamic> jsonResponse =
        json.decode(const Utf8Decoder().convert(response.bodyBytes))
            as Map<String, dynamic>;
    HttpResponse httpResponse = HttpResponse(response.statusCode, jsonResponse);
    return httpResponse;
  }

  Future<bool> _shouldRepeatResponse(HttpResponse response) async {
    if (response.statusCode == 401) {
      if (_jwtModel != null) {
        // Try to refresh token in case 401 response
        HttpResponse newResponse = _createHttpResponse(await _client.post(
            Uri.parse("$baseUrl/${APIContract.jwtRefresh}"),
            headers: getHeaders(),
            body: jsonEncode({"refresh": _jwtModel!.refresh})));
        // If 401 is recived it should be tried with stored credentials
        if (newResponse.statusCode == 401) {
          _jwtModel = null; // Current token is not valid
          String? email = await _secureStorage.read(key: "email");
          String? password = await _secureStorage.read(key: "password");
          if (email != null && password != null) {
            newResponse = _createHttpResponse(await _client.post(
                Uri.parse("$baseUrl/${APIContract.jwtRefresh}"),
                headers: getHeaders(),
                body: jsonEncode(
                    CredentialsEntity(email: email, password: password)
                        .toJson())));
            if (newResponse.statusCode != 401) {
              // Update current JWT
              _jwtModel = JwtEntity.fromJson(newResponse.content);
              return true;
            }
          }
        } else {
          // Update current JWT
          _jwtModel = JwtEntity(
              access: newResponse.content["access"],
              refresh: _jwtModel!.refresh);
          return true;
        }
      }
    }
    if (response.statusCode == 500) ErrorView.go();
    return false;
  }

  void setJwtModel(JwtEntity jwt) {
    _jwtModel = jwt;
  }
}

class HttpResponse {
  final int statusCode;

  final Map<String, dynamic> content;

  /// Whether [statusCode] is not a 20X code
  bool get hasError => (statusCode / 10) != 20;

  /// Get first message error in the content json if content is not empty
  String get errorMessage =>
      (content.keys.isEmpty) ? "" : content[content.keys.first];

  HttpResponse(this.statusCode, this.content);
}
