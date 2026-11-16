import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;
  ApiException(this.message, {this.statusCode, this.fieldErrors});
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalized')
        .replace(queryParameters: query);
  }

  dynamic _handleResponse(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    dynamic decoded;
    if (bodyText.isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = bodyText;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Erreur serveur (${response.statusCode})';
      Map<String, dynamic>? fields;
      if (decoded is Map<String, dynamic>) {
        msg = (decoded['message'] ?? msg).toString();
        final err = decoded['errors'];
        if (err is Map) {
          fields = err.map((k, v) => MapEntry(k.toString(), v));
        }
      }
      throw ApiException(msg, statusCode: response.statusCode, fieldErrors: fields);
    }
    if (decoded is Map<String, dynamic>) {
      final status = decoded['status']?.toString();
      if (status != null && status != 'OK' && status != '200') {
        String msg = (decoded['message'] ?? 'Opération refusée').toString();
        Map<String, dynamic>? fields;
        final err = decoded['errors'];
        if (err is Map) {
          fields = err.map((k, v) => MapEntry(k.toString(), v));
        }
        throw ApiException(msg, fieldErrors: fields);
      }
      return decoded['payload'];
    }
    return decoded;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query), headers: await _headers());
    return _handleResponse(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(res);
  }

  Future<String> getText(String path) async {
    final res = await http.get(_uri(path), headers: await _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Erreur serveur (${res.statusCode})', statusCode: res.statusCode);
    }
    return utf8.decode(res.bodyBytes);
  }
}
