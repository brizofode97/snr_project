import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';
import '../auth/auth_tokens.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors,
  });

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, AuthTokens? tokens})
      : _client = client ?? http.Client(),
        _tokens = tokens ?? AuthService.instance;

  static final ApiClient instance = ApiClient();

  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client;
  final AuthTokens _tokens;

  Uri uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalized')
        .replace(queryParameters: (query?.isNotEmpty ?? false) ? query : null);
  }

  Future<Map<String, String>> _headers({String accept = 'application/json'}) async {
    final token = await _tokens.accessToken;
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': accept,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    String method,
    Uri target, {
    Object? body,
    String accept = 'application/json',
    bool retryOn401 = true,
  }) async {
    final request = http.Request(method, target)
      ..headers.addAll(await _headers(accept: accept))
      ..body = body == null ? '' : jsonEncode(body);
    final response = await _client.send(request).then(http.Response.fromStream);
    if (response.statusCode == 401 && retryOn401) {
      final refreshed = await _tokens.refresh();
      if (refreshed) {
        return _send(
          method,
          target,
          body: body,
          accept: accept,
          retryOn401: false,
        );
      }
    }
    return response;
  }

  dynamic _handleResponse(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes, allowMalformed: true);
    dynamic decoded;
    if (bodyText.isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = bodyText;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionOf(decoded, response.statusCode);
    }
    if (decoded is Map<String, dynamic>) {
      final status = decoded['status']?.toString();
      if (status != null && status != 'OK' && status != '200') {
        throw _exceptionOf(decoded, response.statusCode);
      }
      return decoded['payload'];
    }
    return decoded;
  }

  ApiException _exceptionOf(dynamic decoded, int statusCode) {
    String msg = 'Erreur serveur ($statusCode)';
    Map<String, dynamic>? fields;
    if (decoded is Map<String, dynamic>) {
      msg = (decoded['message'] ?? msg).toString();
      final errors = decoded['errors'];
      if (errors is Map) {
        fields = errors.map((k, v) => MapEntry(k.toString(), v));
      }
    }
    return ApiException(msg, statusCode: statusCode, fieldErrors: fields);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async =>
      _handleResponse(await _send('GET', uri(path, query)));

  Future<dynamic> post(String path, {Object? body}) async =>
      _handleResponse(await _send('POST', uri(path), body: body));

  Future<dynamic> put(String path, {Object? body}) async =>
      _handleResponse(await _send('PUT', uri(path), body: body));

  Future<dynamic> delete(String path) async =>
      _handleResponse(await _send('DELETE', uri(path)));

  Future<String> getText(
    String path, {
    String accept = 'text/csv',
    Map<String, String>? query,
  }) async {
    final response = await _send('GET', uri(path, query), accept: accept);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionOf(
        utf8.decode(response.bodyBytes, allowMalformed: true),
        response.statusCode,
      );
    }
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}
