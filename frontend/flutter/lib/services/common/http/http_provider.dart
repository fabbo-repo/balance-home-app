import 'dart:convert';
import 'dart:io';
import 'package:balance_home_app/common/app_config/env_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:http_parser/src/media_type.dart';

/// Encapsulates the proccess of making authorized HTTP requests from the services.
///
/// This allows for mocking all HTTP requests in service testing and also,
/// reduces code duplication by abstracting this proccess.
class HttpProvider {
  /// Client that will make all requests
  final http.Client client;

  /// Creates an [HttpProvider].
  ///
  /// The optional [http.CLient] argument is added for testing purposes.
  HttpProvider({http.Client? client}) : client = client ?? http.Client();

  /// Gets the base url of the server using environment variables.
  String baseUrl = EnvModel.BASE_URL;

  /// Returns the necessary content and authentication headers for all server requests.
  /* @visibleForTesting
  Future<Map<String, String>> getHeaders() async {
    AuthService authService = GetIt.I.get<UserState>().authService;
    return {
      "Content-Type": ContentType.json.toString(),
      "Authorization": "Bearer ${await authService.getIdToken()}"
    };
  } */

  /// Sends a [GET] request to [baseUrl]/[subPath].
  Future<HttpResponse> sendGetRequest(String subPath) async {
    //final headers = await getHeaders();
    http.Response response =
        await client.get(
          Uri.parse("$baseUrl/$subPath"), 
        //  headers: headers
        );
    return createHttpResponse(response);
  }

  /// Sends a `POST` request to `baseUrl`/`subPath` with `body` as the content.
  Future<HttpResponse> sendPostRequest(
    String subPath,
    Map<String, dynamic> body,
  ) async {
    http.Response response = await client.post(
      Uri.parse("$baseUrl/$subPath"),
      //headers: await getHeaders(), 
      body: jsonEncode(body)
    );
    return createHttpResponse(response);
  }

  /// Sends a `POST` multipart request to upload the image located at `filePath` to `baseUrl`/`subPath`.
  Future<http.StreamedResponse> sendPostImageRequest(
    String subPath,
    String filePath,
    String type,
  ) async {
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse("$baseUrl/$subPath"));
    List<int> bytes = await File(filePath).readAsBytes();
    http.MultipartFile httpImage = http.MultipartFile.fromBytes(
        'upload_file', bytes,
        contentType: MediaType.parse(type),
        filename: 'upload_file_${filePath.hashCode}.$type');
    //request.headers["Authorization"] =
    //    "Bearer ${await GetIt.I.get<UserState>().authService.getIdToken()}";
    request.files.add(httpImage);
    return await client.send(request);
  }

  /// Sends a `PUT` request to `baseUrl`/`subPath` and with `body` as content.
  Future<HttpResponse> sendPutRequest(String subPath, Map<String, dynamic> body) async {
    http.Response response = await client.put(
      Uri.parse("$baseUrl/$subPath"),
      //headers: await getHeaders(), 
      body: jsonEncode(body));
    return createHttpResponse(response);
  }

  /// Sends a `DEL` request to `baseUrl`/`subPath`.
  Future<HttpResponse> sendDelRequest(String subPath) async {
    http.Response response = await client
      .delete(
        Uri.parse("$baseUrl/$subPath"), 
        //headers: await getHeaders()
      );
    return createHttpResponse(response);
  }

  HttpResponse createHttpResponse(http.Response response) {
    Map<String, dynamic> jsonResponse =
        json.decode(const Utf8Decoder().convert(response.bodyBytes))
            as Map<String, dynamic>;
    return HttpResponse(response.statusCode, jsonResponse);
  }
}

class HttpResponse {
  late int statusCode;

  late Map<String, dynamic> content;

  HttpResponse(this.statusCode, this.content);
}
