import 'dart:convert';
import 'dart:developer';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:http_parser/src/media_type.dart' as mt;
import 'package:universal_io/io.dart' as io;

/// Encapsulates the proccess of making authorized HTTP requests from repositories.
class HttpClient {
  /// Client that will make all requests
  final http.Client client;

  JwtEntity? jwtEntity;

  /// Gets the base url of the server using environment variables.
  final String baseUrl;

  /// Creates an [HttpClient].
  ///
  /// The optional [http.CLient] argument is added for testing purposes.
  HttpClient(this.baseUrl, {http.Client? client})
      : client = client ?? http.Client();

  /// Returns the necessary content and authentication headers for all server requests.
  @visibleForTesting
  Map<String, String> getHeaders() {
    Map<String, String> headers = {
      "Content-Type": io.ContentType.json.toString(),
      "Accept-Language": "en"
    };
    if (jwtEntity != null) {
      headers["Authorization"] = "Bearer ${jwtEntity!.access}";
    }
    return headers;
  }

  /// Sends a [GET] request to [baseUrl]/[subPath].
  Future<HttpResponse> sendGetRequest(String subPath) async {
    try {
      HttpResponse response = HttpResponse.create(await client
          .get(Uri.parse("$baseUrl$subPath"), headers: getHeaders()));
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendGetRequest(subPath);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `POST` request to `baseUrl`/`subPath` with `body` as the content.
  Future<HttpResponse> sendPostRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = HttpResponse.create(await client.post(
          Uri.parse("$baseUrl$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPostRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `PATCH` multipart request to upload the image located at `filePath` to `baseUrl`/`subPath`.
  Future<HttpResponse> sendPatchImageRequest(
      String subPath, Uint8List imageBytes, String imageType) async {
    try {
      http.MultipartFile httpImage = http.MultipartFile.fromBytes(
          'image', imageBytes,
          contentType: mt.MediaType.parse(imageType),
          filename: 'upload_image.${imageType.split("/").last}');
      final request =
          http.MultipartRequest('PATCH', Uri.parse("$baseUrl$subPath"));
      request.files.add(httpImage);
      if (jwtEntity != null) {
        request.headers["Authorization"] = "Bearer ${jwtEntity!.access}";
      }
      http.StreamedResponse res = (await client.send(request));
      Map<String, dynamic> content = {};
      try {
        content = json.decode(utf8.decode(await res.stream.toBytes()));
      } catch (_) {}
      HttpResponse response = HttpResponse(res.statusCode, content);
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPatchImageRequest(subPath, imageBytes, imageType);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `PUT` request to `baseUrl`/`subPath` and with `body` as content.
  Future<HttpResponse> sendPutRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = HttpResponse.create(await client.put(
          Uri.parse("$baseUrl$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPutRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `PATCH` request to `baseUrl`/`subPath` and with `body` as content.
  Future<HttpResponse> sendPatchRequest(
      String subPath, Map<String, dynamic> body) async {
    try {
      HttpResponse response = HttpResponse.create(await client.patch(
          Uri.parse("$baseUrl$subPath"),
          headers: getHeaders(),
          body: jsonEncode(body)));
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendPatchRequest(subPath, body);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  /// Sends a `DEL` request to `baseUrl`/`subPath`.
  Future<HttpResponse> sendDelRequest(String subPath) async {
    try {
      HttpResponse response = HttpResponse.create(await client
          .delete(Uri.parse("$baseUrl$subPath"), headers: getHeaders()));
      if (await shouldRepeatResponse(response)) {
        // Recursive call
        return await sendDelRequest(subPath);
      }
      return response;
    } catch (e) {
      log("${Uri.parse("$baseUrl$subPath")} -> $e");
      return HttpResponse(500, {"message": e.toString()});
    }
  }

  @visibleForTesting
  Future<bool> shouldRepeatResponse(HttpResponse response) async {
    if (response.statusCode == 401 && jwtEntity != null) {
      // Try to refresh token in case 401 response
      HttpResponse newResponse = HttpResponse.create(await client.post(
          Uri.parse("$baseUrl${APIContract.jwtRefresh}"),
          headers: getHeaders(),
          body: jsonEncode({"refresh": jwtEntity!.refresh})));
      if (!newResponse.hasError) {
        // Update current JWT
        setJwtEntity(JwtEntity(
            access: newResponse.content["access"],
            refresh: jwtEntity!.refresh));
        return true;
      }
    }
    return false;
  }

  void setJwtEntity(JwtEntity? jwt) {
    jwtEntity = jwt;
  }
}

class HttpResponse {
  final int statusCode;

  final Map<String, dynamic> content;

  /// Whether [statusCode] is not a 20X code
  bool get hasError => (statusCode / 10).round() != 20;

  /// Get first message error in the content json if content is not empty
  String get errorMessage => (content.keys.isEmpty)
      ? ""
      : (content[content.keys.first] is! List)
          ? "${content.keys.first} : ${content[content.keys.first]}"
          : "${content.keys.first} : ${(content[content.keys.first] as List).first}";

  HttpResponse(this.statusCode, this.content);

  /// Response creation from `http` package
  factory HttpResponse.create(http.Response response) {
    Map<String, dynamic> jsonResponse = response.bodyBytes.isNotEmpty
        ? json.decode(const Utf8Decoder().convert(response.bodyBytes))
            as Map<String, dynamic>
        : {};
    HttpResponse httpResponse = HttpResponse(response.statusCode, jsonResponse);
    return httpResponse;
  }
}
