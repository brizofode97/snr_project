import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/core/auth/auth_tokens.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeTokens implements AuthTokens {
  String? token;
  bool refreshResult;
  int refreshCalls = 0;

  _FakeTokens(this.token, {this.refreshResult = true});

  @override
  Future<String?> get accessToken async => token;

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    if (refreshResult) token = 'nouveau-token';
    return refreshResult;
  }

  @override
  Future<void> signOut() async => token = null;
}

void main() {
  test('ajoute le Bearer et déballe le payload', () async {
    final tokens = _FakeTokens('token-initial');
    final client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token-initial');
      expect(request.url.path, endsWith('/creances'));
      expect(request.url.queryParameters['size'], '42');
      return http.Response(
        jsonEncode(<String, dynamic>{
          'status': 'OK',
          'payload': <dynamic>[<String, dynamic>{'id': 'c1'}],
        }),
        200,
      );
    });

    final api = ApiClient(client: client, tokens: tokens);
    final result = await api.get('/creances', query: {'size': '42'}) as List<dynamic>;

    expect(result.single['id'], 'c1');
    expect(tokens.refreshCalls, 0);
  });

  test('rafraîchit le token puis relance la requête sur 401', () async {
    final tokens = _FakeTokens('expire');
    final tokensVus = <String?>[];
    final client = MockClient((request) async {
      tokensVus.add(request.headers['Authorization']);
      if (tokensVus.length == 1) {
        return http.Response(
          jsonEncode(<String, dynamic>{'message': 'Token expiré'}),
          401,
        );
      }
      return http.Response(
        jsonEncode(<String, dynamic>{'status': 'OK', 'payload': <dynamic>[]}),
        200,
      );
    });

    final api = ApiClient(client: client, tokens: tokens);
    final result = await api.get('/debiteurs') as List<dynamic>;

    expect(result, isEmpty);
    expect(tokens.refreshCalls, 1);
    expect(tokensVus, <String?>['Bearer expire', 'Bearer nouveau-token']);
  });

  test('ne relance pas la requête si le refresh échoue', () async {
    final tokens = _FakeTokens('expire', refreshResult: false);
    var appels = 0;
    final body = utf8.encode(
      jsonEncode(<String, dynamic>{'message': 'Session terminée'}),
    );
    final client = MockClient((_) async {
      appels++;
      return http.Response.bytes(body, 401);
    });

    final api = ApiClient(client: client, tokens: tokens);

    await expectLater(
      api.get('/auth/me'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Session terminée')),
    );
    expect(tokens.refreshCalls, 1);
    expect(appels, 1);
  });

  test('transforme une erreur métier en ApiException', () async {
    final body = utf8.encode(jsonEncode(<String, dynamic>{
      'status': 'NOK',
      'message': 'Accès refusé',
      'errors': <String, dynamic>{'droits': 'report.view requis'},
    }));
    final client = MockClient(
      (_) async => http.Response.bytes(body, 200),
    );

    final api = ApiClient(client: client, tokens: _FakeTokens('token'));

    await expectLater(
      api.get('/audit'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'Accès refusé')
            .having((e) => e.fieldErrors?['droits'], 'fieldErrors', 'report.view requis'),
      ),
    );
  });
}
